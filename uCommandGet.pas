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

uses
  uResponses;

  { TCommandGet }
procedure TCommandGet.Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  json: ISuperObject;
  r: IResponses;
  d, a, b: Double;
begin
  r := TResponses.Create(ARequestInfo, AResponseInfo);
  try
    if ARequestInfo.URI = '/testConnection' then
    r.OK()
    else if ARequestInfo.URI = '/testException' then
    begin
      a := 1;
      b := 0;
      d := a / b;
    end
    else
      AResponseInfo.ResponseNo := 404;
  except
    on E: Exception do
      r.Error(e.Message);
  end;
end;

end.

