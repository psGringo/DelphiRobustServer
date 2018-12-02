unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  uCommandGet, uTimers, IdTCPConnection, IdTCPClient, IdHTTP, IdCustomHTTPServer,
  IdContext, Vcl.Samples.Spin, System.ImageList, Vcl.ImgList, uCommon, System.Classes,
  superobject, IdHeaderList;

const
  WM_WORK_TIME = WM_USER + 1000;
  WM_APP_MEMORY = WM_USER + 1001;

type
  TMain = class(TForm)
    Server: TIdHTTPServer;
    eRequest: TEdit;
    mAnswer: TMemo;
    mPostParams: TMemo;
    pAnswer: TPanel;
    pUrlEncode: TPanel;
    bUrlEncode: TBitBtn;
    eUrlEncodeValue: TEdit;
    pPostParams: TPanel;
    pTop: TPanel;
    bStartStop: TBitBtn;
    bGetRequest: TBitBtn;
    bPostRequest: TBitBtn;
    StatusBar: TStatusBar;
    bClearAnswers: TBitBtn;
    ilPics: TImageList;
    pPort: TPanel;
    lPort: TLabel;
    sePort: TSpinEdit;
    bAPI: TBitBtn;
    OpenDialog: TOpenDialog;
    pLog: TPanel;
    mLog: TMemo;
    bTest: TButton;
    cbPostType: TComboBox;
    procedure bGetRequestClick(Sender: TObject);
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure bStartStopClick(Sender: TObject);
    procedure bAPIClick(Sender: TObject);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure UpdateStartStopGlyph(aBitmapIndex: integer);
    procedure bPostRequestClick(Sender: TObject);
    procedure bClearAnswersClick(Sender: TObject);
    procedure bTestClick(Sender: TObject);
  private
    { Private declarations }
    FCommandGet: TCommandGet;
    FTimers: TTimers;
    procedure SwitchStartStopButtons();
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
    procedure UpdateAppMemory(var aMsg: TMessage); message WM_APP_MEMORY;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  Main: TMain;

implementation
{$R *.dfm}

uses
  System.NetEncoding, IdMultipartFormData, uClientExamples;

{ TMain }
procedure TMain.bAPIClick(Sender: TObject);
begin
  ShowMessage('Link to API');
end;

procedure TMain.bClearAnswersClick(Sender: TObject);
begin
  mAnswer.Lines.Clear();
end;

procedure TMain.bGetRequestClick(Sender: TObject);
var
  client: ISP<TIdHTTP>;
begin
  client := TSP<TIdHTTP>.Create();
  mAnswer.Lines.Add(client.Get('http://localhost:' + Server.DefaultPort.ToString + '/' + eRequest.Text));
end;

procedure TMain.bPostRequestClick(Sender: TObject);
begin
//
end;

procedure TMain.bStartStopClick(Sender: TObject);
begin
  SwitchStartStopButtons();
end;

procedure TMain.bTestClick(Sender: TObject);
var
  ce: ISP<TClientExamples>;
begin
  ce := TSP<TClientExamples>.Create(TClientExamples.Create(eRequest.Text, sePort.Value.ToString()));
  if OpenDialog.Execute then
  ce.PostSendFile(OpenDialog.FileName);
end;

constructor TMain.Create(AOwner: TComponent);
begin
  inherited;
  ReportMemoryLeaksOnShutdown := True;
  FCommandGet := TCommandGet.Create(Self);
  FTimers := TTimers.Create(Self);
  Server.DefaultPort := sePort.Value;
  SwitchStartStopButtons(); // will start server
end;

procedure TMain.ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  FCommandGet.Execute(AContext, ARequestInfo, AResponseInfo);
end;

procedure TMain.ServerException(AContext: TIdContext; AException: Exception);
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  l.LogError('Exception class ' + AException.ClassName + ' exception message ' + AException.Message);
end;

procedure TMain.SwitchStartStopButtons;
var
  l: ISP<TLogger>;
begin
  l := TSP<TLogger>.Create();
  if Server.Active then
  begin
    Server.Active := false;
    FTimers.tWorkTimer.Enabled := false;
    StatusBar.Panels[0].Text := 'Stopped';
    UpdateStartStopGlyph(0);
    l.LogInfo('Server successfully stopped');
  end
  else
  begin
    Server.Active := true;
    FTimers.tWorkTimer.Enabled := true;
    FTimers.StartTime := Now;
    StatusBar.Panels[0].Text := 'Started';
    UpdateStartStopGlyph(1);
    l.LogInfo('Server successfully started');
  end;
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

