unit uDecodePostRequest;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdCustomHTTPServer, IdHTTPServer, Vcl.StdCtrls, HTTPApp, IdMultipartFormData,
  IdContext, System.IOUtils, System.NetEncoding, superobject, Contnrs;

type
  TQuery = record
    params: TStringList;
    values: TStringList;
  end;

type
  TDecodePostRequest = class(TDataModule)
  private
    Params: TStringList;
    Query: TQuery;
    FIP: string;
    function ReadMultipartRequest(const Boundary: Ansistring; ARequest: Ansistring; var AHeader: TStringList; var Data: Ansistring): Ansistring;
    procedure QueryParsing(list: TStrings; var params, values: TStringList);
    procedure QueryPreParsing(s: string; var res: TStringList);
    procedure SetIP(const Value: string);
    procedure ParseJson(const aAsObject: TSuperTableString; var postParams: TStringList);
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DecodePostParamsAnsi(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var aPostParams: TStringList);
    procedure ReceiveFile(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; aRelUploadDir: string); overload;
    procedure ReceiveFile(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; dir: string; FileNameOnServer: string); overload;
    property IP: string read FIP write SetIP;
  end;

implementation

function OleVariantToString(const Value: OleVariant): string;
var
  ss: TStringStream;
  Size: integer;
  Data: PByteArray;
begin
  Result := '';
  if Length(Value) = 0 then
    Exit;
  ss := TStringStream.Create;
  try
    Size := VarArrayHighBound(Value, 1) - VarArrayLowBound(Value, 1) + 1;
    Data := VarArrayLock(Value);
    try
      ss.Position := 0;
      ss.WriteBuffer(Data^, Size);
      ss.Position := 0;
      Result := ss.DataString;
    finally
      VarArrayUnlock(Value);
    end;
  finally
    ss.Free;
  end;
end;

procedure TDecodePostRequest.DecodePostParamsAnsi(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; var aPostParams: TStringList);
const
  MaxReadBlockSize = 8192;
  UploadPath = '';
var
  ms: TMemoryStream;
  Boundary, bufferStr, allContent: Ansistring;
  Header: TStringList;
  ByteToRead, ReadedBytes, RSize: Integer;
  Buffer: PAnsiChar;
  Data: Ansistring;
  HList: TStrings;
  ss: TStringStream;
  i: Integer;
  obj: ISuperobject;
  s: string;
//  item: TSuperAvlEntry;
begin

  AResponseInfo.Server := 'ver1';
  AResponseInfo.CacheControl := 'no-cache';

