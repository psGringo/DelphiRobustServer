unit uDB;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDB = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysMySQLDriverLink: TFDPhysMySQLDriverLink;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    function Connect: boolean;
    function GetLastID: integer;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TDB.Connect: boolean;
var
  oParams: TStrings;
  ErrorInfo: string;
begin
  oParams := TStringList.Create;
  try
    oParams.Add('DataBase=sarafan_db');
    oParams.Add('Password=masterkey');
    oParams.Add('User_Name=root');
    oParams.Add('Port=3306');
    oParams.Add('Server=localhost');
    oParams.Add('CharacterSet=utf8');
//  oParams.Add('Pooled=true');
    FDConnection.Params.Assign(oParams);
    FDConnection.DriverName := 'MySQL';
   //������� ������������
    try
      FDConnection.Connected := true;
      if FDConnection.Connected then
      begin
        Result := true;
//     showmessage('Connected');
      end
      else
        Result := false;
    except
      on E: EFDDBEngineException do
        case E.Kind of
          ekUserPwdInvalid:
       // user name or password are incorrect
            raise Exception.Create('DBConnection Error. User name or password are incorrect' + #13#10 + #13#10 + E.ClassName + ' ������� ������, � ���������� : ' + E.Message);
          ekUserPwdExpired:
            raise Exception.Create('DBConnection Error. User password is expired' + #13#10 + #13#10 + E.ClassName + ' ������� ������, � ���������� : ' + E.Message);
          ekServerGone:
            raise Exception.Create('DBConnection Error. DBMS is not accessible due to some reason' + #13#10 + #13#10 + E.ClassName + ' ������� ������, � ���������� : ' + E.Message);
        else                // other issues
          raise Exception.Create('DBConnection Error. UnknownMistake' + #13#10 + #13#10 + E.ClassName + ' ������� ������, � ���������� : ' + E.Message);
        end;
      on E: Exception do
        raise Exception.Create(E.ClassName + ' ������� ������, � ���������� : ' + #13#10 + #13#10 + E.Message);
    end;
  finally
    FreeAndNil(oParams);
  end;
end;

constructor TDB.Create(AOwner: TComponent);
begin
  inherited;
  Connect();
end;

function TDB.GetLastID: integer;
var
  q: TFdquery;
begin
  q := TFdquery.Create(Self);
  try
    with q do
    begin
      Connection := FDConnection;
      sql.Text := 'SELECT last_insert_id() as lastID;';
      Disconnect();
      Open();
      result := FieldByName('lastID').AsInteger;
      Close();
    end;
  finally
    q.Free;
  end;
end;

end.
