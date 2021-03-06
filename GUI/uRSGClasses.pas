unit uRSGClasses;

interface

uses
  uCommon, System.Classes, System.SysUtils, Vcl.Forms, uConst, System.IOUtils, System.Types, TlHelp32, WinSvc, System.NetEncoding,
  ShellApi;

type
  TNotifyEventMsg = procedure(aMsg: string) of object;

  TNotifyEventStatusMsg = procedure(aMsg: string) of object;

  TServer = class
  private
    FProtocol: string;
    FPort: string;
    FHost: string;
    FAdress: string;
    FIsDefaultSettings: boolean;
    FIsActive: boolean;
    FIsStartAsService: boolean;
    FIsStartedAsService: boolean;
    FServerExePath: string;
    FServerServiceName: string;
    FIsOnline: boolean;
    OnFNotifyEventMsg: TNotifyEventMsg;
    OnFNotifyEventStatusMsg: TNotifyEventStatusMsg;

    procedure ReadIniSettings;
    function HowServerStarted: boolean;
    function IsServiceRunning(aSMachine, aSService: PChar): boolean;
    function IsProcessExists(aExeFileName: string): Boolean;
    function ServiceGetStatus(aSMachine, aSService: PChar): DWORD;
    function ServiceStart(sMachine, sService: string): Boolean;
    function ServiceStop(aMachine, aServiceName: string): boolean;
    function KillTask(aExeFileName: string): Boolean;
  public
    constructor Create();
    function Start(): boolean;
    function Stop(): boolean;
    function GoOffline(var aJsonAnswer: string): boolean;
    function GoOnline(): boolean;
    function GetRequest(aRequest: string): string;
    function PostJsonRequest(aRequest, aJson: string): string;
    function PostUrlEncodedRequest(aRequest: string; aPostParams: TStrings): string;
    function PostMultiPart(aRequest: string; aFileName: string; aIsOverWrite: string): string;
    property Protocol: string read FProtocol write FProtocol;
    property Host: string read FHost write FHost;
    property Port: string read FPort write FPort;
    property Adress: string read FAdress write FAdress;
    property IsDefaultSettings: boolean read FIsDefaultSettings write FIsDefaultSettings;
    property IsActive: boolean read FIsActive write FIsActive;
    property IsOnline: boolean read FIsOnline write FIsOnline;
    property OnNotifyEventMsg: TNotifyEventMsg read OnFNotifyEventMsg write OnFNotifyEventMsg;
    property OnNotifyEventStatusMsg: TNotifyEventStatusMsg read OnFNotifyEventStatusMsg write OnFNotifyEventStatusMsg;
    property IsStartAsService: boolean read FIsStartAsService write FIsStartAsService;
    property ServerExePath: string read FServerExePath;
  end;

implementation

uses
  System.IniFiles, IdHTTP, superobject, uMain, Winapi.Windows, IdMultipartFormData;

{ TServer }

constructor TServer.Create();
var
  c: ISP<TidHttp>;
  jo: ISuperObject;
begin
  ReadIniSettings();
  FIsActive := false;
  FIsOnline := false;
  c := TSP<TidHttp>.Create();
  try
    jo := SO(c.Get(FAdress + '/Test/Connection'));
    if (jo.S['answer'] = 'ok') then
    begin
      FIsActive := true;
      FIsOnline := true;
      HowServerStarted(); // exe or service?
    end;
  except
    on E: Exception do
    begin
      FIsActive := false;
      FIsOnline := false;
    end;
  end;
end;

function TServer.GetRequest(aRequest: string): string;
var
  client: ISP<TIdHTTP>;
  idHTTP: TIdhTTP;
begin
  client := TSP<TIdHTTP>.Create();
  Result := client.Get(FAdress + '/' + aRequest);
  if Assigned(OnFNotifyEventMsg) then
    OnFNotifyEventMsg(Result);
end;

function TServer.GoOffline(var aJsonAnswer: string): boolean;
var
  jo: ISuperobject;
begin
  Result := false;
  jo := SO(GetRequest('System/Offline'));
  aJsonAnswer := jo.AsJSon(false, false);
  if jo.S['answer'] = 'ok' then
  begin
    Main.Timers.tStatus.Enabled := false;
    if Assigned(OnFNotifyEventStatusMsg) then
      OnFNotifyEventStatusMsg(ServerPaused);
    FIsOnline := false;
    Result := true;
  end;
