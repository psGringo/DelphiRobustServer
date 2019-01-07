unit uRP;
{< Request processing base class, derive from this all your logical classes}

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB,
  System.Generics.Collections, System.Rtti, IdContext, uAttributes, System.Json, System.IOUtils;

type
  TProcedure = reference to procedure;

  TRP = class
  private
    FContext: TIdContext;
    FResponseInfo: TIdHTTPResponseInfo;
    FRequestInfo: TIdHTTPRequestInfo;
    FDB: ISP<TDB>;
    FRelWebFileDir: string;
    //function RttiMethodInvokeEx(const MethodName: string; RttiType: TRttiType; Instance: TValue; const Args: array of TValue): TValue; // for overloaded methods
  protected
    FClassAlias: string;
    FParams: ISP<TStringList>; // << params collected in one place for GET, POST Request
    FResponses: ISP<TResponses>;
  public
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; virtual;
    constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; NoExecute: Boolean); overload; virtual;
    procedure Create(); overload; virtual;
    procedure Delete(); virtual;
    procedure Update(); virtual;
    procedure GetInfo(); virtual;
    procedure CreateAPI();
    procedure Execute(aClassAlias: string);
    property Context: TIdContext read FContext;
    property RequestInfo: TIdHTTPRequestInfo read FRequestInfo write FRequestInfo;
    property ResponseInfo: TIdHTTPResponseInfo read FResponseInfo write FResponseInfo;
    property DB: ISP<TDB> read FDB;
    property Responses: ISP<TResponses> read FResponses;
    property Params: ISP<TStringList> read FParams;
    property RelWebFileDir: string read FRelWebFileDir write FRelWebFileDir;
  end;

implementation

uses
  System.TypInfo, uDecodePostRequest, uRPTests;

{ TRP }
procedure TRP.Create;
begin
    // insert your code here...
  FResponses.OK();
end;

procedure TRP.CreateAPI;

var
  ctx: TRttiContext;
  t: TRttiType;
  m: TRttiMethod;
  classes, api: ISP<TStringList>;
  i,j: integer;
  methodParams: TArray<System.Rtti.TRttiParameter>;
  fileName: string;
  rpTests: TRPTests;
  attribs: TArray<TCustomAttribute>;
  a: TCustomAttribute;
  methodName: string;
begin
 // to do...
  fileName := 'api.txt';

  if TFile.Exists(fileName) then
    TFile.Delete(fileName);

 api := TSP<TStringList>.Create();
 api.Add('Below API methods and params of TRPTests class');
 api.Add('---');
 api.Add('');

  ctx := TRttiContext.Create();
  try
    t := ctx.GetType(TRPTests);
//      if t.InheritsFrom(TRP) then
      begin
        for m in t.GetMethods do
        begin
          if (m.Visibility = mvPublic)
          and (m.MethodKind <> mkConstructor) and (m.MethodKind <> mkDestructor)
          and ( (m.MethodKind = mkFunction) or  (m.MethodKind = mkProcedure) )
          and   (m.Name <> 'CPP_ABI_3')
                and (m.Name <> 'CPP_ABI_2')
                and (m.Name <> 'CPP_ABI_1')
                and (m.Name <> 'FreeInstance')
                and (m.Name <> 'DefaultHandler')
                and (m.Name <> 'Dispatch')
                and (m.Name <> 'BeforeDestruction')
                and (m.Name <> 'AfterConstruction')
                and (m.Name <> 'SafeCallException')
                and (m.Name <> 'ToString')
                and (m.Name <> 'GetHashCode')
                and (m.Name <> 'GetInterface')
                and (m.Name <> 'FieldAddress')
                and (m.Name <> 'ClassType')
                and (m.Name <> 'CleanupInstance')
                and (m.Name <> 'DisposeOf')
                and (m.Name <> 'Connection')
                and (m.Name <> 'CreateAPI')
                and (m.Name <> 'Execute')
                and (m.Name <> 'Equals')
                and (m.Name <> 'Free')
          then
        begin
          methodName := m.Name;

          attribs := m.GetAttributes;
          if Length(attribs) > 0 then
          begin
            for a in m.GetAttributes() do
            begin
              // if attribs HttpGet or HttpPost
              if (THTTPAttributes(a).CommandType = 'HttpGet') or (THTTPAttributes(a).CommandType = 'HttpPost') then
              begin
                if (THTTPAttributes(a).CommandType = 'HttpGet') then
                  methodName := methodName + ' | GET'
                else if (THTTPAttributes(a).CommandType = 'HttpPost') then
                  methodName := methodName + ' | POST'
              end;
            end;
          end
          else
            methodName := methodName + ' | GET';

          api.Add(methodName);

            methodParams := m.GetParameters();
            if (Length(methodParams) > 0 ) then
            begin
            for j := 0 to high(methodParams) do
              api.Add(methodParams[j].ToString);
            end;
            api.Add('');
          end;
        end;
      end;
    api.SaveToFile(fileName);
  finally
    ctx.Free;
  end;
end;

constructor TRP.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
var
  c: ISP<TCommon>;
  d: ISP<TDecodePostRequest>;
