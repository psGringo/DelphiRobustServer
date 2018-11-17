unit uCommandGet;

interface

uses
  System.SysUtils, System.Classes, IdContext, IdCustomHTTPServer, System.Generics.Collections,
  superobject;

type
  TCommandGet = class(TComponent)
  public
  procedure Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  end;

implementation

{ TCommandGet }

procedure TCommandGet.Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  json: ISuperObject;
begin
  if ARequestInfo.URI = '/testConnection' then
  begin
    json := SO;
    json.S['answer'] := 'ok';
    json.AsJSon(false, false);
    AResponseInfo.CacheControl := 'no-cache';
    AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
    AResponseInfo.ContentText := json.AsJSon(false,false);
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.WriteContent;
  end
  else
      AResponseInfo.ResponseNo := 404;
end;

end.

