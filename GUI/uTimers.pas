unit uTimers;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

type
  TTimers = class(TDataModule)
    tStatus: TTimer;
    IdHTTP: TIdHTTP;
    procedure tStatusTimer(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    procedure StopTimers();
  end;

implementation

uses
  uMain, superobject, uCommon;
{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TTimers.StopTimers;
var
  i: integer;
begin
  for i := 0 to Self.ComponentCount - 1 do
    if Self.Components[i] is TTimer then
      (Self.Components[i] as TTimer).Enabled := false;
end;

procedure TTimers.tStatusTimer(Sender: TObject);
var
  jo: ISuperObject;
  idHTTP: ISP<TiDHTTP>;
begin
  TThread.CreateAnonymousThread(
    procedure
    begin
      idHTTP := TSP<TiDHTTP>.Create();
      try
        // workTime
        jo := SO[idHTTP.Get(Main.Server.Adress + '/System/WorkTime')];
        TThread.Synchronize(TThread.CurrentThread,
          procedure()
          begin
            Main.MF.StatusBar.Panels[1].Text := jo.O['data'].s['workTime'];
            Main.Server.IsActive := true;
            Main.Server.IsOnline := true;
          end);

        // memory
            jo := SO[idHTTP.Get(Main.Server.Adress + '/System/Memory')];
        TThread.Synchronize(TThread.CurrentThread,
          procedure()
          begin
            Main.MF.StatusBar.Panels[2].Text := jo.O['data'].s['memory'];
          end);

        // Contexts
            jo := SO[idHTTP.Get(Main.Server.Adress + '/System/Connections')];
        TThread.Synchronize(TThread.CurrentThread,
          procedure()
          begin
            Main.MF.StatusBar.Panels[3].Text := 'Connections ' + jo.O['data'].i['connections'].ToString();
          end);
      except
        on E: Exception do
          TThread.Synchronize(TThread.CurrentThread,
            procedure()
            begin
              Main.MF.StatusBar.Panels[1].Text := E.Message;
              Main.Server.IsActive := false;
              Main.Server.IsOnline := false;
            end);
      end;
    end).Start;
end;

end.
