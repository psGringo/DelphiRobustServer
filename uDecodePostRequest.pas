unit uDecodePostRequest;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, Vcl.StdCtrls, HTTPApp, IdMultipartFormData,
  IdContext, System.IOUtils, System.NetEncoding, superobject, Contnrs, uCommon,
  System.Generics.Collections, DateUtils, uUniqueName;

type
  TPostParam = record
    Name: string;
    Value: string;
  end;

type
  TDecodePostRequest = class
  private
    FRelWebFileDir: string;
    FPostParams: ISP<TList<TPostParam>>;
    FJson: string;
    //procedure ParseJson(const aAsObject: TSuperTableString); // uncomment if needed
    function ReadMultipartRequest(const aBoundary: string; aRequest: string; aHeader: ISP<TStringList>; var aData: string): string;
    procedure SetRelWebFileDir(const Value: string);
  public
    constructor Create();
    procedure Multipart(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormURLEncoded(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    property RelWebFileDir: string read FRelWebFileDir write SetRelWebFileDir;
    property PostParams: ISP<TList<TPostParam>> read FPostParams;
    property Json: string read FJson;
  end;

const
  MaxReadBlockSize = 8192;

implementation

uses
  System.StrUtils;

procedure TDecodePostRequest.Execute(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  ss: ISP<TStringStream>;
begin
  AResponseInfo.Server := 'ver1';
  AResponseInfo.CacheControl := 'no-cache';

  if (Pos('multipart/form-data', LowerCase(ARequestInfo.ContentType)) > 0) and     // ����� ��� ��������� multipart
    (Pos('boundary', LowerCase(ARequestInfo.ContentType)) > 0) then
    Multipart(AContext, ARequestInfo, AResponseInfo)

  else if (Pos('application/x-www-form-urlencoded', LowerCase(ARequestInfo.ContentType)) > 0) then
    FormURLEncoded(AContext, ARequestInfo, AResponseInfo)

  else if (Pos('application/json', LowerCase(ARequestInfo.ContentType)) > 0) then
  begin
    ss := TSP<TStringStream>.Create();
    ss.LoadFromStream(ARequestInfo.PostStream);
    FJson := ss.DataString;
    // parse json... if needed or parse in other place
    //obj := SO(TNetEncoding.URL.Decode(allContent));
    //ParseJson(obj.AsObject, aPostParams);
  end;
end;

procedure TDecodePostRequest.FormURLEncoded(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  postParam: TPostParam;
  i: Integer;
begin
  for i := 0 to ARequestInfo.Params.Count - 1 do
  begin
    postParam.Name := System.NetEncoding.TNetEncoding.URL.Decode(ARequestInfo.Params.Names[i]);
    postParam.Value := System.NetEncoding.TNetEncoding.URL.Decode(ARequestInfo.Params.Values[ARequestInfo.Params.Names[i]]);
    FPostParams.Add(postParam);
  end;
end;
{
procedure TDecodePostRequest.ParseJson(const aAsObject: TSuperTableString);
//https://stackoverflow.com/questions/14082886/superobject-extract-all
var
  Names: ISuperObject;
  Name: string;
  Items: ISuperObject;
  Item: ISuperObject;
  idx: Integer;
  Value: string;
begin
  if Assigned(aAsObject) then
  begin
    Names := aAsObject.GetNames;
    Items := aAsObject.GetValues;

    for idx := 0 to Items.AsArray.Length - 1 do
    begin
      Name := Names.AsArray[idx].AsString;
      Item := Items.AsArray[idx];
      if Item.DataType = stObject then
        Value := '<Object>'
      else if Item.DataType = stArray then
        Value := '<Array>'
      else
        Value := Item.AsString;

       // do smth with json

      //postParams.Add(Name + '=' + Value);
     // postParams.json := Value; // returning only json object

      //if SameText(Name, 'id') then
       // WriteLn(Format('%s: %s', [aPrefix + Name, Value]));


 //      if Item.DataType = stArray then
//        for ArrayItem in Item do
//          ProcessObject(ArrayItem.AsObject, aPrefix + Name + '.');

//      if Item.DataType = stObject then
//        ProcessObject(Item.AsObject, aPrefix + Name + '.');

    end;
  end;
end;
}
//-------------------------------------------------

function TDecodePostRequest.ReadMultipartRequest(const aBoundary: string; aRequest: string; aHeader: ISP<TStringList>; var aData: string): string;
var
  Req, RHead: string;
  i: Integer;
begin
  Result := '';
  aHeader.Clear;
  aData := '';

  if (Pos(aBoundary, aRequest) < Pos(aBoundary + '--', aRequest)) and (Pos(aBoundary, aRequest) = 1) then
  begin
    Delete(aRequest, 1, Length(aBoundary) + 2);
    Req := Copy(aRequest, 1, Pos(aBoundary, aRequest) - 3);
    Delete(aRequest, 1, Length(Req) + 2);
    RHead := Copy(Req, 1, Pos(#13#10#13#10, Req) - 1);

    Delete(Req, 1, Length(RHead) + 4);
    aHeader.Text := RHead;
    for i := 0 to aHeader.Count - 1 do
      if Pos(':', aHeader.Strings[i]) > 0 then
        aHeader.Strings[i] := Trim(Copy(aHeader.Strings[i], 1, Pos(':', aHeader.Strings[i]) - 1)) + '=' + Trim(Copy(aHeader.Strings[i], Pos(':', aHeader.Strings[i]) + 1, Length(aHeader.Strings[i]) - Pos(':', aHeader.Strings[i])));
    aData := Req;
    Result := aRequest;
  end
end;

procedure TDecodePostRequest.SetRelWebFileDir(const Value: string);
begin
  FRelWebFileDir := Value;
end;

procedure TDecodePostRequest.Multipart(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);

  function ValueByName(aName: string): string;
  var
    i: Integer;
  begin
    Result := '';
    for i := 0 to FPostParams.Count - 1 do
      if FPostParams[i].Name = aName then
      begin
        result := FPostParams[i].Value;
        Break;
      end;
  end;

  function GetPostParam(aParamName: string): string;
  var
    value: string;
  begin
    value := ValueByName(aParamName);
    Result := IfThen(aParamName <> '', value, '');
  end;

const
  MaxReadBlockSize = 8192;
var
  ms: ISP<TMemoryStream>;
  fs: ISP<TFileStream>;
  boundary, bufferStr, allContent: string;
  header: ISP<TStringList>;
  byteToRead, readedBytes, rSize: Integer;
  buffer: PAnsiChar;
  data: string;
  hList: ISP<TStringList>;
  filename: string;
  dir: string;
  isOverwrite: string;
  postParam: TPostParam;
  uploadDir: string;
  un: ISP<TUniqueName>;

  procedure ProcessUploadDir();
  begin
    uploadDir := ExtractFilePath(Application.ExeName) + 'files\' + //
      YearOf(Now).ToString() + '\' + //
      MonthOf(Now).ToString() + '\' +  //
      DayOf(Now).ToString(); //

    if (not TDirectory.Exists(uploadDir)) then
      TDirectory.CreateDirectory(uploadDir);
  end;

begin
  AResponseInfo.Server := 'ver1';
  AResponseInfo.CacheControl := 'no-cache';

 // if (Pos('multipart/form-data', LowerCase(ARequestInfo.ContentType)) > 0) and
  if (Pos('boundary', LowerCase(ARequestInfo.ContentType)) > 0) then
  begin
    header := TSP<TStringList>.Create();
    ExtractHeaderFields([';'], [' '], PChar(ARequestInfo.ContentType), header, False, False);
    boundary := header.Values['boundary'];

   // reading from postStream to allContent
    ms := TSP<TMemoryStream>.Create();
    ms.LoadFromStream(ARequestInfo.PostStream);
    allContent := '';
    byteToRead := ARequestInfo.ContentLength;
    while byteToRead > 0 do
    begin
      rSize := MaxReadBlockSize;
      if rSize > byteToRead then
        rSize := byteToRead;
      GetMem(buffer, rSize);
      try
        readedBytes := ms.Read(buffer^, rSize);
        SetString(bufferStr, buffer, readedBytes);
        allContent := allContent + bufferStr;
      finally
        FreeMem(buffer, rSize);
      end;
      byteToRead := ARequestInfo.ContentLength - Length(allContent);
    end;

    // reading post blocks (params) from allContent to FPostParams
    hList := TSP<TStringList>.Create();
    if ARequestInfo.ContentLength = Length(allContent) then
      while Length(allContent) > Length('--' + boundary + '--' + #13#10) do
      begin
        header.Clear();
        hList.Clear();

        allContent := ReadMultipartRequest('--' + boundary, allContent, header, data);
        ExtractHeaderFields([';'], [' '], PChar(header.Values['Content-Disposition']), hList, False, True);

        postParam.Name := System.NetEncoding.TNetEncoding.URL.Decode(hList.Values['name']);
        postParam.Value := System.NetEncoding.TNetEncoding.URL.Decode(data);
        FPostParams.Add(postParam);
      end;

     // reading params
    filename := GetPostParam('filename');
    dir := GetPostParam('dir');
    isOverwrite := GetPostParam('isOverwrite');
    data := GetPostParam('attach');

    // writing file
    if (filename <> '') and (data <> '') then
    begin
      ProcessUploadDir();

      if isOverwrite <> 'true' then
      begin
        un := TSP<TUniqueName>.Create();
        filename := un.CreateUniqueNameAddingNumber(uploadDir, filename);
      end;


      fs := TSP<TFileStream>.Create(TFileStream.Create(uploadDir + '\' + filename, fmCreate));
      try
        fs.WriteBuffer(Pointer(data)^, Length(data));
      except
        on E: EStreamError do
          raise Exception.Create('EStreamError EClassName' + E.ClassName + ' ' + 'EMessage ' + E.Message);
        on E: Exception do
          raise Exception.Create('EClassName' + E.ClassName + ' ' + 'EMessage ' + E.Message);
      end;
    end;
  end;
end;

constructor TDecodePostRequest.Create();
begin
  FPostParams := TSP<TList<TPostParam>>.Create();
  ;
end;

{ TPostParams }
end.