//  if ARequestInfo.Host = IP then // '40.85.142.196:40000') then
  begin
   // if(ARequestInfo.Document = '/index.php')  then
    begin
      if (Pos('multipart/form-data', LowerCase(ARequestInfo.ContentType)) > 0) and     // ����� ��� ��������� multipart
        (Pos('boundary', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        Header := TStringList.Create;
        try
          ExtractHeaderFields([';'], [' '], PChar(ARequestInfo.ContentType), Header, False, False);
          Boundary := Header.Values['boundary'];
        finally
          Header.Free;
        end;
        ms := TMemoryStream.Create;
        ss := TstringStream.create(bufferStr);
        try
          ms.LoadFromStream(ARequestInfo.PostStream);
          allContent := '';
          ByteToRead := ARequestInfo.ContentLength;
          try
            while ByteToRead > 0 do
            begin
              RSize := MaxReadBlockSize;
              if RSize > ByteToRead then
                RSize := ByteToRead;
              GetMem(Buffer, RSize);
              try
                ReadedBytes := ms.Read(Buffer^, RSize);
                ss.LoadFromStream(ms);
               // ov:=ss.DataString;
               // BufferStr:=OleVariantToString(ov);
                bufferStr := ss.DataString;
                //BufferStr:= (BufferStr);
               // SetString(BufferStr, Buffer, ReadedBytes);
                allContent := allContent + bufferStr;
              finally
                FreeMem(Buffer, RSize);
              end;
              ByteToRead := ARequestInfo.ContentLength - Length(allContent);

            end;
          //  AResponseInfo.ContentText := 'ok';
           // AResponseInfo.WriteContent;
          except
            on E: Exception do
            begin
              raise Exception.Create(E.ClassName + ' Exception Raised : ' + #13#10 + #13#10 + E.Message);
              AResponseInfo.ContentText := E.Message;
              AResponseInfo.WriteContent;
            end;
          end;
        finally
          ms.Free;
          ss.Free;
        end;
        if ARequestInfo.ContentLength = Length(allContent) then
          while Length(allContent) > Length('--' + Boundary + '--' + #13#10) do
          begin
            Header := TStringList.Create;
            HList := TStringList.Create;
            try
              allContent := ReadMultipartRequest('--' + Boundary, allContent, Header, Data);
              ExtractHeaderFields([';'], [' '], PChar(Header.Values['Content-Disposition']), HList, False, True);
              if (Header.Values['Content-Type'] <> '') and (Data <> '') and (HList.Values['filename'] <> '') // << corrected here
                then
              begin
              { // not creating file here
                OutStream:=TFileStream.Create(UploadPath +
                  ExtractFileName(HList.Values['filename']), fmCreate);
                try
                  try
                    OutStream.WriteBuffer(Pointer(Data)^, Length(Data));
                    HTTPServer_Main_UnitVar.mmo3.Lines.Add('File Successfully Uploaded');
                  except
                    on E:Exception do
                    ShowMessage(E.ClassName+' Exception Raised : '
                    +#13#10+#13#10+E.Message);
                  end;
                finally
                  OutStream.Free;
                end

              }
              end
              else
              begin
              //Removing ='#$D#$A'

                Data := StringReplace(Data, '='#$D#$A'', '', [rfReplaceAll]);
                Data := StringReplace(Data, ''#$D#$A'', '', [rfReplaceAll]);
                Data := StringReplace(Data, ''#$D#$A#$D#$A'', '', [rfReplaceAll]);

                Data := TNetEncoding.URL.Decode(Data);
               { logging here
                if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
                begin

                  if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo3) then
                    PS_HTTPFileServerAddon_UnitVar.mmo3.Lines.Add(Format('<p>Field <b>%s</b> = %s', [HList.Values['name'], Data]));
                end;
               }
              // Collecting Post Params in External Var
                aPostParams.Add(HList.Values['name'] + '=' + Data); // // PS Gathering Params Here
              end;
            finally

              { logging
              if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
              begin

                if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo1) then
                  PS_HTTPFileServerAddon_UnitVar.mmo1.Lines := Header;
                if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo2) then
                  PS_HTTPFileServerAddon_UnitVar.mmo2.Lines := HList;
              end;
              }
              Header.Free;
              HList.Free;
            end;
          end;
      end;

      if (Pos('application/x-www-form-urlencoded', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        ms := TMemoryStream.Create;
        try
          ms.LoadFromStream(ARequestInfo.PostStream);
          allContent := '';
          ByteToRead := ARequestInfo.ContentLength;
          try
            while ByteToRead > 0 do
            begin
              RSize := MaxReadBlockSize;
              if RSize > ByteToRead then
                RSize := ByteToRead;
              GetMem(Buffer, RSize);
              try
                ReadedBytes := ms.Read(Buffer^, RSize);
                SetString(bufferStr, Buffer, ReadedBytes);
                allContent := allContent + bufferStr;
              finally
                FreeMem(Buffer, RSize);
              end;
              ByteToRead := ARequestInfo.ContentLength - Length(allContent);
            end;
                //  AResponseInfo.ContentText := 'ok';
                //  AResponseInfo.WriteContent;
          except
            on E: Exception do
            begin
              raise Exception.Create(' Exception Raised = ' + 'Class=' + E.ClassName + #13#1 + #13#10 + '  Message=' + E.Message);
              AResponseInfo.ContentText := E.Message;
              AResponseInfo.WriteContent;
            end;
          end;
        finally
          ms.Free;
        end;
        QueryPreParsing(allContent, Params);
        QueryParsing(Params, Query.params, Query.values);
        //
        for i := 0 to Query.values.Count - 1 do
        begin
          Query.values[i] := StringReplace(Query.values[i], '='#$D#$A'', '', [rfReplaceAll]);
          Query.values[i] := StringReplace(Query.values[i], ''#$D#$A'', '', [rfReplaceAll]);
          Query.values[i] := StringReplace(Query.values[i], ''#$D#$A#$D#$A'', '', [rfReplaceAll]);
          Query.values[i] := TNetEncoding.URL.Decode(Query.values[i]);
        end;
      end;
      //
      if (Pos('application/json', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        ms := TMemoryStream.Create;
        ss := TStringStream.Create;
        try
          ms.LoadFromStream(ARequestInfo.PostStream);
          ss.LoadFromStream(ARequestInfo.PostStream);
          s := ss.DataString;
          s := TNetEncoding.URL.Decode(s);
          allContent := '';
          ByteToRead := ARequestInfo.ContentLength;
          try
            while ByteToRead > 0 do
            begin
              RSize := MaxReadBlockSize;
              if RSize > ByteToRead then
                RSize := ByteToRead;
              GetMem(Buffer, RSize);
              try
                ReadedBytes := ms.Read(Buffer^, RSize);
                SetString(bufferStr, Buffer, ReadedBytes);
                allContent := allContent + bufferStr;
              finally
                FreeMem(Buffer, RSize);
              end;
              ByteToRead := ARequestInfo.ContentLength - Length(allContent);
            end;
                //  AResponseInfo.ContentText := 'ok';
                //  AResponseInfo.WriteContent;
          except
            on E: Exception do
            begin
              raise Exception.Create(' Exception Raised = ' + 'Class=' + E.ClassName + #13#1 + #13#10 + '  Message=' + E.Message);
              AResponseInfo.ContentText := E.Message;
              AResponseInfo.WriteContent;
            end;
          end;
        finally
          ms.Free;
          ss.Free;
        end;

        // parse json...
        obj := SO(TNetEncoding.URL.Decode(allContent));
        ParseJson(obj.AsObject, aPostParams);

        {
        QueryPreParsing(allContent, Params);
        QueryParsing(Params, Query.params, Query.values);
        //
        for i := 0 to Query.values.Count - 1 do
        begin
          Query.values[i] := StringReplace(Query.values[i], '='#$D#$A'', '', [rfReplaceAll]);
          Query.values[i] := StringReplace(Query.values[i], ''#$D#$A'', '', [rfReplaceAll]);
          Query.values[i] := StringReplace(Query.values[i], ''#$D#$A#$D#$A'', '', [rfReplaceAll]);
          Query.values[i] := TNetEncoding.URL.Decode(Query.values[i]);
        end;
        }
      end;
    end;
  end;
end;

procedure TDecodePostRequest.ParseJson(const aAsObject: TSuperTableString; var postParams: TStringList);
//https://stackoverflow.com/questions/14082886/superobject-extract-all
var
  Names: ISuperObject;
  Name: string;
  Items: ISuperObject;
  Item: ISuperObject;
  idx: Integer;
  Value: string;
  ArrayItem: ISuperObject;
begin
  if Assigned(aAsObject) then
  begin
    Names := aAsObject.GetNames;
    Items := aAsObject.GetValues;

    for idx := 0 to Items.AsArray.Length - 1 do
    begin
      Name := Names.AsArray[idx].AsString;
      Item := Items.AsArray[idx];
      if Item.DataType = stObject then
        Value := '<Object>'
      else if Item.DataType = stArray then
        Value := '<Array>'
      else
        Value := Item.AsString;

      postParams.Add(Name + '=' + Value);

      //if SameText(Name, 'id') then
       // WriteLn(Format('%s: %s', [aPrefix + Name, Value]));

       {
      if Item.DataType = stArray then
        for ArrayItem in Item do
          ProcessObject(ArrayItem.AsObject, aPrefix + Name + '.');

      if Item.DataType = stObject then
        ProcessObject(Item.AsObject, aPrefix + Name + '.');
        }
    end;
  end;
end;

//---------------Decode params and receive file

procedure TDecodePostRequest.ReceiveFile(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; aRelUploadDir: string);
const
  MaxReadBlockSize = 8192;
var
  ms: TMemoryStream;
  Boundary, BufferStr, AllContent: Ansistring;
  Header: TStringList;
  ByteToRead, ReadedBytes, RSize: Integer;
  Buffer: PAnsiChar;
  Data: Ansistring;
  HList: TStrings;
  OutStream: TFileStream;
  UploadPath: string;
begin
  AResponseInfo.Server := 'ver1';
  AResponseInfo.CacheControl := 'no-cache';
  //HTTPServerToRequest
//  if ARequestInfo.Host = IP then // '40.85.142.196:40000') then
  begin
   // if(ARequestInfo.Document = '/index.php')  then
    begin
      if (Pos('multipart/form-data', LowerCase(ARequestInfo.ContentType)) > 0) and     // ����� ��� ��������� multipart
        (Pos('boundary', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        Header := TStringList.Create;
        try
          ExtractHeaderFields([';'], [' '], PChar(ARequestInfo.ContentType), Header, False, False);
          Boundary := Header.Values['boundary'];
        finally
          Header.Free;
        end;
        ms := TMemoryStream.Create;
        try
          ms.LoadFromStream(ARequestInfo.PostStream);
          AllContent := '';
          ByteToRead := ARequestInfo.ContentLength;
//          try
          while ByteToRead > 0 do
          begin
            RSize := MaxReadBlockSize;
            if RSize > ByteToRead then
              RSize := ByteToRead;
            GetMem(Buffer, RSize);
            try
              ReadedBytes := ms.Read(Buffer^, RSize);
              SetString(BufferStr, Buffer, ReadedBytes);
              AllContent := AllContent + BufferStr;
            finally
              FreeMem(Buffer, RSize);
            end;
            ByteToRead := ARequestInfo.ContentLength - Length(AllContent);
          end;
          //  AResponseInfo.ContentText := 'ok';
          //  AResponseInfo.WriteContent;
          {
          except
            on E: Exception do
            begin
              AResponseInfo.ContentText := E.Message;
              AResponseInfo.WriteContent;
            end;
          end;
          }
        finally
          ms.Free;
        end;

        if ARequestInfo.ContentLength = Length(AllContent) then
          while Length(AllContent) > Length('--' + Boundary + '--' + #13#10) do
          begin
            Header := TStringList.Create;
            HList := TStringList.Create;
            try
              AllContent := ReadMultipartRequest('--' + Boundary, AllContent, Header, Data);
              ExtractHeaderFields([';'], [' '], PChar(Header.Values['Content-Disposition']), HList, False, True);
              if (Header.Values['Content-Type'] <> '') and (Data <> '') and (HList.Values['filename'] <> '') // << corrected here
                then
              begin
                UploadPath := '';
                if aRelUploadDir <> '' then
                begin
                 //Check if dir exists and create it if not
                  if not TDirectory.Exists(ExtractFileDir(Application.ExeName) + '\' + aRelUploadDir) then
                    TDirectory.CreateDirectory(ExtractFileDir(Application.ExeName) + '\' + aRelUploadDir);
                  UploadPath := ExtractFileDir(Application.ExeName) + '\' + aRelUploadDir + '\';
                  OutStream := TFileStream.Create(UploadPath + ExtractFileName(HList.Values['filename']), fmCreate);
                end;
                try
                  try
                    OutStream.WriteBuffer(Pointer(Data)^, Length(Data));
                    { logging
                    if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
                    begin
                      if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo3) then
                        PS_HTTPFileServerAddon_UnitVar.mmo3.Lines.Add('File Successfully Uploaded');
                    end;
                    }
                  except
                    on E: EStreamError do
                    begin
                      raise Exception.Create('This is EStreamError EClassName' + E.ClassName + ' ' + 'EMessage ' + E.Message);
                     // AResponseInfo.ContentText := E.Message;
                     // AResponseInfo.WriteContent;
                    end;
                    on E: Exception do
                    begin
                      raise Exception.Create(E.ClassName + ' Exception Raised : ' + #13#10 + #13#10 + E.Message);
                     // AResponseInfo.ContentText := E.Message;
                     // AResponseInfo.WriteContent;
                    end;
                  end;
                finally
                  OutStream.Free;
                end
              end
              else
              begin
                { // logging
                if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
                begin
                  if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo3) then
                    PS_HTTPFileServerAddon_UnitVar.mmo3.Lines.Add(Format('<p>Field <b>%s</b> = %s', [HList.Values['name'], Data]));
                end;
                }
              end;
            finally
              { // logging
              if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
              begin
                if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo1) then
                  PS_HTTPFileServerAddon_UnitVar.mmo1.Lines := Header;
                if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo2) then
                  PS_HTTPFileServerAddon_UnitVar.mmo2.Lines := HList;
              end;
              }
              Header.Free;
              HList.Free;
            end;
          end;
      end;

      if (Pos('application/x-www-form-urlencoded', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        ms := TMemoryStream.Create;
        try
          ms.LoadFromStream(ARequestInfo.PostStream);
          AllContent := '';
          ByteToRead := ARequestInfo.ContentLength;
          try
            while ByteToRead > 0 do
            begin
              RSize := MaxReadBlockSize;
              if RSize > ByteToRead then
                RSize := ByteToRead;
              GetMem(Buffer, RSize);
              try
                ReadedBytes := ms.Read(Buffer^, RSize);
                SetString(BufferStr, Buffer, ReadedBytes);
                AllContent := AllContent + BufferStr;
              finally
                FreeMem(Buffer, RSize);
              end;
              ByteToRead := ARequestInfo.ContentLength - Length(AllContent);
            end;
          //  AResponseInfo.ContentText := 'ok';
          //  AResponseInfo.WriteContent;
          except
            on E: EStreamError do
            begin
              raise Exception.Create('This is EStreamError EClassName' + E.ClassName + ' ' + 'EMessage ' + E.Message);
              AResponseInfo.ContentText := E.Message;
              AResponseInfo.WriteContent;
            end;
            on E: Exception do
            begin
              raise Exception.Create(E.ClassName + ' Exception Raised : ' + #13#10 + #13#10 + E.Message);
              //AResponseInfo.ContentText := E.Message;
              //AResponseInfo.WriteContent;
            end;
          end;
        finally
          ms.Free;
        end;
        QueryPreParsing(AllContent, Params);
        QueryParsing(Params, Query.params, Query.values);

        { logging
        if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
        begin
          if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo1) then
            PS_HTTPFileServerAddon_UnitVar.mmo1.Lines := Query.params;
          if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo2) then
            PS_HTTPFileServerAddon_UnitVar.mmo2.Lines := Query.values;
        end;
         }
      end;

    end;
  end;

end;


//-------------------------------------------------

function TDecodePostRequest.ReadMultipartRequest(const Boundary: Ansistring; ARequest: Ansistring; var AHeader: TStringList; var Data: Ansistring): Ansistring;
var
  Req, RHead: string;
  i: Integer;
begin
  Result := '';
  AHeader.Clear;
  Data := '';

  if (Pos(Boundary, ARequest) < Pos(Boundary + '--', ARequest)) and (Pos(Boundary, ARequest) = 1) then
  begin
    Delete(ARequest, 1, Length(Boundary) + 2);
    Req := Copy(ARequest, 1, Pos(Boundary, ARequest) - 3);
    Delete(ARequest, 1, Length(Req) + 2);
    RHead := Copy(Req, 1, Pos(#13#10#13#10, Req) - 1);

    Delete(Req, 1, Length(RHead) + 4);
    AHeader.Text := RHead;
    for i := 0 to AHeader.Count - 1 do
      if Pos(':', AHeader.Strings[i]) > 0 then
        AHeader.Strings[i] := Trim(Copy(AHeader.Strings[i], 1, Pos(':', AHeader.Strings[i]) - 1)) + '=' + Trim(Copy(AHeader.Strings[i], Pos(':', AHeader.Strings[i]) + 1, Length(AHeader.Strings[i]) - Pos(':', AHeader.Strings[i])));
    Data := Req;
    Result := ARequest;
  end
end;

procedure TDecodePostRequest.ReceiveFile(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo; dir, FileNameOnServer: string);
const
  MaxReadBlockSize = 8192;
var
  ms: TMemoryStream;
  Boundary, BufferStr, AllContent: Ansistring;
  Header: TStringList;
  ByteToRead, ReadedBytes, RSize: Integer;
  Buffer: PAnsiChar;
  Data: Ansistring;
  HList: TStrings;
  outStream: TFileStream;
  UploadPath: string;
begin
  AResponseInfo.Server := 'ver1';
  AResponseInfo.CacheControl := 'no-cache';

//  if ARequestInfo.Host = FIP then // '40.85.142.196:40000') then
  begin
   // if(ARequestInfo.Document = '/index.php')  then
    begin
      if (Pos('multipart/form-data', LowerCase(ARequestInfo.ContentType)) > 0) and     // ����� ��� ��������� multipart
        (Pos('boundary', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        Header := TStringList.Create;
        try
          ExtractHeaderFields([';'], [' '], PChar(ARequestInfo.ContentType), Header, False, False);
          Boundary := Header.Values['boundary'];
        finally
          Header.Free;
        end;
        ms := TMemoryStream.Create;
        try
          ms.LoadFromStream(ARequestInfo.PostStream);
          AllContent := '';
          ByteToRead := ARequestInfo.ContentLength;
          try
            while ByteToRead > 0 do
            begin
              RSize := MaxReadBlockSize;
              if RSize > ByteToRead then
                RSize := ByteToRead;
              GetMem(Buffer, RSize);
              try
                ReadedBytes := ms.Read(Buffer^, RSize);
                SetString(BufferStr, Buffer, ReadedBytes);
                AllContent := AllContent + BufferStr;
              finally
                FreeMem(Buffer, RSize);
              end;
              ByteToRead := ARequestInfo.ContentLength - Length(AllContent);
            end;
          //  AResponseInfo.ContentText := 'ok';
          //  AResponseInfo.WriteContent;
          except
            on E: Exception do
            begin
             // AResponseInfo.ContentText := E.Message;
             // AResponseInfo.WriteContent;
            end;
          end;
        finally
          ms.Free;
        end;

        if ARequestInfo.ContentLength = Length(AllContent) then
          while Length(AllContent) > Length('--' + Boundary + '--' + #13#10) do
          begin
            Header := TStringList.Create;
            HList := TStringList.Create;
            try
              AllContent := ReadMultipartRequest('--' + Boundary, AllContent, Header, Data);
              ExtractHeaderFields([';'], [' '], PChar(Header.Values['Content-Disposition']), HList, False, True);
              if (Header.Values['Content-Type'] <> '') and (Data <> '') and (HList.Values['filename'] <> '') // << corrected here
                then
              begin
                UploadPath := '';
                if dir <> '' then
                begin
                 //Check if dir exists and create it if not
                  if not TDirectory.Exists(ExtractFileDir(Application.ExeName) + '\' + dir) then
                    TDirectory.CreateDirectory(ExtractFileDir(Application.ExeName) + '\' + dir);
                  UploadPath := ExtractFileDir(Application.ExeName) + '\' + dir + '\';
                  outStream := TFileStream.Create(UploadPath + FileNameOnServer, fmCreate);
                 //ExtractFileName(HList.Values['filename']), fmCreate);
                end;
                try
                  try
                    outStream.WriteBuffer(Pointer(Data)^, Length(Data));
                    {
                    if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
                    begin
                      if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo3) then
                        PS_HTTPFileServerAddon_UnitVar.mmo3.Lines.Add('File Successfully Uploaded');
                    end;
                    }
                  except
                    on E: EStreamError do
                    begin
                      raise Exception.Create('This is EStreamError EClassName' + E.ClassName + ' ' + 'EMessage ' + E.Message);
                      //AResponseInfo.ContentText := E.Message;
                      //AResponseInfo.WriteContent;
                    end;
                    on E: Exception do
                    begin
                      raise Exception.Create(E.ClassName + ' Exception Raised : ' + #13#10 + #13#10 + E.Message);
                      //AResponseInfo.ContentText := E.Message;
                      //AResponseInfo.WriteContent;
                    end;
                  end;
                finally
                  outStream.Free;
                end
              end

              else
              begin
               { logging
                if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
                begin
                  if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo3) then
                    PS_HTTPFileServerAddon_UnitVar.mmo3.Lines.Add(Format('<p>Field <b>%s</b> = %s', [HList.Values['name'], Data]));
                end;
               }
              end;
            finally
             { logging
              if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
              begin
                if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo1) then
                  PS_HTTPFileServerAddon_UnitVar.mmo1.Lines := Header;
                if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo2) then
                  PS_HTTPFileServerAddon_UnitVar.mmo2.Lines := HList;
              end;
              }
              Header.Free;
              HList.Free;
            end;
          end;
      end;

      if (Pos('application/x-www-form-urlencoded', LowerCase(ARequestInfo.ContentType)) > 0) then
      begin
        ms := TMemoryStream.Create;
        try
          ms.LoadFromStream(ARequestInfo.PostStream);

          AllContent := '';
          ByteToRead := ARequestInfo.ContentLength;

          try
            while ByteToRead > 0 do
            begin
              RSize := MaxReadBlockSize;
              if RSize > ByteToRead then
                RSize := ByteToRead;
              GetMem(Buffer, RSize);
              try
                ReadedBytes := ms.Read(Buffer^, RSize);
                SetString(BufferStr, Buffer, ReadedBytes);
                AllContent := AllContent + BufferStr;
              finally
                FreeMem(Buffer, RSize);
              end;
              ByteToRead := ARequestInfo.ContentLength - Length(AllContent);
            end;

          //  AResponseInfo.ContentText := 'ok';
          //  AResponseInfo.WriteContent;
          except

            on E: EStreamError do

            begin
              raise Exception.Create('This is EStreamError EClassName' + E.ClassName + ' ' + 'EMessage ' + E.Message);
              //AResponseInfo.ContentText := E.Message;
              //AResponseInfo.WriteContent;
            end;
            on E: Exception do
            begin
              raise Exception.Create(E.ClassName + ' Exception Raised : ' + #13#10 + #13#10 + E.Message);
              //AResponseInfo.ContentText := E.Message;
              //AResponseInfo.WriteContent;
            end;
          end;
        finally
          ms.Free;
        end;
        QueryPreParsing(AllContent, Params);
        QueryParsing(Params, Query.params, Query.values);
        {
        if PS_HTTPFileServerAddon_UnitVar.EnableLogging then
        begin
          if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo1) then
            PS_HTTPFileServerAddon_UnitVar.mmo1.Lines := Query.params;
          if Assigned(PS_HTTPFileServerAddon_UnitVar.mmo2) then
            PS_HTTPFileServerAddon_UnitVar.mmo2.Lines := Query.values;
        end;
        }
      end;

    end;
  end;

end;

procedure TDecodePostRequest.SetIP(const Value: string);
begin
  FIP := Value;
end;

//-------------------------Some Additional methods

procedure TDecodePostRequest.QueryPreParsing(s: string; var res: TStringList);
begin
  if (Pos('=', s) <= 0) then
  begin
    Exit;
  end;
end;

constructor TDecodePostRequest.Create(AOwner: TComponent);
begin
  inherited;
  Query.params := TStringList.Create;
  Query.values := TStringList.Create;
  Params := TStringList.Create;
end;

destructor TDecodePostRequest.Destroy;
begin
  inherited;
  FreeAndNil(Query.params);
  FreeAndNil(Query.values);
  FreeAndNil(Params);
end;

procedure TDecodePostRequest.QueryParsing(list: TStrings; var params: TStringList; var values: TStringList);
var
  i: Integer;
  p: integer;
begin
  params.Clear;
  values.Clear;
  for i := 0 to list.Count - 1 do
  begin
    p := Pos('=', list.Strings[i]);
    params.Add(Copy(list.Strings[i], 1, p - 1));
    values.Add(Copy(list.Strings[i], p + 1, Length(list.Strings[i])));
  end;
end;

end.
