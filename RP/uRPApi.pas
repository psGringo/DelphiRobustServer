unit uRPApi;

interface

uses
  uRP, System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB, IdContext, System.NetEncoding,
  uAttributes, System.JSON, TypInfo,System.Rtti, System.IOUtils;

type
  TRPApi = class(TRP)
  constructor Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; override;
  private
   procedure CreateAPIFromClass(aClass: TClass; aApi: TStringList);
  public
   procedure Get;
  end;

implementation

uses
  uRPTests, Vcl.Forms, uRPFiles, uRPMemory, uRPUsers;

{ TApi }

constructor TRPApi.Create(aContext: TIdContext; aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  Execute('Api');
end;

procedure TRPApi.CreateAPIFromClass(aClass: TClass; aApi: TStringList);
{
  procedure getAPIClasses(aClasses: TList<TClass>);
  var
    ctx: TRttiContext;
    types: TArray<System.Rtti.TRttiType>;
    oneOfTypes: System.Rtti.TRttiType;
  begin
    ctx := TRttiContext.Create();
    types := ctx.GetTypes();
    for oneOfTypes in types do
      if (oneOfTypes.Name.contains('TRP')) and (oneOfTypes.Name <> 'TRP') then
        aClasses.Add(oneOfTypes.ClassType.ClassInfo);
  end;
}
var
  ctx: TRttiContext;
  t: TRttiType;
  m: TRttiMethod;
  j: integer;
  methodParams: TArray<System.Rtti.TRttiParameter>;
  attribs: TArray<TCustomAttribute>;
  a: TCustomAttribute;
  methodName: string;

begin
  aApi.Add('');
  aApi.Add('---');
  aApi.Add('');

  aApi.Add(aClass.ClassName);
  aApi.Add('');
  aApi.Add('---');
  ctx := TRttiContext.Create;
  try
    t := ctx.GetType(aClass);
    begin
      for m in t.GetMethods do
      begin
        if (m.Visibility = mvPublic) //
          and (m.MethodKind <> mkConstructor) //
          and (m.MethodKind <> mkDestructor) //
          and ((m.MethodKind = mkFunction) or (m.MethodKind = mkProcedure)) and (m.Name <> 'CPP_ABI_3') //
          and (m.Name <> 'CPP_ABI_2') and (m.Name <> 'CPP_ABI_1') //
          and (m.Name <> 'FreeInstance') //
          and (m.Name <> 'DefaultHandler') //
          and (m.Name <> 'Dispatch') //
          and (m.Name <> 'BeforeDestruction') //
          and (m.Name <> 'AfterConstruction') //
          and (m.Name <> 'SafeCallException') //
          and (m.Name <> 'ToString') //
          and (m.Name <> 'GetHashCode') //
          and (m.Name <> 'GetInterface') //
          and (m.Name <> 'FieldAddress') //
          and (m.Name <> 'ClassType') //
          and (m.Name <> 'CleanupInstance') //
          and (m.Name <> 'DisposeOf') //
          and (m.Name <> 'Connection') //
          and (m.Name <> 'CreateAPI') //
          and (m.Name <> 'Execute') //
          and (m.Name <> 'Equals') //
          and (m.Name <> 'Free') //
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

          aApi.Add(methodName);

          methodParams := m.GetParameters();
          if (Length(methodParams) > 0) then
          begin
            for j := 0 to high(methodParams) do
              aApi.Add(methodParams[j].ToString);
          end;
          aApi.Add('');
        end;
      end;
    end;
  finally
    ctx.Free;
  end;
end;

procedure TRPApi.Get;
var
  fileName: string;
  api: ISP<TStringList>;
  filepath: string;
begin
  fileName := 'api.txt';

  if TFile.Exists(fileName) then
    TFile.Delete(fileName);

  api := TSP<TStringList>.Create();

  CreateAPIFromClass(TRPTests, api);
  CreateAPIFromClass(TRPFiles, api);
  CreateAPIFromClass(TRPMemory, api);
  CreateAPIFromClass(TRPUsers, api);
  // add other classes that descendants from TRP or just API classes
  // CreateAPIFromClass(TRPOtherClass, api);

  api.SaveToFile(fileName);

  filepath := ExtractFileDir(Application.ExeName) + '\'+fileName;
  if TFile.Exists(filepath) then
  begin
    ResponseInfo.SmartServeFile(Context, RequestInfo, filepath);
    FResponses.OK();
  end;
end;

end.

