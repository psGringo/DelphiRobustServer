unit uTestThread;

interface

uses
  System.Classes, uSmartPointer, IdHTTP;

type
  TTestThread = class(TThread)
  private
    FCountRequestsPerSecond: integer;
    { Private declarations }
  protected
    procedure Execute; override;
  public
    property CountRequestsPerSecond: integer read FCountRequestsPerSecond write FCountRequestsPerSecond;
  end;

implementation

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

procedure TTestThread.Execute;
var
  i: integer;
  c: ISP<TIdHTTP>;
  s: string;
begin
  { Place thread code here }
  c := TSP<TIdHTTP>.Create();
  while not Terminated do
  begin
    for i := 0 to FCountRequestsPerSecond - 1 do
    begin
      s := c.Get('http://localhost:7777/Test/DBConnection');
    end;
    sleep(1000);
  end;
end;

end.