end;

function TServer.GoOnline: boolean;
var
  jo: ISuperobject;
begin
  Result := false;
  jo := SO(GetRequest('System/Online'));
  Result := jo.S['answer'] = 'ok';
  if Result then
  begin
    Main.Timers.tStatus.Enabled := true;
    FIsOnline := true;
    if Assigned(OnFNotifyEventStatusMsg) then
      OnFNotifyEventStatusMsg(ServerStarted);
  end;
  if Assigned(OnFNotifyEventMsg) then
    OnFNotifyEventMsg(jo.AsJSon(false, false));
end;

function TServer.PostJsonRequest(aRequest, aJson: string): string;
var
  jo: ISuperobject;
  ss: ISP<TStringStream>;
  client: ISP<TIdHTTP>;
begin
  client := TSP<TIdHTTP>.Create();
  ss := TSP<TStringStream>.Create();
  jo := SO(aJson);
  ss.WriteString(jo.AsJSon(false, false));
  client.Request.ContentType := 'application/json';
  client.Request.ContentEncoding := 'utf-8';
  Result := client.Post(Main.Server.Adress + '/' + aRequest, ss);

  if Assigned(OnFNotifyEventMsg) then
    OnFNotifyEventMsg(Result);
end;

function TServer.PostMultiPart(aRequest: string; aFileName, aIsOverWrite: string): string;
var
  postData: ISP<TIdMultiPartFormDataStream>;
  client: ISP<TIdHTTP>;
  ss: ISP<TStringStream>;
begin
  ss := TSP<TStringStream>.Create();
  postData := TSP<TIdMultiPartFormDataStream>.Create();
  client := TSP<TIdHTTP>.Create();

  client.Request.Referer := Main.Server.Adress + '/' + aRequest;
  client.Request.ContentType := 'multipart/form-data';
  client.Request.RawHeaders.AddValue('AuthToken', System.NetEncoding.TNetEncoding.URL.Encode('evjTI82N'));
  postData.AddFormField('filename', aFileName);
  postData.AddFormField('isOverwrite', aIsOverWrite); // 'true' or 'false' here
  postData.AddFile('attach', aFileName, 'application/x-rar-compressed');
  client.POST(Main.Server.Adress + '/' + aRequest, postData, ss); //
  Result := ss.DataString;
end;

function TServer.PostUrlEncodedRequest(aRequest: string; aPostParams: TStrings): string;
var
  client: ISP<TIdHTTP>;
begin
  client := TSP<TIdHTTP>.Create();
  client.Request.ContentType := 'application/x-www-form-urlencoded';
  client.Request.ContentEncoding := 'utf-8';
  Result := client.Post(Main.Server.Adress + '/' + aRequest, aPostParams);
  if Assigned(OnFNotifyEventMsg) then
    OnFNotifyEventMsg(Result);
end;

procedure TServer.ReadIniSettings();
var
  filepath: string;
  ini: ISP<TIniFile>;
begin
  filepath := ExtractFilePath(Application.ExeName) + SettingsFile;
  if TFile.Exists(filepath) then
  begin
    ini := TSP<Tinifile>.Create(Tinifile.Create(filepath));
    FProtocol := ini.ReadString('server', 'protocol', '<None>');
    FHost := ini.ReadString('server', 'host', '<None>');
    FPort := ini.ReadString('server', 'port', '<None>');
    FServerExePath := ini.ReadString('server', 'exepath', '<None>');
    FServerServiceName := ini.ReadString('server', 'serviceName', '<None>');
    FIsStartAsService := ini.ReadString('server', 'isStartAsService', '<None>') = 'true';
    FIsDefaultSettings := false;
  end
  else
  begin
    FProtocol := 'http';
    FHost := 'localhost';
    FPort := '7777';
    FIsStartAsService := false;
    FIsDefaultSettings := true;
  end;
  FAdress := FProtocol + '://' + FHost + ':' + FPort;
end;

function TServer.HowServerStarted: boolean;
var
  asExe: boolean;
  asService: boolean;
begin
  asExe := IsProcessExists(ExtractFileName(FServerExePath));
  asService := IsServiceRunning(nil, PWideChar(FServerServiceName));
  Result := asExe or asService;
  if Result then
    FIsStartedAsService := asService;
end;

