unit uUniqueName;
{< this unit contains methods that will Create Unique Name}

interface

uses
  System.SysUtils, System.Classes, vcl.dialogs, System.RegularExpressions,
  StrUtils,uSmartPointer, System.IOUtils,Vcl.Forms;

type
  TUniqueName = class(TDataModule)
  private

    { Private declarations }
  public
    { Public declarations }
    function CreateUniqueNameAddingGUID(FileName: string; MaxOriginNameLength: Integer): string;
    {< CreateUniqueNameAddingGUID - all clear from the name. This is class function}
    function AddNumberOnTheEnd(ANameWithNumberOnTheEnd: string): string;
    function CreateUniqueNameAddingNumber(ANamesToCompare: TStringList; ANameThatShouldBeUnique: string): string; overload;
    function CreateUniqueNameAddingNumber(ADirectory: string; ANameThatShouldBeUnique: string): string; overload;
    {< this method will Create Unique Name like SomeName(1),SomeName(2), Etc.}
    function IsFileNameUnique(ANameThatShouldBeUnique: string; AAllNamesToCompareSL: TStringList): boolean;
    {< this method will Create Unique Name like SomeName(1),SomeName(2), Etc.}
    function AddParamAndValueToName(aFileName, aParam, aValue: string): string;
    {<this will add Param=Value to someName }
    function GetParamValueFromFileName(FileName: string; const ParamName: string): string;
    {<this will get ParamValue from Name like Param=Value   }
    function GetNumberInBracketsFromTheEnd(AFileName: string): string;
    function FindAllOffsetsOfSubstrings(ASomeString: string; ASomeSubString: string): TStringList;
    function GetSubStringWithoutLastBracketsInTheEnd(ASomeString, AValueInBrackets: string): string;
    function IsValueInBracketsAtEndOfString(ASomeString, AValueInBrackets: string): Boolean;
    function GetStringWithoutExtension(AFileName: string; var ext: string): string;
  end;

//var
//  CreateUniqueName: TCreateUniqueName;

implementation

uses
  System.Types;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{ TCreateUniqueName }

{Creating New Unique Name with a rest of old name, using GUID}
function TUniqueName.CreateUniqueNameAddingGUID(FileName: string; MaxOriginNameLength: Integer): string;
var
  ext: string;
  splittedString: TArray<string>;
  someStringToChange: string;
  newguid: tguid;
  i: Integer;
  fileNameTemp: string;
begin
//Checks
  if FileName = '' then
    Exit;
//if MaxOriginNameLength=0 then exit;  // if MaxOriginNameLength=0 will be only GUID as a result
//1--------- First of all we need to extract extension if it is
  splittedString := FileName.Split(['.']);
    //we suppose that extensions are symbols after last '.', so...
    // if FileName has extension like 'SomeFileName.exe'
  if Length(splittedString) > 0 //1 and more, for example somename.ext [somename,ext]
    then
  begin
    ext := splittedString[High(splittedString)];
    //Lets join everything except extension
    for i := Low(splittedString) to High(splittedString) - 1 do
    begin
      if i = 0 then
        someStringToChange := someStringToChange + splittedString[i]
      else
        someStringToChange := someStringToChange + '.' + splittedString[i];
    end;
         //Cutting name up to the MaxOriginNameLength
    if Length(someStringToChange) > MaxOriginNameLength then
      someStringToChange := someStringToChange.Substring(0, MaxOriginNameLength);
      //Adding GUID
    Createguid(newguid);
    someStringToChange := someStringToChange + newguid.ToString;
      // Joining Extension
    someStringToChange := someStringToChange + '.' + ext;
    Result := someStringToChange;
  end
  else
     // if FileName without Extension like 'SomeFileName'
if Length(splittedString) = 0 then
  begin
    fileNameTemp := FileName;
      //Cutting name up to the MaxOriginNameLength
    if Length(fileNameTemp) > MaxOriginNameLength then
      fileNameTemp := fileNameTemp.Substring(0, MaxOriginNameLength);
      //Adding GUID
    Createguid(newguid);
    fileNameTemp := fileNameTemp + newguid.ToString;
    Result := fileNameTemp;
  end;
//ShowMessage(Result);
end;

function TUniqueName.CreateUniqueNameAddingNumber(ADirectory: string; ANameThatShouldBeUnique: string): string;
var files : ISmartPointer<TStringList>;
    a: TStringDynArray;
  i: Integer;
