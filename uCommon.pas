unit uCommon;

interface

uses
  LDSLogger, uConst, System.SysUtils, System.Classes, IdCustomHTTPServer,
  superobject, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, IdMessage, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdExplicitTLSClientServerBase, IdMessageClient, IdSMTPBase,
  IdSMTP, IdMessageCoderMIME, IdMessageCoder, IdGlobal, HTTPApp, vcl.Forms;

type
  int = integer;

  ISP<T> = reference to function: T;

  TSP<T: class, constructor> = class(TInterfacedObject, ISP<T>)
  private
    FValue: T;
    function Invoke: T;
    procedure SetValue(const Value: T);
  public
    constructor Create; overload;
    constructor Create(AValue: T); overload;
    destructor Destroy; override;
    function Extract: T;
    property Value: T read FValue write SetValue;
  end;

  TEmail = class(TInterfacedObject)
    procedure Send(aHost: string; aPort: int; aSubject, aEmailContent, aRecipientEmail, aMyEmail, aMyPassword, aFromName: string);
  end;

  TLogger = class
    procedure LogError(aMsg: string);
    procedure LogInfo(aMsg: string);
    procedure UpdateMainLogMemo();
  end;

  TResponses = class(TInterfacedObject)
  private
    FAResponseInfo: TIdHTTPResponseInfo;
    FARequestInfo: TIdHTTPRequestInfo;
    function GetCommandType(): string;
  public
    constructor Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
    procedure OK();
    procedure Error(EMessage: string = ''; ACodeNumber: integer = -1);
    procedure ResponseOkWithJson(aJsonData: string);
    procedure ResponseSuccessfullInsert(aId: integer);
    property ARequestInfo: TIdHTTPRequestInfo read FARequestInfo write FARequestInfo;
    property AResponseInfo: TIdHTTPResponseInfo read FAResponseInfo write FAResponseInfo;
  end;


  TCommon = class
  public
    class procedure DecodeFormDataRemy(ARequestInfo: TIdHTTPRequestInfo);
    {< method from Remy, doesn't work...}
  end;

const
  logFileName = 'log.txt';

implementation

uses
  uMain;
{ TLDSLoggerImpl }

procedure TLogger.LogError(aMsg: string);
var
  l: TLDSLogger;
begin
  l := TLDSLogger.Create(logFileName);
  try
    l.LogStr(aMsg, tlpError);
    UpdateMainLogMemo;
  finally
    l.Free;
  end;
end;

procedure TLogger.LogInfo(aMsg: string);
var
  l: TLDSLogger;
begin
  l := TLDSLogger.Create(logFileName);
  try
    l.LogStr(aMsg, tlpInformation);
    UpdateMainLogMemo;
  finally
    l.free;
  end;
end;

procedure TLogger.UpdateMainLogMemo;
var
  fs: TFileStream;
  ss: ISP<TstringStream>;
  sl: ISP<TStringList>;
  i: Integer;
begin
  fs := nil;
  fs := WaitAndCreateLogFileStream(logFileName, fmOpenRead, -1);
  ss := TSP<TstringStream>.Create();
  sl := TSP<TStringList>.Create();
  try
    ss.LoadFromStream(fs);
    Main.mLog.Lines.Text := ss.DataString;
    sl.Assign(Main.mLog.Lines);
    Main.mLog.Lines.Clear;
    for i := sl.Count - 1 downto 0 do
      Main.mLog.Lines.Add(sl[i]);
  finally
    fs.Free;
  end;
end;

{ TEmail }
procedure TEmail.Send(aHost: string; aPort: int; aSubject, aEmailContent, aRecipientEmail, aMyEmail, aMyPassword, aFromName: string);
var
  idSMTP: ISP<TIdSMTP>;
  msg: ISP<TIdMessage>;
  sslOpen: ISP<TIdSSLIOHandlerSocketOpenSSL>;
begin
  //
  idSMTP := TSP<TIdSMTP>.Create(TIdSMTP.Create(nil));
  msg := TSP<TIdMessage>.Create(TIdMessage.Create(nil));
  sslOpen := TSP<TIdSSLIOHandlerSocketOpenSSL>.Create(TIdSSLIOHandlerSocketOpenSSL.Create(nil));

  idSMTP.Host := aHost;
  idSMTP.Port := aPort;
  idSMTP.AuthType := satDefault;
  idSMTP.Username := aMyEmail;
  idSMTP.Password := aMyPassword;
  //for SSL
//  SSLOpen := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  sslOpen.Destination := idSMTP.Host + ':' + IntToStr(idSMTP.Port);
  sslOpen.Host := idSMTP.Host;
  sslOpen.Port := idSMTP.Port;
  sslOpen.DefaultPort := 0;
  sslOpen.SSLOptions.Method := sslvSSLv23;
  sslOpen.SSLOptions.Mode := sslmUnassigned;
  //
  idSMTP.IOHandler := sslOpen;
  idSMTP.UseTLS := utUseImplicitTLS;
  //
  msg.ContentType := 'text/html; charset=windows-1251';
  msg.Body.Text := aEmailContent;
  msg.Subject := aSubject;
  msg.From.Address := aMyEmail; // 'shop.bel-ozero@yandex.ru';
  msg.From.Name :=   aFromName;
  msg.Recipients.EMailAddresses := aRecipientEmail;
  //
  try
    idSMTP.Connect;
    idSMTP.Send(msg);
  except
    on E: Exception do
    begin
      raise Exception.Create('Error Message ' + e.Message);
      idSMTP.Disconnect();
    end;
  end;
end;

class procedure TCommon.DecodeFormDataRemy(ARequestInfo: TIdHTTPRequestInfo);
var
  msgEnd: Boolean;
  decoder: TIdMessageDecoder;
  tmp: string;
  dest: TStream;
  headers: ISP<TStringList>;
  boundary: string;
  ss: TStringStream;
begin
  msgEnd := False;
  decoder := TIdMessageDecoderMIME.Create(nil);
  try
    headers := TSP<TStringList>.Create();
    ExtractHeaderFields([';'], [' '], PChar(ARequestInfo.ContentType), headers, false, false);
    boundary := headers.Values['boundary'];
    TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;  //TIdMIMEBoundary.  FindBoundary(Header);

    decoder.SourceStream := ARequestInfo.PostStream;
    decoder.FreeSourceStream := False;
    decoder.ReadLn;

    repeat
      decoder.ReadHeader;
      //decoder.ReadLn;
      case decoder.PartType of
      //mcptUnknown:
      //    raise Exception('Unknown form data detected');
        mcptText:
          begin
            tmp := decoder.Headers.Values['Content-Type'];
            ss := TStringStream.Create();
            try
              decoder := decoder.ReadBody(ss, msgEnd);

                            {
              if AnsiSameText(Fetch(tmp, ';'), 'multipart/mixed') then
                DecodeFormData(ARequestInfo,tmp, dest)
              else
              }
                // use Dest as needed...
              begin


                //  ss.Free();
              end;
            finally
              FreeAndNil(ss);
            end;
          end;
        mcptAttachment:
          begin
            tmp := ExtractFileName(decoder.FileName);
            if tmp <> '' then
              tmp := ExtractFileDir(Application.ExeName) + '\files\' + tmp; //'c:\some folder\" + Tmp';
            //else
            //Tmp := MakeTempFilename("c:\somefolder\");
            dest := TFileStream.Create(tmp, fmCreate);
            try
              decoder := decoder.ReadBody(dest, msgEnd);
            finally
              FreeAndNil(dest);
            end;
          end;
      end;
    until (decoder = nil) or msgEnd;
  finally
    FreeAndNil(decoder);
  end;
end;


    { // example of use...
    begin

        S := ARequestInfo.Headers.Values['Content-Type'];
        if AnsiSameText(Fetch(S, ';'), 'multipart/form-data') then
            DecodeFormData(S, ARequestInfo.PostStream)
        else
            // use request data as needed...

    end;
    }

{ TSP }

constructor TSP<T>.Create;
begin
  inherited Create;
  FValue := T.Create;
end;

constructor TSP<T>.Create(AValue: T);
begin
  inherited Create;
  FValue := AValue;
end;

destructor TSP<T>.Destroy;
begin
  FValue.Free;
  inherited;
end;

function TSP<T>.Invoke: T;
begin
  Result := FValue;
end;

procedure TSP<T>.SetValue(const Value: T);
begin
  FValue := Value;
end;

function TSP<T>.Extract: T;
begin
  Result := FValue;
  FValue := nil;
end;

{ TResponses }

constructor TResponses.Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  FAResponseInfo := aResponseInfo;
  FARequestInfo := aRequestInfo;
end;

procedure TResponses.Error(EMessage: string = ''; ACodeNumber: integer = -1);
var
  json: ISuperObject;
begin
  json := SO;
  json.S['answer'] := 'not ok';
  json.S['errorCode'] := ACodeNumber.ToString();
  json.S['errorMessage'] := EMessage;
  json.S['uri'] := aRequestInfo.URI;
  json.S['responseNo'] := AResponseInfo.ResponseNo.ToString();
  FaResponseInfo.ResponseNo := 200;
  FaResponseInfo.ContentType := 'application/json';
  FaResponseInfo.CacheControl := 'no-cache';
  FaResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
  FaResponseInfo.ContentText := json.AsJSon(false, false);
  FaResponseInfo.WriteContent;
end;

function TResponses.GetCommandType: string;
begin
  if (aRequestInfo.CommandType = hcGet) then
    Result := 'GET'
  else if (aRequestInfo.CommandType = hcPOST) then
    Result := 'POST'
  else
    Result := 'Other';
end;

procedure TResponses.OK();
var
  json: ISuperObject;
begin
  json := SO;
  json.S['answer'] := 'ok';
  json.S['uri'] := aRequestInfo.URI;
  json.S['responseNo'] := AResponseInfo.ResponseNo.ToString();
  FaResponseInfo.ResponseNo := 200;
  FaResponseInfo.ContentType := 'application/json';
  FaResponseInfo.CacheControl := 'no-cache';
  FaResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
  FaResponseInfo.ContentText := json.AsJSon(false, false);
  FaResponseInfo.WriteContent;
end;

procedure TResponses.ResponseOkWithJson(aJsonData: string);
var
  json,jsonResult: ISuperobject;
begin
  json :=SO(aJsonData);
  jsonResult := SO();
  jsonResult.S['answer'] := 'ok';
  jsonResult.S['uri'] := aRequestInfo.URI;
  jsonResult.S['responseNo'] := AResponseInfo.ResponseNo.ToString();
  jsonResult.O['data'] := json;
  jsonresult.S['commandType'] := GetCommandType();

  FAResponseInfo.ResponseNo := 200;
  FAResponseInfo.ContentType := 'application/json';
  FAResponseInfo.CacheControl := 'no-cache';
  FAResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
  FAResponseInfo.ContentText := jsonResult.AsJSon(false, false); // toString;
  FAResponseInfo.WriteContent;
end;

procedure TResponses.ResponseSuccessfullInsert(aId: integer);
begin

end;


end.