function TServer.IsServiceRunning(aSMachine, aSService: PChar): boolean;
begin
  Result := SERVICE_RUNNING = ServiceGetStatus(aSMachine, aSService);
end;

function TServer.ServiceStart(sMachine, sService: string): Boolean;
var
  schSCManager, schService: SC_HANDLE;
  ssStatus: TServiceStatus;
  dwWaitTime: Cardinal;
begin
  // Get a handle to the SCM database.
  schSCManager := OpenSCManager(PChar(sMachine), nil, SC_MANAGER_CONNECT);
  if (schSCManager = 0) then
    RaiseLastOSError;
  try
    // Get a handle to the service.

    schService := OpenService(schSCManager, PChar(sService), SERVICE_START or SERVICE_QUERY_STATUS);
    if (schService = 0) then
      RaiseLastOSError;
    try
      // Check the status in case the service is not stopped.

      if not QueryServiceStatus(schService, ssStatus) then
      begin
        if (ERROR_SERVICE_NOT_ACTIVE <> GetLastError()) then
          RaiseLastOSError;
        ssStatus.dwCurrentState := SERVICE_STOPPED;
      end;

      // Check if the service is already running

      if (ssStatus.dwCurrentState <> SERVICE_STOPPED) and (ssStatus.dwCurrentState <> SERVICE_STOP_PENDING) then
      begin
        Result := True;
        Exit;
      end;

      // Wait for the service to stop before attempting to start it.

      while (ssStatus.dwCurrentState = SERVICE_STOP_PENDING) do
      begin
        // Do not wait longer than the wait hint. A good interval is
        // one-tenth of the wait hint but not less than 1 second
        // and not more than 10 seconds.

        dwWaitTime := ssStatus.dwWaitHint div 10;

        if (dwWaitTime < 1000) then
          dwWaitTime := 1000
        else if (dwWaitTime > 10000) then
          dwWaitTime := 10000;

        Sleep(dwWaitTime);

        // Check the status until the service is no longer stop pending.

        if not QueryServiceStatus(schService, ssStatus) then
        begin
          if (ERROR_SERVICE_NOT_ACTIVE <> GetLastError()) then
            RaiseLastOSError;
          Break;
        end;
      end;

      // Attempt to start the service.

      // NOTE: if you use a version of Delphi that incorrectly declares
      // StartService() with a 'var' lpServiceArgVectors parameter, you
      // can't pass a nil value directly in the 3rd parameter, you would
      // have to pass it indirectly as either PPChar(nil)^ or PChar(nil^)
      if not StartService(schService, 0, PPChar(nil)^) then
        RaiseLastOSError;

      // Check the status until the service is no longer start pending.

      if not QueryServiceStatus(schService, ssStatus) then
      begin
        if (ERROR_SERVICE_NOT_ACTIVE <> GetLastError()) then
          RaiseLastOSError;
        ssStatus.dwCurrentState := SERVICE_STOPPED;
      end;

      while (ssStatus.dwCurrentState = SERVICE_START_PENDING) do
      begin
        // Do not wait longer than the wait hint. A good interval is
        // one-tenth the wait hint, but no less than 1 second and no
        // more than 10 seconds.

        dwWaitTime := ssStatus.dwWaitHint div 10;

        if (dwWaitTime < 1000) then
          dwWaitTime := 1000
        else if (dwWaitTime > 10000) then
          dwWaitTime := 10000;

        Sleep(dwWaitTime);

        // Check the status again.

        if not QueryServiceStatus(schService, ssStatus) then
        begin
          if (ERROR_SERVICE_NOT_ACTIVE <> GetLastError()) then
            RaiseLastOSError;
          ssStatus.dwCurrentState := SERVICE_STOPPED;
          Break;
        end;
      end;

      // Determine whether the service is running.

      Result := (ssStatus.dwCurrentState = SERVICE_RUNNING);
    finally
      CloseServiceHandle(schService);
    end;
  finally
    CloseServiceHandle(schSCManager);
  end;
end;

function TServer.ServiceStop(aMachine, aServiceName: string): boolean;
// aMachine ��� UNC ����, ���� ��������� ��������� ���� �����
var
  h_manager, h_svc: SC_Handle;
  svc_status: TServiceStatus;
  dwCheckPoint: DWord;
