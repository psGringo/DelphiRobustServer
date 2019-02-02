unit uCommon;

interface

type
  ISP<T> = reference to function: T;

  TSP<T: class, constructor> = class(TInterfacedObject, ISP<T>)
  private
    FValue: T;
    function Invoke: T;
    procedure SetValue(const Value: T);
  public
    constructor Create; overload;
    constructor Create(AValue: T); overload;
    destructor Destroy; override;
    function Extract: T;
    property Value: T read FValue write SetValue;
  end;

implementation

constructor TSP<T>.Create;
begin
  inherited Create;
  FValue := T.Create;
end;

constructor TSP<T>.Create(AValue: T);
begin
  inherited Create;
  FValue := AValue;
end;

destructor TSP<T>.Destroy;
begin
  FValue.Free;
  inherited;
end;

function TSP<T>.Invoke: T;
begin
  Result := FValue;
end;

procedure TSP<T>.SetValue(const Value: T);
begin
  FValue := Value;
end;

function TSP<T>.Extract: T;
begin
  Result := FValue;
  FValue := nil;
end;

end.
