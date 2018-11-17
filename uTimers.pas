unit uTimers;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, DateUtils;

type
  TTimers = class(TDataModule)
    tWorkTimer: TTimer;
    procedure tWorkTimerTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  uMain, Winapi.Windows, Winapi.Messages;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TTimers.tWorkTimerTimer(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      s: string;
    begin
      s := DateTimeToStr(Now());
      PostMessage(Main.Handle, WM_WORK_TIME, 0, LParam(PChar(s)));
    end).Start;
end;

end.

