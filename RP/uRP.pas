unit uRP;
{< Request processing base class, derive from this all your logical classes}

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject, uCommon, uDB,
  System.Generics.Collections,System.Rtti;

type
  TProcedure = reference to procedure;

  TRP = class
  private
    FAResponseInfo: TIdHTTPResponseInfo;
    FARequestInfo: TIdHTTPRequestInfo;
    FResponses: ISP<TResponses>;
    FDB: ISP<TDB>;
  protected
    FClassAlias: string;
  public
    constructor Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; virtual;
    procedure Create(); overload; virtual;
    procedure Delete(); virtual;
    procedure Update(); virtual;
    procedure GetInfo(); virtual;
    procedure Execute(aURI: string);
    property ARequestInfo: TIdHTTPRequestInfo read FARequestInfo write FARequestInfo;
    property AResponseInfo: TIdHTTPResponseInfo read FAResponseInfo write FAResponseInfo;
    property DB: ISP<TDB> read FDB;
    property Responses: ISP<TResponses> read FResponses;
    property ClassAlias: string read FClassAlias write FClassAlias;
  end;

implementation

uses
  System.TypInfo;

{ TRP }
procedure TRP.Create;
begin
    // insert your code here...
  FResponses.OK();
end;

constructor TRP.Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
var
  c: ISP<TCommon>;
begin
  c := TSP<TCommon>.Create();
  c.IsNotNull(aResponseInfo);
  c.IsNotNull(aRequestInfo);

  FResponses := TSP<TResponses>.Create(TResponses.Create(aRequestInfo, aResponseInfo));
  FAResponseInfo := aResponseInfo;
  FARequestInfo := aRequestInfo;
  FDB := TSP<TDB>.Create();
  FClassAlias := '';
end;

procedure TRP.Delete;
begin
  // insert your code here...
  FResponses.OK();
end;

procedure TRP.Execute(aURI: string);
var
  ctx: TRttiContext;
  t: TRttiType;
  m: TRttiMethod;
  classAlias: TRttiField;
  classAliasValue: TValue;
  className: string;
  args: array of TValue;
  s: string;
begin
  ctx := TRttiContext.Create();
  try
    t := ctx.GetType(Self.ClassType);
    SetLength(args, 0);
    classAlias := t.GetField('FClassAlias');

    // looking for className
    classAliasValue := classAlias.GetValue(Self);
    if (classAliasValue.AsString)<>'' then
    className := classAliasValue.AsString
    else className := Self.ClassName;

    for m in t.GetMethods do
      if (m.MethodKind <>  mkConstructor) and
      (m.MethodKind <>  mkDestructor) and
       (aURI = '/' + className + '/' + m.Name) then
      begin
        m.Invoke(Self, args);
        break;
      end;
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

end.