begin
  // getting files
  files := TSmartPointer<TStringList>.Create();
  a := TDirectory.GetFiles(ExtractFilePath(Application.ExeName) + ADirectory);
  for i := Low(a) to High(a) do
    files.add(ExtractFileName(a[i]));
  // Creating Unique Name
  Result := ANameThatShouldBeUnique;
  if files.IndexOf(ANameThatShouldBeUnique) = -1 then
  begin
    Result := ANameThatShouldBeUnique; // Already Unique
    Exit;
  end
  else
    repeat
      Result := AddNumberOnTheEnd(Result);
    until files.IndexOf(Result) = -1;
end;

function TUniqueName.CreateUniqueNameAddingNumber(ANamesToCompare: TStringList; ANameThatShouldBeUnique: string): string;
begin
  Result := ANameThatShouldBeUnique;
  if ANamesToCompare.IndexOf(ANameThatShouldBeUnique) = -1 then
  begin
    Result := ANameThatShouldBeUnique; // Already Unique
    Exit;
  end
  else
    repeat
      Result := AddNumberOnTheEnd(Result);
    until ANamesToCompare.IndexOf(Result) = -1;
end;

function TUniqueName.AddNumberOnTheEnd(ANameWithNumberOnTheEnd: string): string;
var
  SplittedString: TArray<string>;
  i: integer;
  NameWithoutExtension: string;
  NumberInTheEnd: Integer;
  SubStringWithoutLastBrackets: string;
  StringWithoutExtension: string;
  Extension: string;
  StringWithoutBracketsInTheEnd: string;
begin
// Check of Uniquiness
  StringWithoutExtension := GetStringWithoutExtension(ANameWithNumberOnTheEnd, Extension);
  if GetNumberInBracketsFromTheEnd(ANameWithNumberOnTheEnd) = '' then
  begin
    Result := StringWithoutExtension + '(1)'; // adding first number
    if Extension <> '' then
      Result := Result + '.' + Extension;
  end
  else
  begin
    NumberInTheEnd := GetNumberInBracketsFromTheEnd(StringWithoutExtension).ToInteger;
    if IsValueInBracketsAtEndOfString(StringWithoutExtension, NumberInTheEnd.ToString()) then
    begin
      StringWithoutBracketsInTheEnd := GetSubStringWithoutLastBracketsInTheEnd(StringWithoutExtension, NumberInTheEnd.ToString());
      NumberInTheEnd := NumberInTheEnd + 1;
      Result := StringWithoutBracketsInTheEnd + '(' + NumberInTheEnd.ToString() + ')';
    end
    else
    begin
      Result := ANameWithNumberOnTheEnd + '(1)'; // adding first number
    end;
    if Extension <> '' then
      Result := Result + '.' + Extension;
  end;
end;

function TUniqueName.GetStringWithoutExtension(AFileName: string; var ext: string): string;
var
  SplittedString: TArray<string>;
  i: Integer;
begin
  SplittedString := AFileName.Split(['.']);
      // if some Extension is...
  if High(SplittedString) >= 1 then
  begin
        //Gather all splitted elements except extension
    Result := '';
    for i := 0 to High(SplittedString) - 1 do
    begin
      Result := Result + SplittedString[i];
    end;
          // Remembering Extension;
    ext := SplittedString[High(SplittedString)];
  end
  else
  begin
    Result := AFileName;
    ext := '';
  end;
end;

function TUniqueName.GetNumberInBracketsFromTheEnd(AFileName: string): string;
var
  RegEx: TRegEx;
  M: TMatchCollection;
  s: string;
  NumberInBrackets: string;
  RegEx2: TRegEx;
  M2: TMatchCollection;
begin
  Result := '';
  RegEx := TRegEx.Create('\([\d]+\)'); // Extracting (1) from SomeFile(1) - will receive (1)
  M := RegEx.Matches(AFileName);
  if M.Count > 0 then
  begin
    NumberInBrackets := M.Item[M.Count - 1].Value; // Extracting Last One
  end;
  RegEx2 := TRegEx.Create('[\d]+'); // Extracting 1 from  (1)
  M2 := RegEx2.Matches(NumberInBrackets);
  if M2.Count > 0 then
  begin
    Result := M2.Item[M.Count - 1].Value; // Extracting Last One
  end;
end;

