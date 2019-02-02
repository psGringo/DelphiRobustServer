program RobustServerGUI;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {Main},
  uMainFrame in 'uMainFrame.pas' {MainFrame: TFrame},
  uTimers in 'uTimers.pas' {Timers: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  uCommon in 'uCommon.pas',
  uConst in 'uConst.pas',
  uRSGClasses in 'uRSGClasses.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Charcoal Dark Slate');
  Application.CreateForm(TMain, Main);
  Application.Run;
end.