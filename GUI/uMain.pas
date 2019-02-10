unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin, Vcl.Buttons, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList, Vcl.ComCtrls,
  uMainFrame, uTimers, System.IOUtils, Registry, System.IniFiles, uCommon, uRSGClasses;

type
  TMain = class(TForm)
    PageControl: TPageControl;
    tsMain: TTabSheet;
    tsLoadTests: TTabSheet;
    MF: TMainFrame;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FServer: ISP<TServer>;
    FTimers: TTimers;
    procedure NotifyEventMsg(aMsg: string);
    procedure NotifyEventStatusMsg(aMsg: string);
  public
    { Public declarations }
    property Server: ISP<TServer> read FServer write FServer;
    property Timers: TTimers read FTimers write FTimers;
  end;

var
  Main: TMain;

implementation

uses
  uConst, IdHTTP, superobject;
{$R *.dfm}

procedure TMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  FServer := TSP<TServer>.Create();
  FServer.OnNotifyEventMsg := NotifyEventMsg;
  FServer.OnNotifyEventStatusMsg := NotifyEventStatusMsg;
  FTimers := TTimers.Create(Self);
  MF.Init();
end;

procedure TMain.NotifyEventMsg(aMsg: string);
begin
  MF.mAnswer.Lines.Add(aMsg);
end;

procedure TMain.NotifyEventStatusMsg(aMsg: string);
begin
  MF.StatusBar.Panels[0].Text := aMsg;
end;

end.

