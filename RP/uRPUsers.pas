unit uRPUsers;
{< Request processing users}

interface

uses
  System.SysUtils, System.Classes, IdCustomHTTPServer, superobject,
  uCommon, uDB, uRP;

type
  TRPUsers = class(TRP)
  public
    constructor Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo); overload; override;
    procedure Create(); overload; override;
    procedure Delete(); override;
    procedure Update(); override;
    procedure GetInfo(); override;
  end;

implementation

{ TRPUsers }

procedure TRPUsers.Create();
begin
       // insert your code here...
  Responses.OK();
end;

constructor TRPUsers.Create(aRequestInfo: TIdHTTPRequestInfo; aResponseInfo: TIdHTTPResponseInfo);
begin
  inherited;
  FClassAlias := 'Users';
  Execute(ARequestInfo.URI);
end;

procedure TRPUsers.Delete;
begin
  // insert your code here...
Responses.OK();
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
  Responses.OkWithJson(jsonUser.AsJSon(false, false));
end;

procedure TRPUsers.Update;
begin
  // insert your code here...
  Responses.OK();
end;

end.


