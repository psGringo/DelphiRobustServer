unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdHTTPServer, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, uCommandGet, uTimers, IdTCPConnection, IdTCPClient, IdHTTP,
  IdCustomHTTPServer, IdContext, Vcl.Samples.Spin, System.ImageList, Vcl.ImgList,
  uCommon;

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
    procedure bGetRequestClick(Sender: TObject);
    procedure ServerCommandGet(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure bStartStopClick(Sender: TObject);
    procedure bAPIClick(Sender: TObject);
    procedure ServerException(AContext: TIdContext; AException: Exception);
    procedure UpdateStartStopGlyph(aBitmapIndex: integer);
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

procedure TMain.ServerException(AContext: TIdContext; AException: Exception);
var
  l: ILogger;
begin
  l := TLogger.Create;
  l.LogError('Exception class ' + AException.ClassName + ' exception message ' + AException.Message);
end;

procedure TMain.SwitchStartStopButtons;
begin
  if Server.Active then
  begin
    Server.Active := false;
    FTimers.tWorkTimer.Enabled := false;
    StatusBar.Panels[0].Text := 'Stopped';
    UpdateStartStopGlyph(0);
  end
  else
  begin
    Server.Active := true;
    FTimers.tWorkTimer.Enabled := true;
    StatusBar.Panels[0].Text := 'Started';
    UpdateStartStopGlyph(1);
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

