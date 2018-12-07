{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N-,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN SYMBOL_EXPERIMENTAL ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN UNIT_EXPERIMENTAL ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_CAST OFF}
{$WARN OPTION_TRUNCATED ON}
{$WARN WIDECHAR_REDUCED ON}
{$WARN DUPLICATES_IGNORED ON}
{$WARN UNIT_INIT_SEQ ON}
{$WARN LOCAL_PINVOKE ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN TYPEINFO_IMPLICITLY_ADDED ON}
{$WARN RLINK_WARNING ON}
{$WARN IMPLICIT_STRING_CAST ON}
{$WARN IMPLICIT_STRING_CAST_LOSS ON}
{$WARN EXPLICIT_STRING_CAST OFF}
{$WARN EXPLICIT_STRING_CAST_LOSS OFF}
{$WARN CVT_WCHAR_TO_ACHAR ON}
{$WARN CVT_NARROWING_STRING_LOST ON}
{$WARN CVT_ACHAR_TO_WCHAR ON}
{$WARN CVT_WIDENING_STRING_LOST ON}
{$WARN NON_PORTABLE_TYPECAST ON}
{$WARN XML_WHITESPACE_NOT_ALLOWED ON}
{$WARN XML_UNKNOWN_ENTITY ON}
{$WARN XML_INVALID_NAME_START ON}
{$WARN XML_INVALID_NAME ON}
{$WARN XML_EXPECTED_CHARACTER ON}
{$WARN XML_CREF_NO_RESOLVE ON}
{$WARN XML_NO_PARM ON}
{$WARN XML_NO_MATCHING_PARM ON}
{$WARN IMMUTABLE_STRINGS OFF}
unit uCommandGet;

interface

uses
  System.Classes, IdContext, IdCustomHTTPServer, System.Generics.Collections,
  superobject, System.NetEncoding, System.IOUtils, Vcl.Forms, uUniqueName, uDB, uCommon;

type
  TCommandGet = class(TComponent)
  private
    FContext: TIdContext;
    FRequestInfo: TIdHTTPRequestInfo;
    FResponseInfo: TIdHTTPResponseInfo;
    function ParseFirstSection(aValue: string): Boolean;
    procedure ProcessFiles(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure ProcessTests(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure Execute();
    property Context: TIdContext read FContext write FContext;
    property RequestInfo: TIdHTTPRequestInfo read FRequestInfo write FRequestInfo;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo write FResponseInfo;
  end;

implementation

uses
  uRPUsers, uDecodePostRequest, System.SysUtils,
  DateUtils, uConst;

{ TCommandGet }
constructor TCommandGet.Create(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  FContext := AContext;
  FRequestInfo := ARequestInfo;
  FResponseInfo := AResponseInfo;
  Execute();
end;

procedure TCommandGet.Execute();
var
  r: ISP<TResponses>;
  u: ISP<TRPUsers>;
begin
  r := TSP<TResponses>.Create(TResponses.Create(FRequestInfo, FResponseInfo));
  try
    if (ParseFirstSection('Users')) then
      u := TSP<TRPUsers>.Create(TRPUsers.Create(FRequestInfo, FResponseInfo))
    {
    if (ParseFirstSection('SmthOther')) then
      u := TSP<TRPSmthOther>.Create(TRPSmthOther.Create(FRequestInfo, FResponseInfo))
    }
    else
      FResponseInfo.ResponseNo := 404;
  except
    on E: Exception do
      r.Error(e.Message);
  end;
end;


function TCommandGet.ParseFirstSection(aValue: string): Boolean;
var
  a: TArray<string>;
begin
  a := FRequestInfo.URI.Split(['/']);
  if Length(a) > 0 then
    Result := a[1].Equals(aValue); // Parses Users from /Users/Add for example....
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
  d: ISP<TDecodePostRequest>;
  fileName: string;
  relUploadDir: string;
  relWebFilePath: string;
  r: ISP<TResponses>;
  json: ISuperobject;
  uri: string;
begin
  {
  uri := ARequestInfo.URI;
  if ParseFirstSection(uri) = 'Files' then
    if (uri = '/Files/Send') then
    begin
      d := TSP<TDecodePostRequest>.Create();
      d.Execute(AContext, ARequestInfo, AResponseInfo);
      relWebFilePath := StringReplace(relUploadDir, '\', '/', [rfReplaceAll]) + '/' + fileName;
      json := SO;
      json.S['relWebFilePath'] := relWebFilePath;
      r := TSP<TResponses>.Create(TResponses.Create(ARequestInfo, AResponseInfo));
      r.OkWithJson(json.AsJSon(false, false)); // return relative webpath
    end;
   }
end;

procedure TCommandGet.ProcessTests(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  r: ISP<TResponses>;
  uri: string;
  d: ISP<TDecodePostRequest>;
  jo: ISuperobject;
begin
  uri := ARequestInfo.URI;
  r := TSP<TResponses>.Create(TResponses.Create(ARequestInfo, AResponseInfo));
  if uri = '/Test/Connection' then
    r.OK()
  else if uri = '/Test/Exception' then
   raise Exception.Create('Test Error Message')
  else if uri = '/Test/Request' then
  begin
    if ARequestInfo.CommandType = hcGET then
    begin
      // parse params like
      // id:=ARequestInfo.Params['id']
    end
    else if ((ARequestInfo.CommandType = hcPOST) and (Pos('application/json', LowerCase(ARequestInfo.ContentType)) > 0)) then
    begin
      d := TSP<TDecodePostRequest>.Create();
      d.Execute(AContext, ARequestInfo, AResponseInfo);
      jo := SO[d.Json];
      r.OkWithJson(jo.AsJSon(false, false));
    end;
  end
  else if uri = '/Test/URLEncoded' then
  begin
    d := TSP<TDecodePostRequest>.Create();
    d.Execute(AContext, ARequestInfo, AResponseInfo);
    r := TSP<TResponses>.Create(TResponses.Create(ARequestInfo, AResponseInfo));
    r.OK();
  end
   else if uri = '/Test/Sessions' then
   begin
    jo := SO();
    jo.S['sessionID'] := ARequestInfo.Session.SessionID;
    r.OkWithJson(jo.AsJSon(false, false));
   end;
end;

end.

