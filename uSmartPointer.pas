unit uSmartPointer;

interface

type
  ISmartPointer<T> = reference to function: T;

  TSmartPointer<T: class, constructor> = class(TInterfacedObject, ISmartPointer<T>)
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

constructor TSmartPointer<T>.Create;
begin
  inherited Create;
  FValue := T.Create;
end;

constructor TSmartPointer<T>.Create(AValue: T);
begin
  inherited Create;
  FValue := AValue;
end;

destructor TSmartPointer<T>.Destroy;
begin
  FValue.Free;
  inherited;
end;

function TSmartPointer<T>.Invoke: T;
begin
  Result := FValue;
end;

procedure TSmartPointer<T>.SetValue(const Value: T);
begin
  FValue := Value;
end;

function TSmartPointer<T>.Extract: T;
begin
  Result := FValue;
  FValue := nil;
end;

end.