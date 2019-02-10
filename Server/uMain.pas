unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  uCommandGet, uTimers, IdTCPConnection, IdTCPClient, IdHTTP, IdCustomHTTPServer, IdContext, Vcl.Samples.Spin, System.ImageList,
  Vcl.ImgList, uCommon, System.Classes, superobject, IdHeaderList, ShellApi, uRPTests, Registry, uConst;

const
  WM_WORK_TIME = WM_USER + 1000;
  WM_APP_MEMORY = WM_USER + 1001;

type
  TMain = class(TForm)
    Server: TIdHTTPServer;
    eRequest: TEdit;
    pUrlEncode: TPanel;
    bDoUrlEncode: TBitBtn;
    eUrlEncodeValue: TEdit;
    pTop: TPanel;
    bStartStop: TBitBtn;
    StatusBar: TStatusBar;
    ilPics: TImageList;
    pPort: TPanel;
    lPort: TLabel;
    sePort: TSpinEdit;
    bAPI: TBitBtn;
    OpenDialog: TOpenDialog;
    bLog: TBitBtn;
    cbRequestType: TComboBox;
    bGo: TBitBtn;
    pPost: TPanel;
    pPostParamsTop: TPanel;
    cbPostType: TComboBox;
    mPostParams: TMemo;
    bUrlEncode: TBitBtn;
    pAnswers: TPanel;
    pAnswerTop: TPanel;
    mAnswer: TMemo;
    bClearAnswers: TBitBtn;
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure bStartStopClick(Sender: TObject);
    procedure bAPIClick(Sender: TObject);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure UpdateStartStopGlyph(aBitmapIndex: integer);
    procedure bClearAnswersClick(Sender: TObject);
    procedure bLogClick(Sender: TObject);
    procedure bGoClick(Sender: TObject);
    procedure cbRequestTypeSelect(Sender: TObject);
    procedure bUrlEncodeClick(Sender: TObject);
    procedure cbPostTypeSelect(Sender: TObject);
    procedure bDoUrlEncodeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FProtocol: string;
    FHost: string;
    FPort: string;
    FTimers: TTimers;
    FAdress: string;
    FLongTaskThreads: ISP<TThreadList>;
    procedure SwitchStartStopButtons();
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
    procedure UpdateAppMemory(var aMsg: TMessage); message WM_APP_MEMORY;
    procedure PostRequestProcessing();
    procedure GetRequestProcessing();
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure Start;
    procedure Stop;
    property Protocol: string read FProtocol write FProtocol;
    property Host: string read FHost write FHost;
    property Port: string read FPort write FPort;
    property Adress: string read FAdress write FAdress;
    property Timers: TTimers read FTimers write FTimers;
    property LongTaskThreads: ISP<TThreadList> read FLongTaskThreads;
  end;

var
  Main: TMain;

implementation
{$R *.dfm}

uses
  System.NetEncoding, IdMultipartFormData, uClientExamples, uRP, System.Math, System.IOUtils, System.IniFiles;

{ TMain }
procedure TMain.bAPIClick(Sender: TObject);
var
  c: ISP<TIdHTTP>;
begin
  c := TSP<TIdHTTP>.Create();
  c.Get(FAdress + '/System/Api');
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', 'api.txt', nil, SW_SHOWNORMAL);
end;

procedure TMain.bClearAnswersClick(Sender: TObject);
begin
  mAnswer.Lines.Clear();
end;

procedure TMain.bDoUrlEncodeClick(Sender: TObject);
begin
  eUrlEncodeValue.Text := System.NetEncoding.TNetEncoding.URL.Encode(eUrlEncodeValue.Text);
end;

procedure TMain.bGoClick(Sender: TObject);
begin
  case cbRequestType.ItemIndex of
    0:
      GetRequestProcessing();
    1:
      PostRequestProcessing();
  end;
end;

procedure TMain.bLogClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'c:\windows\notepad.exe', 'log.txt', nil, SW_SHOWNORMAL);
end;

procedure TMain.PostRequestProcessing();
var
  client: ISP<TIdHTTP>;
  jo: ISuperobject;
  ss: ISP<TStringStream>;
  postData: ISP<TIdMultiPartFormDataStream>;
  paramsSL: ISP<TStringList>;
  r: string;
  fileName: string;
begin
  client := TSP<TIdHTTP>.Create();
  ss := TSP<TStringStream>.Create();

  case cbPostType.ItemIndex of
    0:
      begin
        jo := SO(Trim(mPostParams.Lines.Text));
        ss.WriteString(jo.AsJSon(false, false));
        client.Request.ContentType := 'application/json';
        client.Request.ContentEncoding := 'utf-8';
        r := client.Post(FAdress + '/' + eRequest.Text, ss);
        mAnswer.Lines.Add(r);
      end;
    1:
      begin
       //for test Send with 2 params on  Test/URLEncoded
        paramsSL := TSP<TStringList>.Create();
        paramsSL.Assign(mPostParams.Lines);
        { or in code you can add params...
         paramsSL.Add('a=UrlEncoded(aValue)')
         paramsSL.Add('b=UrlEncoded(bValue)')
        }
        client.Request.ContentType := 'application/x-www-form-urlencoded';
        client.Request.ContentEncoding := 'utf-8';

        r := client.Post(FAdress + '/' + eRequest.Text, paramsSL);
        mAnswer.Lines.Add(r);
      end;
    2:
      begin
      // multipart...
        fileName := ExtractFileName(mPostParams.Lines[0]);
        postData := TSP<TIdMultiPartFormDataStream>.Create();
        client.Request.Referer := FAdress + '/' + eRequest.Text;
        client.Request.ContentType := 'multipart/form-data';
        client.Request.RawHeaders.AddValue('AuthToken', System.NetEncoding.TNetEncoding.URL.Encode('evjTI82N'));
        postData.AddFormField('filename', System.NetEncoding.TNetEncoding.URL.Encode(fileName));
        postData.AddFormField('isOverwrite', System.NetEncoding.TNetEncoding.URL.Encode(mPostParams.Lines[1]));
        postData.AddFile('attach', mPostParams.Lines[0], 'application/x-rar-compressed');
        client.POST(FAdress + '/' + eRequest.Text, postData, ss); //
        mAnswer.Lines.Add(ss.DataString);
      end;
  end;
