unit uRSService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  uMain, Vcl.Forms, uTimers;

type
  TRobustService = class(TService)
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
    FMain: TMain;
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
    property MainInstance: TMain read FMain;
  end;

var
  RobustService: TRobustService;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

{ TMainService }

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  RobustService.Controller(CtrlCode);
end;

function TRobustService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TRobustService.ServiceCreate(Sender: TObject);
begin
  FMain := TMain.Create(Self);
end;

procedure TRobustService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FMain.Start();
  Started := true;
end;

procedure TRobustService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FMain.Stop();
  Stopped := true;
end;

end.

