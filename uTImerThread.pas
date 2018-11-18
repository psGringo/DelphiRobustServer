unit uTimerThread;

interface

uses
  System.Classes, uCommon;

type
  TTimerThread = class(TThread)
  private
    FMsg: string;
    FPanelNumber: int;
    { Private declarations }
  protected
    procedure Execute; override;
  public
  property Msg:string read FMsg write FMsg;
  property PanelNumber: int read FPanelNumber write FPanelNumber;
  end;

implementation
  uses uMain;
{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TTestThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end;

    or

    Synchronize(
      procedure
      begin
        Form1.Caption := 'Updated in thread via an anonymous method'
      end
      )
    );
    
  where an anonymous method is passed.
  
  Similarly, the developer can call the Queue method with similar parameters as 
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.
    
}

{ TTestThread }

procedure TTimerThread.Execute;
begin
  { Place thread code here }
  Synchronize(
      procedure
      begin
      Main.StatusBar.Panels[FPanelNumber].Text := FMsg;
      end
      )
end;
end.
