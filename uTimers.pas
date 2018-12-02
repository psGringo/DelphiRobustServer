unit uTimers;

interface

uses
  System.SysUtils, Vcl.ExtCtrls, DateUtils, System.Classes, uCommon;

type
  TTimers = class(TDataModule)
    tWorkTimer: TTimer;
    tMemory: TTimer;
    procedure tWorkTimerTimer(Sender: TObject);
    procedure tMemoryTimer(Sender: TObject);
  private
    FStartTime: TDateTime;
    procedure SetStartTime(const Value: TDateTime);
    { Private declarations }
  public
    { Public declarations }
    property StartTime:TDateTime read FStartTime write SetStartTime;
  end;

implementation

uses
  uMain, Winapi.Windows, Winapi.Messages,uRPMemory, uTimerThread;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TTimers.SetStartTime(const Value: TDateTime);
begin
  FStartTime := Value;
end;

procedure TTimers.tMemoryTimer(Sender: TObject);
var
  t: TTimerThread;
  memory: ISP<TRPMemory>;
    //t: TThread;
begin
  memory := TSP<TRPMemory>.Create();
  t := TTimerThread.Create(true);
  t.Msg := memory.CurrentProcessMemoryKB.ToString()+' KB / '+memory.CurrentProcessMemoryPeakKB.ToString()+' KB';
  t.PanelNumber := 2;
  t.FreeOnTerminate := true;
  t.Start;
{
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
}
end;

procedure TTimers.tWorkTimerTimer(Sender: TObject);
var
  //t: TThread;
  t:TTimerThread;
begin
  t := TTimerThread.Create(true);
  t.Msg := TimeToStr(Now() - FStartTime);
  t.PanelNumber := 1;
  t.FreeOnTerminate := true;
  t.Start;
    {
 t := TThread.CreateAnonymousThread(
    procedure
    var
      s: string;
    begin
      s := DateTimeToStr(Now());
      //PostMessage(Main.Handle, WM_WORK_TIME, 0, LParam(PChar(s)));


    end);
   t.FreeOnTerminate := true;
   t.Start;
   }
end;

end.

