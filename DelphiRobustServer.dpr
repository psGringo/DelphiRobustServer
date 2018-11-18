program DelphiRobustServer;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  uCommandGet in 'uCommandGet.pas',
  Vcl.Themes,
  Vcl.Styles,
  uTimers in 'uTimers.pas' {Timers: TDataModule},
  uSmartPointer in 'uSmartPointer.pas',
  uRPMemory in 'RP\uRPMemory.pas',
  LDSLogger in 'LDSLogger.pas',
  uCommon in 'uCommon.pas',
  uConst in 'uConst.pas',
  uResponses in 'uResponses.pas',
  uRPUsers in 'RP\uRPUsers.pas',
  uDecodePostRequest in 'uDecodePostRequest.pas',
  uUniqueName in 'uUniqueName.pas',
  uDB in 'uDB.pas' {DB: TDataModule},
  uTImerThread in 'uTImerThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Onyx Blue');
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