function TUniqueName.FindAllOffsetsOfSubstrings(ASomeString: string; ASomeSubString: string): TStringList;
var
  Len: Integer;
  P: Integer;
begin
  Result := TStringList.Create;
//
  Len := Length(ASomeSubString);
  P := PosEx(ASomeSubString, ASomeString, 1);
  while P > 0 do
  begin
    Result.Add(P.ToString());
    P := PosEx(ASomeSubString, ASomeString, P + Len); // Recursievely call this for next possible substring
  end;
end;

function TUniqueName.GetSubStringWithoutLastBracketsInTheEnd(ASomeString: string; AValueInBrackets: string): string;
begin
//
  if (ASomeString.Length > 0) and (AValueInBrackets.Length > 0) and (ASomeString.Length - AValueInBrackets.Length >= 3) // 3 means (1) for example
    then
    Result := ASomeString.Substring(0, ASomeString.Length - AValueInBrackets.Length - 2); // -2 means brackets around value for ex. (1)
end;

function TUniqueName.IsValueInBracketsAtEndOfString(ASomeString: string; AValueInBrackets: string): Boolean;
var
  valueInBrackets: string;
  endOfString: string;
begin
  Result := false;
  if ASomeString.Length >= valueInBrackets.Length then
  begin
    valueInBrackets := '(' + AValueInBrackets + ')';
    endOfString := ASomeString.Substring(ASomeString.Length - valueInBrackets.Length);
    if endOfString = valueInBrackets then
      Result := True;
  end;
end;

// {Adding Params to FileName, so FileName.exe will be FileName{Param=Value}.exe }
function TUniqueName.AddParamAndValueToName(aFileName: string; aParam: string; aValue: string): string;
var
  ext: string;
  splittedString: TArray<string>;
  SomeStringToChange: string;
  i: Integer;
  FileNameTemp: string;
begin
//Checks
  if aFileName = '' then
    Exit;
//1--------- First of all we need to extract extension if it is
  splittedString := aFileName.Split(['.']);
    //we suppose that extensions are symbols after last '.', so...
    // if FileName has extension like 'SomeFileName.exe'
  if Length(splittedString) > 1 //2 and more, for example somename.ext [somename,ext]
    then
  begin
    ext := splittedString[High(splittedString)];
//ShowMessage(Extension); // for test
//2----------Now lets change previous massive Element if it is
    SomeStringToChange := splittedString[High(splittedString) - 1];
      //Adding Param And Value
    SomeStringToChange := SomeStringToChange + '{' + aParam + '=' + aValue + '}';
    splittedString[High(splittedString) - 1] := SomeStringToChange;
//3-------Now our name is Unique we can join it back
    Result := '';
    for i := Low(splittedString) to High(splittedString) - 1 do
      Result := Result + splittedString[i] + '.';
    //At last adding Extension
    Result := Result + ext;
  end
  else
  // if FileName without Extension like 'SomeFileName'
if Length(splittedString) = 1 then
  begin
    FileNameTemp := aFileName;
    FileNameTemp := FileNameTemp + '{' + aParam + '=' + aValue + '}';
    Result := FileNameTemp;
  end;
//ShowMessage(Result); //for test
end;


{Get Param Value from FileName}
function TUniqueName.GetParamValueFromFileName(FileName: string; const ParamName: string): string;
var
  RegEx: TRegEx;
  M: TMatchCollection;
  M2: TMatchCollection;
  M3: TMatchCollection;
begin
  Result := '';
  M := RegEx.Matches(FileName, '{' + ParamName + '=[\w\d]*}'); //chunkNumber=[\w\d]*[\d]\b //chunkNumber=[\w]*[\d]\b
  if M.Count > 0 then
    M2 := RegEx.Matches(M.Item[M.Count - 1].Value, '=[\w\d]*');
  if M2.Count > 0 then
    M3 := RegEx.Matches(M2.Item[M2.Count - 1].Value, '[\w\d]*');
  if M3.Count > 0 then
    Result := M3.Item[M3.Count - 1].Value;
end;

function TUniqueName.IsFileNameUnique(ANameThatShouldBeUnique: string; AAllNamesToCompareSL: TStringList): boolean;
var
  splittedString: TArray<string>;
  i: Integer;
begin
  Result := false;
  if AAllNamesToCompareSL.IndexOf(ANameThatShouldBeUnique) = -1 then
    Result := true;
end;

end.

