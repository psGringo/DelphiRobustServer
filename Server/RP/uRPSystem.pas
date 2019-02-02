unit uRPSystem;

interface

uses
  uRP, System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB, IdContext, System.NetEncoding,
  uAttributes, System.JSON, TypInfo, System.Rtti, System.IOUtils, Winapi.PsAPI, Winapi.Windows, Math, IdHeaderList;

type
  TRPSystem = class(TRP)
  protected
    function CurrentProcessMemoryKB: Extended;
    function CurrentProcessMemoryPeakKB: Extended;
  private
    function CloseAllConnections(): boolean;
    procedure ServerHeadersAvailable(AContext: TIdContext; const AUri: string; AHeaders: TIdHeaderList; var
      VContinueProcessing: Boolean);
    procedure ServerHeadersBlocked(AContext: TIdContext; AHeaders: TIdHeaderList; var VResponseNo: Integer; var
      VResponseText, VContentText: string);
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
      overload; override;
    procedure Memory();
    procedure WorkTime();
    procedure Offline();
    procedure Online();
    procedure Connections();
  end;

implementation

uses
  uMain, IdThreadSafe;
{ TRPApi }

function TRPSystem.CloseAllConnections: boolean;
var
  i: Integer;
  l: TList;
  c: TIdThreadSafeObjectList;
begin
  Result := false;

  c := Main.Server.Contexts;
  if c = nil then
    Exit();

  l := c.LockList();

  try
    for i := 0 to l.Count - 1 do
      TIdContext(l.Items[i]).Connection.Disconnect(False);
    Result := true;
  finally
    c.UnlockList;
  end;
end;

procedure TRPSystem.Connections;
var
  jo: ISuperObject;
  l: TList;
begin
  with Main.Server.Contexts.LockList() do
  try
    jo := SO;
    jo.I['connections'] := Main.Server.Contexts.Count;
    FResponses.OkWithJson(jo.AsJSon(false, false));
  finally
    Main.Server.Contexts.UnlockList();
  end;
end;

constructor TRPSystem.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  Execute('System');
end;

function TRPSystem.CurrentProcessMemoryKB: Extended;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters)) then
    Result := trunc(MemCounters.WorkingSetSize / 1024)
  else
    RaiseLastOSError;
end;

function TRPSystem.CurrentProcessMemoryPeakKB: Extended;
var
  MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess, @MemCounters, SizeOf(MemCounters)) then
    Result := trunc(MemCounters.PeakWorkingSetSize / 1024)
  else
    RaiseLastOSError;
end;

procedure TRPSystem.Memory();
var
  json: ISuperobject;
begin
  json := SO;
  json.S['memory'] := CurrentProcessMemoryKB.ToString() + ' KB / ' + CurrentProcessMemoryPeakKB.ToString() + ' KB';
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPSystem.Online();
begin
  Main.Server.OnHeadersAvailable := nil;
  Main.Server.OnHeadersBlocked := nil;
  FResponses.OK();
end;

procedure TRPSystem.Offline();
begin
//  CloseAllConnections();
//  Main.Server.Scheduler.ActiveYarns.Clear; ////Main.Server.Scheduler.AcquireYarn;
  Main.Server.OnHeadersAvailable := ServerHeadersAvailable;
  Main.Server.OnHeadersBlocked := ServerHeadersBlocked;
  FResponses.OK();
  //   Main.Stop();
end;

procedure TRPSystem.WorkTime;
var
  json: ISuperobject;
begin
  json := SO;
  json.S['workTime'] := TimeToStr(Main.Timers.WorkTime);
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPSystem.ServerHeadersAvailable(AContext: TIdContext; const AUri: string; AHeaders: TIdHeaderList; var
  VContinueProcessing: Boolean);
begin
  if not AUri.contains('System') then
  begin
    VContinueProcessing := false;
  end;
end;

procedure TRPSystem.ServerHeadersBlocked(AContext: TIdContext; AHeaders: TIdHeaderList; var VResponseNo: Integer; var
  VResponseText, VContentText: string);
begin
  VResponseNo := 503;
  VResponseText := 'Service Unavailable';
end;

end.
