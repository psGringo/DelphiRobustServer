unit uResponses;

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject;

type
  IResponses = interface
    ['{CF59B6D2-D745-469D-8E16-E8EC501A6024}']
    procedure OK();
    procedure Error(EMessage: string = ''; ACodeNumber: integer = -1);
    procedure ResponseOkWithJson(aJsonData: string);
    procedure ResponseSuccessfullInsert(aId: integer);
  end;

  TResponses = class(TInterfacedObject, IResponses)
  private
    FAResponseInfo: TIdHTTPResponseInfo;
    FARequestInfo: TIdHTTPRequestInfo;
    procedure SetARequestInfo(const Value: TIdHTTPRequestInfo);
    procedure SetAResponseInfo(const Value: TIdHTTPResponseInfo);
  published
    constructor Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
    procedure OK();
    procedure Error(EMessage: string = ''; ACodeNumber: integer = -1);
    procedure ResponseOkWithJson(aJsonData: string);
    procedure ResponseSuccessfullInsert(aId: integer);
    property ARequestInfo: TIdHTTPRequestInfo read FARequestInfo write SetARequestInfo;
    property AResponseInfo: TIdHTTPResponseInfo read FAResponseInfo write SetAResponseInfo;
  end;

implementation

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
  json.S['uri'] := aRequestInfo.URI;
  json.S['responseNo'] := AResponseInfo.ResponseNo.ToString();
  jsonResult.O['data'] := json;

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

procedure TResponses.SetARequestInfo(const Value: TIdHTTPRequestInfo);
begin
  FARequestInfo := Value;
end;

procedure TResponses.SetAResponseInfo(const Value: TIdHTTPResponseInfo);
begin
  FAResponseInfo := Value;
end;

end.

