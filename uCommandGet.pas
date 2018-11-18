unit uCommandGet;

interface

uses
  System.Classes, IdContext, IdCustomHTTPServer, System.Generics.Collections,
  superobject, System.NetEncoding, System.IOUtils, Vcl.Forms, uUniqueName,uDB;

type
  TCommandGet = class(TComponent)
  private
    function GetFirstURISection(aURI: string): string;
    procedure ProcessFiles(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcessTests(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcessUsers(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    procedure Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  end;

implementation

uses
  uResponses, uSmartPointer, uRPUsers, uDecodePostRequest, System.SysUtils,
  DateUtils;


{ TCommandGet }
procedure TCommandGet.Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  r: IResponses;
begin
  r := TResponses.Create(ARequestInfo, AResponseInfo);
  try
    ProcessTests(ARequestInfo, AResponseInfo);
    ProcessUsers(ARequestInfo, AResponseInfo);
    ProcessFiles(AContext, ARequestInfo, AResponseInfo);
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
  db : ISmartPointer<TDb>;
begin
  db := TSmartPointer<TDb>.Create();
  uri := ARequestInfo.URI;
  if GetFirstURISection(uri) = 'Users' then
  begin
    u := TRPUsers.Create(ARequestInfo, AResponseInfo, db);
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

procedure TCommandGet.ProcessFiles(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

  function processRelUploadDir(): string;
  var
    absPath: string;
  begin
    Result := 'files\' + YearOf(Now).ToString() + '\' + MonthOf(Now()).ToString() + '\' + DayOf(Now).ToString(); //
    absPath := ExtractFilePath(Application.ExeName) + Result;
    if not TDirectory.Exists(absPath) then
      TDirectory.CreateDirectory(absPath);
  end;

var
  d: ISmartPointer<TDecodePostRequest>;
  postParamsSmart: ISmartPointer<TStringList>;
  postParams: TStringList;
  uN : ISmartPointer<TUniqueName>;
  fileName: string;
  relUploadDir: string;
  relWebFilePath: string;
  r: IResponses;
  json: ISuperobject;
  uri: string;
  isUniqueName: string;
begin
  uri := ARequestInfo.URI;
  if GetFirstURISection(uri) = 'Files' then
    if (uri = '/Files/Send') then
    begin
  // init
      d := TSmartPointer<TDecodePostRequest>.Create();
      postParamsSmart := TSmartPointer<TStringList>.Create();
      postParams := postParamsSmart; // hack for next string
      r := TResponses.Create(ARequestInfo, AResponseInfo);
  // work
      relUploadDir := processRelUploadDir();
      d.DecodePostParamsAnsi(AContext, ARequestInfo, AResponseInfo, postParams);
      fileName := TNetEncoding.URL.Decode(postParams.Values['filename']);
      isUniqueName := TNetEncoding.URL.Decode(postParams.Values['isUniqueName']);
      if (isUniqueName = 'true') then
      begin
      uN := TSmartPointer<TUniqueName>.Create();
      fileName := uN.CreateUniqueNameAddingNumber(relUploadDir, fileName);
      end;
      d.ReceiveFile(AContext, ARequestInfo, AResponseInfo, relUploadDir, fileName);
      relWebFilePath := StringReplace(relUploadDir, '\', '/', [rfReplaceAll]) + '/' + fileName;
      json := SO;
      json.S['relWebFilePath'] := relWebFilePath;
      r.ResponseOkWithJson(json.AsJSon(false, false)); // return relative webpath
    end;
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

