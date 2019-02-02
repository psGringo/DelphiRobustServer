unit uMainFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.Samples.Spin, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  uCommon, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdMultipartFormData, System.NetEncoding,
  System.IniFiles, uConst, System.IOUtils, Math;

type
  TMainFrame = class(TFrame)
    eRequest: TEdit;
    ilPics: TImageList;
    mAnswer: TMemo;
    pAnswerTop: TPanel;
    bClearAnswers: TBitBtn;
    pPost: TPanel;
    pPostParamsTop: TPanel;
    cbPostType: TComboBox;
    mPostParams: TMemo;
    pTop: TPanel;
    bStop: TBitBtn;
    bAPI: TBitBtn;
    bLog: TBitBtn;
    cbRequestType: TComboBox;
    bGo: TBitBtn;
    bUrlEncode: TBitBtn;
    pUrlEncode: TPanel;
    bDoUrlEncode: TBitBtn;
    eUrlEncodeValue: TEdit;
    StatusBar: TStatusBar;
    IdHTTP1: TIdHTTP;
    eHost: TEdit;
    pPort: TPanel;
    sePort: TSpinEdit;
    cmbProtocol: TComboBox;
    cbServiceOrExe: TComboBox;
    bPause: TBitBtn;
    bStart: TBitBtn;
    procedure bGoClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure bPauseClick(Sender: TObject);
    procedure bUrlEncodeClick(Sender: TObject);
    procedure bDoUrlEncodeClick(Sender: TObject);
  private
    FIsStartedAsService: boolean;
    procedure PostRequestProcessing;
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure ShowGUIServerStarted();
    procedure ShowGUIServerStopped();
    procedure Init();
  end;

implementation

uses
  uMain, superobject, uTimers;
{$R *.dfm}

procedure TMainFrame.ShowGUIServerStarted;
begin
  Main.Timers.tStatus.Enabled := true;
  StatusBar.Panels[0].Text := ServerStarted;
end;

procedure TMainFrame.ShowGUIServerStopped;
begin
  Main.Timers.tStatus.Enabled := false;
  StatusBar.Panels[0].Text := ServerStopped;
end;

procedure TMainFrame.bPauseClick(Sender: TObject);
var
  answer: string;
begin
  if ( not Main.Server.IsActive) or ( not Main.Server.IsOnline)
  then Exit();

  if Main.Server.GoOffline(answer) then
  begin
    StatusBar.Panels[0].Text := ServerPaused;
    Main.Timers.tStatus.Enabled := false;
  end
  else
    mAnswer.Lines.Add(answer);
end;

procedure TMainFrame.bStartClick(Sender: TObject);
begin
  if Main.Server.Start() then
  begin
    StatusBar.Panels[0].Text := ServerStarted;
    Main.Timers.tStatus.Enabled := true;
  end;
end;

procedure TMainFrame.bStopClick(Sender: TObject);
begin
  if Main.Server.Stop() then
  begin
    StatusBar.Panels[0].Text := ServerStopped;
    StatusBar.Panels[1].Text := ''; // time
    StatusBar.Panels[2].Text := ''; // memory
    StatusBar.Panels[3].Text := ''; // connections
    Main.Timers.tStatus.Enabled := false;
  end;
end;

procedure TMainFrame.bUrlEncodeClick(Sender: TObject);
begin
  pUrlEncode.Visible := not pUrlEncode.Visible;
end;

constructor TMainFrame.Create(AOwner: TComponent);
begin
  inherited;
  ilPics.GetBitmap(3, bClearAnswers.Glyph);
  ilPics.GetBitmap(0, bStart.Glyph);
  ilPics.GetBitmap(1, bStop.Glyph);
  ilPics.GetBitmap(4, bPause.Glyph);
end;

procedure TMainFrame.Init;
begin
  if Main.Server.IsActive then
    ShowGUIServerStarted()
  else
    ShowGUIServerStopped();
end;

procedure TMainFrame.PostRequestProcessing;
var
  r: string;
begin

  case cbPostType.ItemIndex of
    0:
      begin
        r := Main.Server.PostJsonRequest(Trim(eRequest.Text), Trim(mPostParams.Lines.Text));
        mAnswer.Lines.Add(r);
      end;
    1:
      begin
        r := Main.Server.PostUrlEncodedRequest(Trim(eRequest.Text), mPostParams.Lines);
        mAnswer.Lines.Add(r);
      end;
    2:
      begin
      // multipart...
        r := Main.Server.PostMultiPart(Trim(eRequest.Text), Trim(mPostParams.Lines[0]), Trim(mPostParams.Lines[1]));
        mAnswer.Lines.Add(r);
      end;
  end;
end;

procedure TMainFrame.bDoUrlEncodeClick(Sender: TObject);
begin
  eUrlEncodeValue.Text := System.NetEncoding.TNetEncoding.URL.Encode(eUrlEncodeValue.Text);
end;

procedure TMainFrame.bGoClick(Sender: TObject);
begin
  case cbRequestType.ItemIndex of
    0:
      Main.Server.GetRequest(eRequest.Text);
    1:
      PostRequestProcessing();
  end;
end;

end.
