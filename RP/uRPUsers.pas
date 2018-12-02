unit uRPUsers;
{< Request processing users}

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject,
  uCommon, uDB;

type
  TRPUsers = class(TInterfacedObject)
  private
    FAResponseInfo: TIdHTTPResponseInfo;
    FARequestInfo: TIdHTTPRequestInfo;
    FResponses: ISP<TResponses>;
    FDB: TDB;
  public
    constructor Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; aDB: TDB);
    procedure Add();
    procedure Delete();
    procedure Update();
    procedure GetInfo();
    property ARequestInfo: TIdHTTPRequestInfo read FARequestInfo write FARequestInfo;
    property AResponseInfo: TIdHTTPResponseInfo read FAResponseInfo write FAResponseInfo;
    property DB: TDB read FDB write FDB;
  end;

implementation

{ TRPUsers }

procedure TRPUsers.Add;
begin
    // insert your code here...
  FResponses.OK();
end;

constructor TRPUsers.Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo; aDB: TDB);
begin
  FResponses := TSP<TResponses>.Create(TResponses.Create(ARequestInfo, AResponseInfo));
  FAResponseInfo := aResponseInfo;
  FARequestInfo := aRequestInfo;
  FDB := aDB;
end;

procedure TRPUsers.Delete;
begin
  // insert your code here...
  FResponses.OK();
end;

procedure TRPUsers.GetInfo;
var id :string;
    jsonUser : ISuperobject;
begin
  // insert your code here...
  id := ARequestInfo.Params.Values['password'];
  // getInfo by id... ... for ex in db
  jsonUser := SO();
  jsonUser.S['name'] := 'Bill Gates';
  FResponses.ResponseOkWithJson(jsonUser.AsJSon(false, false));
end;

procedure TRPUsers.Update;
begin
  // insert your code here...
  FResponses.OK();
end;

end.


