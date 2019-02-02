unit uRPTests;

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB, uRP, IdContext, System.NetEncoding,
  uAttributes, System.JSON;

type
  TRPTests = class(TRP)
  private
    FRequest: string;
    FPort: string;
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
      overload; override;
    procedure Connection;
    procedure Exceptions;
    [THTTPAttributes('HttpPost')]
    procedure PostJson;
    procedure URLEncoded(a, b: string);
    procedure Sessions;
    procedure MethodWithParams(aParam1: string; aParam2: string);
    [THTTPAttributes('HttpGet')]
    procedure HTTPAttribute(); overload;
    [THTTPAttributes('HttpPost')]
    procedure HTTPAttribute(aParam: string); overload;
    property Port: string read FPort;
    property Request: string read FRequest;
    procedure SomeFakeJob();
  end;

implementation

uses
  idHTTP, IdMultipartFormData, uMain, Vcl.Dialogs;

{ TRPUsers }

constructor TRPTests.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  Execute('Test');
end;

procedure TRPTests.MethodWithParams(aParam1: string; aParam2: string);
var
  json: ISuperObject;
begin
  json := SO;
  json.S['param1'] := aParam1;
  json.S['param2'] := aParam2;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.Exceptions;
begin
  raise Exception.Create('Test Error Message');
end;

procedure TRPTests.HTTPAttribute(aParam: string);
var
  json: ISuperObject;
begin
  json := SO;
  json.S['commandType'] := 'POST';
  json.S['param'] := aParam;
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.HTTPAttribute;
var
  json: ISuperObject;
begin
  json := SO;
  json.S['commandType'] := 'GET';
  FResponses.OkWithJson(json.AsJSon(false, false));
end;

procedure TRPTests.PostJson;
var
  jso: ISuperobject;
  jo: TJSONObject; // ISP<> doesn't work here 'cause jo always has reference and no nil after wrong parse of json
begin
  jo := TJSONObject.ParseJSONValue(FParams.Text) as TJSONObject;
  try
    if not (Assigned(jo)) then
      raise Exception.Create('not a json object');
    jso := SO[FParams.Text];
    FResponses.OkWithJson(jso.AsJSon(false, false));
  finally
    jo.Free();
  end;
end;

procedure TRPTests.Sessions;
var
  jo: ISuperObject;
//  LSessionList: TIdHTTPDefaultSessionList;  //TIdHTTPSessionList;
  LSessionList: TIdHTTPSessionList;
begin
  jo := SO;
  jo.S['sessionID'] := RequestInfo.Session.SessionID;
  jo.S['content'] := RequestInfo.Session.Content.Text;
  jo.S['remoteHost'] := RequestInfo.Session.RemoteHost;
  jo.S['lastTimeStamp'] := DateTimeToStr(RequestInfo.Session.LastTimeStamp);

//  LSessionList := TIdHTTPDefaultSessionList(Main.Server.SessionList).LockList;
  LSessionList := TIdHTTPDefaultSessionList(Main.Server.SessionList).SessionList.LockList;
  jo.S['sessionCount'] := LSessionList.Count.ToString;
  TIdHTTPDefaultSessionList(Main.Server.SessionList).SessionList.UnlockList;
  FResponses.OkWithJson(jo.AsJSon(false, false));
end;

procedure TRPTests.SomeFakeJob;
begin
  Sleep(3000);
  FResponses.OK();
end;

procedure TRPTests.Connection;
begin
  FResponses.OK();
end;

procedure TRPTests.URLEncoded(a, b: string);
var
  jo: ISuperObject;
begin
  jo := SO;
  jo.S[FParams.Names[0]] := a;
  jo.S[FParams.Names[1]] := b;
  FResponses.OkWithJson(jo.AsJSon(false, false));
end;

end.