begin
  c := TSP<TCommon>.Create();
  c.IsNotNull(aContext);
  c.IsNotNull(aResponseInfo);
  c.IsNotNull(aRequestInfo);

  FResponses := TSP<TResponses>.Create(TResponses.Create(aRequestInfo, aResponseInfo));
  FContext := aContext;
  FResponseInfo := aResponseInfo;
  FRequestInfo := aRequestInfo;
  FDB := TSP<TDB>.Create();
  FClassAlias := '';
  FParams := TSP<TStringList>.Create();
  //reading params
  case aRequestInfo.CommandType of
    hcGET:
      FParams.Assign(aRequestInfo.Params);
    hcPOST:
      begin
        d := TSP<TDecodePostRequest>.Create();
        d.Execute(aContext, aRequestInfo, aResponseInfo);
        FParams.Text := d.Params.Text;
        FRelWebFileDir := d.RelWebFileDir;
    // might me continued with PUT, DELETE and other request types...
      end;
  end;
end;

constructor TRP.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; NoExecute: Boolean);
begin
  FResponses := TSP<TResponses>.Create(TResponses.Create(aRequestInfo, aResponseInfo));
  FRequestInfo := aRequestInfo;
  FResponseInfo := aResponseInfo;
  FContext := aContext;
end;

procedure TRP.Delete;
begin
  // insert your code here...
  FResponses.OK();
end;

procedure TRP.Execute(aClassAlias: string);
var
  ctx: TRttiContext;
  t: TRttiType;
  m: TRttiMethod;
  classAlias: TRttiField;
  classAliasValue: TValue;
  className: string;
  args: array of TValue;
  attribs: TArray<TCustomAttribute>;
  a: TCustomAttribute;
  methodParams: TArray<System.Rtti.TRttiParameter>;

  procedure CollectArgs();
  var
    i: int;
  begin
    SetLength(args, 0);
//    SetLength(args, Length(args) + 1);
//    args[0] := Self;
    for i := 0 to FParams.Count - 1 do
    begin
      SetLength(args, Length(args) + 1);
      args[i] := FParams.Values[FParams.Names[i]];
    end;
  end;

begin
  FClassAlias := aClassAlias;
  CollectArgs();
  ctx := TRttiContext.Create();
  try
    t := ctx.GetType(Self.ClassType);
    classAlias := t.GetField('FClassAlias');
    // looking for className
    classAliasValue := classAlias.GetValue(Self);
    if (classAliasValue.AsString) <> '' then
      className := classAliasValue.AsString
    else
      className := Self.ClassName;

    for m in t.GetMethods do
      if (m.MethodKind <> mkConstructor) and (m.MethodKind <> mkDestructor) and (FRequestInfo.URI = '/' + className + '/' + m.Name) then
      begin
        if (Pos('application/json', LowerCase(RequestInfo.ContentType)) > 0)
        or (
            (Pos('multipart/form-data', LowerCase(FRequestInfo.ContentType)) > 0)
            and (Pos('boundary', LowerCase(FRequestInfo.ContentType)) > 0)
            and (FRequestInfo.URI = '/Files/Upload')
           )
        then
        begin
          // do nothing, pass Fparams.Text which is json here, to invoked method
          SetLength(args, 0);
          m.Invoke(Self, args);
        end
        else
        begin
          methodParams := m.GetParameters;
          if Length(args) <> Length(methodParams) then
            Continue;

          attribs := m.GetAttributes;
          if Length(attribs) > 0 then
          begin
            for a in m.GetAttributes() do
            begin
              // if attribs HttpGet or HttpPost
              if (THTTPAttributes(a).CommandType = 'HttpGet') or (THTTPAttributes(a).CommandType = 'HttpPost') then
              begin
                if (THTTPAttributes(a).CommandType = 'HttpGet') and (FRequestInfo.CommandType = hcGET) then
                  m.Invoke(Self, args)

                else if (THTTPAttributes(a).CommandType = 'HttpPost') and (FRequestInfo.CommandType = hcPOST) then
                  m.Invoke(Self, args)
              end;
            end
          end
          else
            m.Invoke(Self, args);
        end;
        break;
      end;
      FResponseInfo.ResponseNo := 404;
  finally
    ctx.Free();
  end;
end;

procedure TRP.GetInfo;
begin

  // insert your code here...
  FResponses.OK();
end;

procedure TRP.Update;
begin
  // insert your code here...
  FResponses.OK();
end;
{ for overloaded methods
function TRP.RttiMethodInvokeEx(const MethodName:string; RttiType : TRttiType; Instance: TValue; const Args: array of TValue): TValue;
var
 Found   : Boolean;
 LMethod : TRttiMethod;
 LIndex  : Integer;
 LParams : TArray<TRttiParameter>;
begin
  Result:=nil;
  LMethod:=nil;
  Found:=False;
  for LMethod in RttiType.GetMethods do
   if SameText(LMethod.Name, MethodName) then
   begin
     LParams:=LMethod.GetParameters;
     if Length(Args)=Length(LParams) then
     begin
       Found:=True;
       for LIndex:=0 to Length(LParams)-1 do
       if LParams[LIndex].ParamType.Handle<>Args[LIndex].TypeInfo then
       begin
         Found:=False;
         Break;
       end;
     end;

     if Found then Break;
   end;

   if (LMethod<>nil) and Found then
     Result:=LMethod.Invoke(Instance, Args)
   else
     raise Exception.CreateFmt('method %s not found',[MethodName]);
end;
}
end.

