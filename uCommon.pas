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
    procedure LogInfo(aMsg: string);
  end;

  TLogger = class(TInterfacedObject, ILogger)
    procedure LogError(aMsg: string);
    procedure LogInfo(aMsg: string);
    procedure UpdateMainLogMemo();
  end;

implementation

uses
  uMain, uSmartPointer;
{ TLDSLoggerImpl }

procedure TLogger.LogError(aMsg: string);
var
  l: TLDSLogger;
begin
  l := TLDSLogger.Create(logFileName);
  try
    l.LogStr(aMsg, tlpError);
    UpdateMainLogMemo;
  finally
    l.Free;
  end;
end;

procedure TLogger.LogInfo(aMsg: string);
var
  l: TLDSLogger;
begin
  l := TLDSLogger.Create(logFileName);
  try
    l.LogStr(aMsg, tlpInformation);
    UpdateMainLogMemo;
  finally
    l.free;
  end;
end;

procedure TLogger.UpdateMainLogMemo;
var
  fs: TFileStream;
  ss: ISmartPointer<TstringStream>;
  sl: ISmartPointer<TStringList>;
  i: Integer;
begin
  fs := nil;
  fs := WaitAndCreateLogFileStream(logFileName, fmOpenRead, -1);
  ss := TSmartPointer<TstringStream>.Create();
  sl := TSmartPointer<TStringList>.Create();
  try
    ss.LoadFromStream(fs);
    Main.mLog.Lines.Text := ss.DataString;
    sl.Assign(Main.mLog.Lines);
    Main.mLog.Lines.Clear;
    for i := sl.Count - 1 downto 0 do
      Main.mLog.Lines.Add(sl[i]);
  finally
    fs.Free;
  end;
end;

end.

