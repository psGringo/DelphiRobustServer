unit uCommon;

interface

uses
  LDSLogger, uConst, System.SysUtils, System.Classes, IdCustomHTTPServer,
  superobject, uResponses;

type
  int = integer;

  ILogger = interface(IUnknown)
    ['{CE79C197-CB93-4576-9590-6FA2ED197652}']
    procedure LogError(aMsg: string);
  end;

  TLogger = class(TInterfacedObject, ILogger)
    procedure LogError(aMsg: string);
  end;

implementation

{ TLDSLoggerImpl }

procedure TLogger.LogError(aMsg: string);
var
  l: TLDSLogger;
begin
  l := TLDSLogger.Create(logFileName);
  try
    l.LogStr(aMsg, tlpError);
  finally
    l.Free;
  end;
end;

end.

