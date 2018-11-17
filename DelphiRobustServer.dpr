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
  uResponses in 'uResponses.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Tablet Light');
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
