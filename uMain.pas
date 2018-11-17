unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, uCommandGet, uTimers, IdTCPConnection, IdTCPClient, IdHTTP,
  IdCustomHTTPServer, IdContext, Vcl.Samples.Spin, System.ImageList, Vcl.ImgList;

const
  WM_WORK_TIME = WM_USER + 1000;

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
    procedure bGetRequestClick(Sender: TObject);
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure bStartStopClick(Sender: TObject);
    procedure bAPIClick(Sender: TObject);
  private
    { Private declarations }
    FCommandGet: TCommandGet;
    FTimers: TTimers;
    procedure SwitchStartStopButtons();
    procedure UpdateWorkTime(var aMsg: TMessage); message WM_WORK_TIME;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  Main: TMain;

implementation
{$R *.dfm}

uses
  uSmartPointer;


{ TMain }
procedure TMain.bAPIClick(Sender: TObject);
begin
  ShowMessage('Link to API');
end;

procedure TMain.bGetRequestClick(Sender: TObject);
var
  client: ISmartPointer<TIdHTTP>;
begin
  client := TSmartPointer<TIdHTTP>.Create();
  mAnswer.Lines.Add(client.Get('http://localhost:' + Server.DefaultPort.ToString + '/' + eRequest.Text));
end;

procedure TMain.bStartStopClick(Sender: TObject);
begin
  SwitchStartStopButtons();
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

procedure TMain.SwitchStartStopButtons;
begin
  if Server.Active then
  begin
    Server.Active := false;
    FTimers.tWorkTimer.Enabled := false;
    //bStartStop.Caption := 'Start';
    StatusBar.Panels[0].Text := 'Stopped';
    ilPics.GetBitmap(0, bStartStop.Glyph);
  end
  else
  begin
    Server.Active := true;
    FTimers.tWorkTimer.Enabled := true;
    //bStartStop.Caption := 'Stop';
    StatusBar.Panels[0].Text := 'Started';
    ilPics.GetBitmap(1, bStartStop.Glyph);
  end;
end;

procedure TMain.UpdateWorkTime(var aMsg: TMessage);
begin
  StatusBar.Panels[1].Text := PChar(aMsg.LParam);
end;

end.