end;

procedure TMain.bStartStopClick(Sender: TObject);
begin
  SwitchStartStopButtons();
end;

procedure TMain.bUrlEncodeClick(Sender: TObject);
begin
  pUrlEncode.Visible := not pUrlEncode.Visible;
end;

procedure TMain.cbPostTypeSelect(Sender: TObject);
begin
  mPostParams.Clear();
  mPostParams.Lines.BeginUpdate;
  case cbPostType.ItemIndex of
    0:
      begin
        eRequest.Text := 'Test/PostJson';
        mPostParams.Text := '{ "name":"Stas", "age":35 }';
      end;
    1:
      begin
        eRequest.Text := 'Test/URLEncoded';
        mPostParams.Lines.Add('PostParam1 = URLEncoded(PostParam1Value)');
        mPostParams.Lines.Add('PostParam2 = URLEncoded(PostParam2Value)');
      end;
    2:
      begin
        eRequest.Text := 'Files/Upload';
        mPostParams.Lines.Add(ExtractFilePath(Application.ExeName) + 'testFile.php');
        mPostParams.Lines.Add('false');
      end;
  end;
  mPostParams.Lines.EndUpdate;
end;

procedure TMain.cbRequestTypeSelect(Sender: TObject);
begin
  case cbRequestType.ItemIndex of
    0:
      begin
        eRequest.Text := 'Test/Connection';
        pPost.Visible := false;
      end;

    1:
      begin
        cbPostTypeSelect(nil);
        pPost.Visible := true;
      end;

  end;
end;

constructor TMain.Create(AOwner: TComponent);
var
  filepath: string;
  ini: ISP<TIniFile>;
begin
  inherited;

  filepath := ExtractFilePath(Application.ExeName) + settingsFileName;
  if TFile.Exists(filepath) then
  begin
    ini := TSP<Tinifile>.Create(Tinifile.Create(filepath));
    FProtocol := ini.ReadString('server', 'protocol', '<None>');
    FHost := ini.ReadString('server', 'host', '<None>');
    FPort := ini.ReadString('server', 'port', '<None>');
  end
  else
  begin
    FProtocol := 'http';
    FHost := 'localhost';
    FPort := '7777';
  end;
  Adress := FProtocol + '://' + FHost + ':' + FPort;

  ReportMemoryLeaksOnShutdown := True;
  FTimers := TTimers.Create(Self);
  sePort.Value := FPort.ToInteger();
  Server.DefaultPort := FPort.ToInteger();
  ilPics.GetBitmap(3, bClearAnswers.Glyph);
  SwitchStartStopButtons(); // will start server

  FLongTaskThreads := TSP<TThreadList>.Create();
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: integer;
begin
  with LongTaskThreads.LockList() do
  try
    for i := 0 to Count-1 do
    begin
      TLongTaskThread(Items[i]).FreeOnTerminate := false; // in other case they will be destroyed automatically
      TLongTaskThread(Items[i]).Free();
    end;
  finally
    LongTaskThreads.UnlockList();
  end;
end;

procedure TMain.GetRequestProcessing;
var
  client: ISP<TIdHTTP>;
begin
  client := TSP<TIdHTTP>.Create();
  mAnswer.Lines.Add(client.Get(FAdress + '/' + eRequest.Text));
end;

procedure TMain.ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  cg: ISP<TCommandGet>;
begin
  cg := TSP<TCommandGet>.Create(TCommandGet.Create(AContext, ARequestInfo, AResponseInfo));
end;

procedure TMain.ServerException(AContext: TIdContext; AException: Exception);
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  l.LogError('Exception class ' + AException.ClassName + ' exception message ' + AException.Message);
end;

procedure TMain.Start;
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  Server.Active := true;
  StatusBar.Panels[0].Text := 'Started';
  UpdateStartStopGlyph(1);
  l.LogInfo('Server successfully started');
end;

procedure TMain.Stop;
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  Server.Active := false;
  StatusBar.Panels[0].Text := 'Stopped';
  UpdateStartStopGlyph(0);
  l.LogInfo('Server successfully stopped');

end;

procedure TMain.SwitchStartStopButtons;
begin
  if (Server.Active) then
    Stop
  else
    Start;
end;

procedure TMain.UpdateAppMemory(var aMsg: TMessage);
begin
  StatusBar.Panels[2].Text := PChar(aMsg.LParam);
end;

procedure TMain.UpdateStartStopGlyph(aBitmapIndex: integer);
begin
  bStartStop.Glyph := nil;
  ilPics.GetBitmap(aBitmapIndex, bStartStop.Glyph);
end;

procedure TMain.UpdateWorkTime(var aMsg: TMessage);
begin
  StatusBar.Panels[1].Text := PChar(aMsg.LParam);
end;

end.

