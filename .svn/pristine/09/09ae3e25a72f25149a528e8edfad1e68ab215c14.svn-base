unit uLoadTestsFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, uSmartPointer, IdAntiFreezeBase, Vcl.IdAntiFreeze, uTestThread;

type
  TLoadTestFrame = class(TFrame)
    pTop: TPanel;
    bStart: TBitBtn;
    bStop: TBitBtn;
    cmbTests: TComboBox;
    Timer: TTimer;
    IdHTTP: TIdHTTP;
    pCenter: TPanel;
    pLeft: TPanel;
    pDescriptionTop: TPanel;
    mDescription: TMemo;
    pRight: TPanel;
    pParamsTop: TPanel;
    mParams: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    pBottom: TPanel;
    mResultsErrors: TMemo;
    pResultsErrors: TPanel;
    IdAntiFreeze: TIdAntiFreeze;
    procedure TimerTimer(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
  private
    { Private declarations }
    FProc: TProc;
    FAdress: string;
    FTestThread: TTestThread;
    procedure TestDBConnections;
  public
    { Public declarations }
  end;

implementation

uses
  uMain;


{$R *.dfm}

procedure TLoadTestFrame.bStartClick(Sender: TObject);
begin
  if Assigned(FTestThread) then
    FTestThread.Terminate();

  FTestThread := TTestThread.Create(true);
  FTestThread.CountRequestsPerSecond := mParams.Lines.Values['countRequestsPerSecond'].ToInteger;
  FTestThread.Start();
  {
  FAdress := Main.Server.Adress;
  Timer.Enabled := false;
  case cmbTests.ItemIndex of
    0:
      begin
        FProc := TestDBConnections;
      end;

  end;
  Timer.Enabled := true;
  }
end;

procedure TLoadTestFrame.bStopClick(Sender: TObject);
begin
  FTestThread.Terminate();
//  Timer.Enabled := false;
end;

procedure TLoadTestFrame.TestDBConnections;

//  c: ISP<TIdHTTP>;

begin



 // c := TSP<TIdHTTP>.Create();
  //r := c.Get('http://localhost:7777/Test/DBConnection');
 {
  TThread.CreateAnonymousThread(
    procedure()
    var
      i: integer;
      countRequestsPerSecond: integer;
    begin


      countRequestsPerSecond := mParams.Lines.Values['countRequestsPerSecond'].ToInteger;
      for i := 0 to countRequestsPerSecond do
      begin
        TThread.CreateAnonymousThread(
          procedure()
          var
            c: ISP<TIdHTTP>;
            s: string;
          begin
            try
              c := TSP<TIdHTTP>.Create();
              s := c.Get('http://localhost:7777/Test/DBConnection');
            except
              on E: Exception do
              begin
                Timer.Enabled := false;
                mResultsErrors.Lines.Add(e.ClassName + ' ' + e.Message);
              end;
            end;
          end).Start();
      end;
    end).Start();
    }
end;

procedure TLoadTestFrame.TimerTimer(Sender: TObject);
begin
  FProc();
end;

end.