begin
  h_manager := OpenSCManager(PChar(aMachine), nil, SC_MANAGER_CONNECT);
  if h_manager > 0 then
  begin
    h_svc := OpenService(h_manager, PChar(aServiceName), SERVICE_STOP or SERVICE_QUERY_STATUS);
    if h_svc > 0 then
    begin
      if (ControlService(h_svc, SERVICE_CONTROL_STOP, svc_status)) then
      begin
        if (QueryServiceStatus(h_svc, svc_status)) then
        begin
          while (SERVICE_STOPPED <> svc_status.dwCurrentState) do
          begin
            dwCheckPoint := svc_status.dwCheckPoint;
            Sleep(svc_status.dwWaitHint);
            if (not QueryServiceStatus(h_svc, svc_status)) then
            begin
              // couldn't check status
              break;
            end;
            if (svc_status.dwCheckPoint < dwCheckPoint) then
              break;
          end;
        end;
      end;
      CloseServiceHandle(h_svc);
    end;
    CloseServiceHandle(h_manager);
  end;
  Result := SERVICE_STOPPED = svc_status.dwCurrentState;
end;

function TServer.KillTask(aExeFileName: string): Boolean;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  r: integer;
begin
  r := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(aExeFileName)) or (UpperCase(FProcessEntry32.szExeFile)
      = UpperCase(aExeFileName))) then
      r := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
  Result := r <> 0;
end;

// https://stackoverflow.com/questions/876224/how-to-check-if-a-process-is-running-using-delphi
function TServer.IsProcessExists(aExeFileName: string): Boolean;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := False;
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(aExeFileName)) or (UpperCase(FProcessEntry32.szExeFile)
      = UpperCase(aExeFileName))) then
    begin
      Result := True;
    end;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function TServer.ServiceGetStatus(aSMachine, aSService: PChar): DWORD;
  {******************************************}
  {*** Parameters: ***}
  {*** sService: specifies the name of the service to open
  {*** sMachine: specifies the name of the target computer
  {*** ***}
  {*** Return Values: ***}
  {*** -1 = Error opening service ***}
  {*** 1 = SERVICE_STOPPED ***}
  {*** 2 = SERVICE_START_PENDING ***}
  {*** 3 = SERVICE_STOP_PENDING ***}
  {*** 4 = SERVICE_RUNNING ***}
  {*** 5 = SERVICE_CONTINUE_PENDING ***}
  {*** 6 = SERVICE_PAUSE_PENDING ***}
  {*** 7 = SERVICE_PAUSED ***}
  {******************************************}
var
  SCManHandle, SvcHandle: SC_Handle;
  SS: TServiceStatus;
  dwStat: DWORD;
begin
  dwStat := 0;
  // Open service manager handle.
  SCManHandle := OpenSCManager(aSMachine, nil, SC_MANAGER_CONNECT);
  if (SCManHandle > 0) then
  begin
    SvcHandle := OpenService(SCManHandle, aSService, SERVICE_QUERY_STATUS);
    // if Service installed
    if (SvcHandle > 0) then
    begin
      // SS structure holds the service status (TServiceStatus);
      if (QueryServiceStatus(SvcHandle, SS)) then
        dwStat := SS.dwCurrentState;
      CloseServiceHandle(SvcHandle);
    end;
    CloseServiceHandle(SCManHandle);
  end;
  Result := dwStat;
end;

function TServer.Start(): boolean;
var
  param: string;
begin
  Result := false;

  if (FIsActive) and (not FIsOnline) and (GoOnline()) then
    Exit;

  if FIsActive then
    Exit();

  if FIsStartAsService then
  begin // as service
    if ServiceStart('', FServerServiceName) then
    begin
      FIsStartedAsService := true;
      FIsActive := true;
      Exit(true);
    end;
  end
  else
  begin // as exe
    param := 'exe';
    ShellExecute(0, 'open', PWideChar(FServerExePath), PChar(param), nil, SW_SHOW);
    FIsStartedAsService := false;
    FIsActive := true;
    Exit(true);
  end;
end;

function TServer.Stop(): boolean;
begin
  if (not FIsActive) then
    Exit();

  Result := false;
  // prepare Stop
  GetRequest('System/Offline');
  sleep(3000); // give time to finish job

  if FIsStartedAsService then
    Result := (ServiceStop('', FServerServiceName))
  else
    Result := KillTask(ExtractFileName(FServerExePath));

  Main.Timers.StopTimers();
  FIsOnline := false;
  FIsActive := false;
end;

end.

