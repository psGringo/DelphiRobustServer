unit uCommandGet;

interface

uses
  System.SysUtils, System.Classes, IdContext, IdCustomHTTPServer, System.Generics.Collections,
  superobject;

type
  TCommandGet = class(TComponent)
  private
    function GetFirstURISection(aURI: string): string;
    procedure ProcessTests(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcessUsers(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  end;

implementation

uses
  uResponses, uSmartPointer, uRPUsers;

  { TCommandGet }
procedure TCommandGet.Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  json: ISuperObject;
  uri: string;
  r: IResponses;
begin
  r := TResponses.Create(ARequestInfo, AResponseInfo);
  try
    uri := ARequestInfo.URI;
    ProcessTests(ARequestInfo, AResponseInfo);
    ProcessUsers(ARequestInfo, AResponseInfo);
    AResponseInfo.ResponseNo := 404;
  except
    on E: Exception do
      r.Error(e.Message);
  end;
end;

procedure TCommandGet.ProcessUsers(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  u: IRPUsers;
  uri: string;
begin
  uri := ARequestInfo.URI;
  if GetFirstURISection(uri) = 'Users' then
  begin
    u := TRPUsers.Create(ARequestInfo, AResponseInfo);
    if uri = '/Users/Add' then
      u.Add
    else if uri = '/Users/Delete' then
      u.Delete
    else if uri = '/Users/Update' then
      u.Update
    else if uri = '/Users/GetInfo' then
      u.GetInfo;
  end;
end;

function TCommandGet.GetFirstURISection(aURI: string): string;
var
  a: TArray<string>;
begin
  Result := '';
  a := aURI.Split(['/']);
  if Length(a) > 0 then
    Result := a[1]; // Parses Users from /Users/Add for example....
end;

procedure TCommandGet.ProcessTests(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  r: IResponses;
  d, a, b: Double;
  uri: string;
begin
  uri := ARequestInfo.URI;
  r := TResponses.Create(ARequestInfo, AResponseInfo);
  if uri = '/Test/Connection' then
    r.OK()
  else if uri = '/Test/Exception' then
  begin
    a := 1;
    b := 0;
    d := a / b;
  end
end;

end.

