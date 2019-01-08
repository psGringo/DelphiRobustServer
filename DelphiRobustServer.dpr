program DelphiRobustServer;

uses
  Vcl.Forms,
  Vcl.SvcMgr,
  uMain in 'uMain.pas' {Main},
  uCommandGet in 'uCommandGet.pas',
  Vcl.Themes,
  Vcl.Styles,
  uTimers in 'uTimers.pas' {Timers: TDataModule},
  uRPMemory in 'RP\uRPMemory.pas',
  LDSLogger in 'LDSLogger.pas',
  uCommon in 'uCommon.pas',
  uRPUsers in 'RP\uRPUsers.pas',
  uDecodePostRequest in 'uDecodePostRequest.pas',
  uUniqueName in 'uUniqueName.pas',
  uDB in 'uDB.pas' {DB: TDataModule},
  uTImerThread in 'uTImerThread.pas',
  uClientExamples in 'uClientExamples.pas',
  uConst in 'uConst.pas',
  uRP in 'RP\uRP.pas',
  uRPTests in 'RP\uRPTests.pas',
  uAttributes in 'uAttributes.pas',
  uRPFiles in 'RP\uRPFiles.pas',
  uRPApi in 'RP\uRPApi.pas',
  uDelphiRobustService in 'uDelphiRobustService.pas' {DelphiRobustService},
  Winapi.Windows {MainService: TDataModule},
  uAnotherMain in 'uAnotherMain.pas' {AnotherMain};

{$R *.res}

begin
  if (ParamCount > 0) and (ParamStr(1) = 'vcl_desktop') then
  begin
    Vcl.Forms.Application.Initialize;
    Vcl.Forms.Application.MainFormOnTaskbar := True;
    TStyleManager.TrySetStyle('Carbon');
    Vcl.Forms.Application.CreateForm(TMain, Main);
    Main.IsVclDesktopMode := true;
    Vcl.Forms.Application.Run;
  end
  else
  begin
    if not Vcl.SvcMgr.Application.DelayInitialize or Vcl.SvcMgr.Application.Installing then
      Vcl.SvcMgr.Application.Initialize;
    Vcl.SvcMgr.Application.CreateForm(TDelphiRobustService, DelphiRobustService);
    Application.Run;
  end;

end.

