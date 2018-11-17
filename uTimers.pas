unit uTimers;

interface

uses
  System.SysUtils, Vcl.ExtCtrls, DateUtils, System.Classes;

type
  TTimers = class(TDataModule)
    tWorkTimer: TTimer;
    tMemory: TTimer;
    procedure tWorkTimerTimer(Sender: TObject);
    procedure tMemoryTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  uMain, Winapi.Windows, Winapi.Messages,uRPMemory,uSmartPointer;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TTimers.tMemoryTimer(Sender: TObject);
var
  t: TThread;
begin
 t := TThread.CreateAnonymousThread(
    procedure
    var
      s: string;
      memory: ISmartPointer<TRPMemory>;
    begin
      memory := TSmartPointer<TRPMemory>.Create();
      s := memory. CurrentProcessMemoryKB.ToString()+' KB / '+memory.CurrentProcessMemoryPeakKB.ToString()+' KB';
      PostMessage(Main.Handle, WM_APP_MEMORY, 0, LParam(PChar(s)));
    end);
   t.FreeOnTerminate := true;
   t.Start;
end;

procedure TTimers.tWorkTimerTimer(Sender: TObject);
var
  t: TThread;
begin
 t := TThread.CreateAnonymousThread(
    procedure
    var
      s: string;
    begin
      s := DateTimeToStr(Now());
      PostMessage(Main.Handle, WM_WORK_TIME, 0, LParam(PChar(s)));
    end);
   t.FreeOnTerminate := true;
   t.Start;
end;

end.

