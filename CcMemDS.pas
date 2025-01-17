// CopyCat replication suite<p/>
// Copyright (c) 2014 Microtec Communications. For any questions or technical
// support, contact us at contact@copycat.fr<p/>
// <p/>
// Based on the RxMemDS unit from the Rx library<p/>
// <p/>
// The original Rx code is Copyright (c) 2001,2002 SGB Software Copyright (c) 1997,
// 1998 Fedor Koshevnikov, Igor Pavluk and Serge Korolev

unit CcMemDS;

{$I CC.INC}

interface

{$IFNDEF NEXTGEN}
uses
{$IFDEF MSWINDOWS} Windows, {$ENDIF}
  SysUtils, Classes, CcProviders, DB{$IFDEF CC_UseVariants}, Variants{$ENDIF}
{$IFDEF CC_D6}, SqlTimSt {$ENDIF};

{ TCcMemoryData }


type
  TLoadMode = (lmCopy, lmAppend);

{$IFNDEF CC_D6}
  PByte = ^Byte;
{$ENDIF}

  { TCcWideStringField = class (TWideStringField)

    end; }

  TMemBlobData = ansistring;
  TMemBlobArray = array [0 .. 0] of TMemBlobData;
  PMemBlobArray = ^TMemBlobArray;
  TMemoryRecord = class;
  TCompareRecords = function(Item1, Item2: TMemoryRecord): Integer of object;
{$IFDEF UNICODE}
  PCcMemBuffer = TRecordBuffer;
{$ELSE}
  PCcMemBuffer = PChar;
{$ENDIF UNICODE}

{$IFDEF CC_D2K6}
  TCcWideMemoField = class(TWideMemoField)
  protected
    function GetIsNull: Boolean; override;
    function GetAsVariant: Variant; override;
    procedure SetVarValue(const Value: Variant); override;
  end;
{$ENDIF}

  TCcMemoField = class(TMemoField)
  protected
    function GetIsNull: Boolean; override;
    procedure SetVarValue(const Value: Variant); override;
  public
    function GetAsVariant: Variant; override;
  end;

  // Summary:
  // In-memory TDataSet descendant.
  // Description:
  // TCcInternalMemoryData is based on the RxLib TRxMemoryData component.
  TCcInternalMemoryData = class(TDataSet)
  private
    FRecordPos: Integer;
    FRecordSize: Integer;
    FBookmarkOfs: Integer;
    FBlobOfs: Integer;
    FRecBufSize: Integer;
    FOffsets: PWordArray;
    FLastID: Integer;
    FAutoInc: Longint;
    FActive: Boolean;
    FRecords: TList;
    FIndexList: TList;
    FCaseInsensitiveSort: Boolean;
    FDescendingSort: Boolean;
    function AddRecord: TMemoryRecord;
    function InsertRecord(Index: Integer): TMemoryRecord;
    function FindRecordID(ID: Integer): TMemoryRecord;
    procedure CreateIndexList(const FieldNames: string);
    procedure FreeIndexList;
    procedure QuickSort(L, R: Integer; Compare: TCompareRecords);
    procedure Sort;
    function CalcRecordSize: Integer;
    function FindFieldData(Buffer: Pointer; Field: TField): Pointer;
    function GetMemoryRecord(Index: Integer): TMemoryRecord;
    function GetCapacity: Integer;
    function RecordFilter: Boolean;
    procedure SetCapacity(Value: Integer);
    procedure ClearRecords;
    procedure InitBufferPointers(GetProps: Boolean);
  protected
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    procedure AssignMemoryRecord(Rec: TMemoryRecord; Buffer: PCcMemBuffer);
    function GetActiveRecBuf(var RecBuf: PCcMemBuffer): Boolean; virtual;
    procedure InitFieldDefsFromFields;
    procedure RecordToBuffer(Rec: TMemoryRecord; Buffer: PCcMemBuffer);
    procedure SetMemoryRecordData(Buffer: PCcMemBuffer; Pos: Integer); virtual;
    procedure SetAutoIncFields(Buffer: PCcMemBuffer); virtual;
    function CompareRecords(Item1, Item2: TMemoryRecord): Integer; virtual;
    function GetBlobData(Field: TField; Buffer: PCcMemBuffer): TMemBlobData;
    procedure SetBlobData(Field: TField; Buffer: PCcMemBuffer; Value: TMemBlobData);
    function AllocRecordBuffer: PCcMemBuffer; override;
    procedure FreeRecordBuffer(var Buffer: PCcMemBuffer); override;
    procedure InternalInitRecord(Buffer: PCcMemBuffer); override;
    procedure ClearCalcFields(Buffer: PCcMemBuffer); override;
    function GetRecord(Buffer: PCcMemBuffer; GetMode: TGetMode;
      DoCheck: Boolean): TGetResult; override;
    function GetRecordSize: Word; override;
    procedure SetFiltered(Value: Boolean); override;
    procedure SetOnFilterRecord(const Value: TFilterRecordEvent); override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); override;
{$IFDEF CC_D2K13}
    procedure SetFieldData(Field: TField; Buffer: TValueBuffer); overload; override;
{$ENDIF}
    procedure CloseBlob(Field: TField); override;
    procedure GetBookmarkData(Buffer: PCcMemBuffer; Data: Pointer); override;
    function GetBookmarkFlag(Buffer: PCcMemBuffer): TBookmarkFlag; override;
{$IFDEF UNICODE}
    procedure InternalGotoBookmark(Bookmark: Pointer); override;
{$ELSE}
    procedure InternalGotoBookmark(Bookmark: TBookmark); override;
{$ENDIF}
    procedure InternalSetToRecord(Buffer: PCcMemBuffer); override;
    procedure SetBookmarkFlag(Buffer: PCcMemBuffer; Value: TBookmarkFlag); override;
    procedure SetBookmarkData(Buffer: PCcMemBuffer; Data: Pointer); override;
    function GetIsIndexField(Field: TField): Boolean; override;
    procedure InternalFirst; override;
    procedure InternalLast; override;
    procedure InitRecord(Buffer: PCcMemBuffer); override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean); override;
    procedure InternalDelete; override;
    procedure InternalPost; override;
    procedure InternalClose; override;
    procedure InternalHandleException; override;
    procedure InternalInitFieldDefs; override;
    procedure InternalOpen; override;
    procedure OpenCursor(InfoQuery: Boolean); override;
    function IsCursorOpen: Boolean; override;
    function GetRecordCount: Integer; override;
    function GetRecNo: Integer; override;
    procedure SetRecNo(Value: Integer); override;
    property Records[index: Integer]: TMemoryRecord read GetMemoryRecord;

    procedure DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean); override;
{$IFDEF CC_DXE6}
    procedure DataConvert(Field: TField; Source: TValueBuffer; var Dest: TValueBuffer; ToNative: Boolean); override;
{$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function BookmarkValid(Bookmark: TBookmark): Boolean; override;
    function CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
{$IFDEF CC_D2K13}
    function GetFieldData(Field: TField; {$IFDEF CC_D2K14}var {$ENDIF}Buffer: TValueBuffer): Boolean; overload; override;
{$ENDIF}
    function GetCurrentRecord(Buffer: PCcMemBuffer): Boolean; override;
    function IsSequenced: Boolean; override;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean; override;
    procedure SortOnFields(const FieldNames: string;
      CaseInsensitive: Boolean = True; Descending: Boolean = False);
    procedure EmptyTable;
    function SaveToDataSet(Dest: TDataSet; RecordCount: Integer): Integer;
    property Capacity: Integer read GetCapacity write SetCapacity default 0;
    property Active;
  published
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
  end;

  //Summary:
  //In-memory TDataSet descendant.
  //Description:
  //TCcMemoryData is an in-memory TDataSet descendant, used as an ancestor for
  //TCcDataSet.                                                               
  TCcMemoryData = class(TCcInternalMemoryData)
  private
    lFirst: Boolean;
    procedure CreateDataSetFields;
    procedure EmptyAndClose;
    procedure CopyStructure(Source: TCCQuery); overload;
    procedure CopyStructure(Source: TDataSet); overload;
  protected
    FAutoCreateFieldDefs: Boolean;
    procedure DoBeforeClose; override;
    procedure DoBeforeOpen; override;
    procedure OpenCursor(InfoQuery: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SortRows(const FieldNames: string; CaseInsensitive: Boolean);
    function LoadFromDataSet(Source: TCCQuery; lTrimCharFields,
      lCopyStructure: Boolean; lEmptyStringsToNull: Boolean): Integer; overload;
    function LoadFromDataSet(Source: TCCQuery): Integer; overload;
    function LoadFromDataSet(Source: TDataSet; RecordCount: Integer; Mode: TLoadMode): Integer; overload;
    procedure AddField(Name: string; DataType: TFieldType; Size: Integer);
  end;

  TMemBlobStream = class(TStream)
  private
    FField: TBlobField;
    FDataSet: TCcInternalMemoryData;
    FBuffer: PCcMemBuffer;
    FMode: TBlobStreamMode;
    FOpened: Boolean;
    FModified: Boolean;
    FPosition: Longint;
    FCached: Boolean;
    function GetBlobSize: Longint;
    function GetBlobFromRecord(Field: TField): TMemBlobData;
  public
    constructor Create(Field: TBlobField; Mode: TBlobStreamMode);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;

{$IFDEF CC_D2K13}
    function Write(const Buffer: TBytes; Offset, Count: Longint): Longint; overload; override;
{$ENDIF}
    function Write(const Buffer; Count: Longint): Longint; override;

{$IFDEF CC_D2K12}
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
{$ENDIF}
    function Seek(Offset: Longint; Origin: Word): Longint; override;

    procedure Truncate;
  end;

  TMemoryRecord = class(TPersistent)
  private
    FMemoryData: TCcInternalMemoryData;
    FID: Integer;
    FData: Pointer;
    FBlobs: Pointer;
    function GetIndex: Integer;
    procedure SetMemoryData(Value: TCcInternalMemoryData; UpdateParent: Boolean);
  protected
    procedure SetIndex(Value: Integer); virtual;
  public
    constructor Create(MemoryData: TCcInternalMemoryData); virtual;
    constructor CreateEx(MemoryData: TCcInternalMemoryData; UpdateParent: Boolean); virtual;
    destructor Destroy; override;
    property MemoryData: TCcInternalMemoryData read FMemoryData;
    property ID: Integer read FID write FID;
    property index: Integer read GetIndex write SetIndex;
    property Data: Pointer read FData;
  end;

{$IFDEF WIN32}

function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
{$ENDIF}


procedure RxAssignRecord(Source, Dest: TDataSet; ByName: Boolean);
procedure _DBError(const Msg: string);
function Min(A, B: Longint): Longint;

{$ENDIF}

implementation

{$IFNDEF NEXTGEN}

uses
  DbConsts, {$IFDEF CC_D2K14}VCL.Forms{$ELSE} Forms{$ENDIF}, ComObj;

resourcestring
  SMemNoRecords = 'No data found';

const
  ftBlobTypes = [ftBlob, ftMemo, ftGraphic, ftFmtMemo, ftParadoxOle,
    ftDBaseOle, ftTypedBinary, ftOraBlob, ftOraClob
{$IFDEF CC_D2K6}, ftWideMemo{$ENDIF}];

  ftSupported = [ftString, ftSmallint, ftInteger, ftWord, ftBoolean,
    ftFloat, ftCurrency, ftDate, ftTime, ftDateTime, ftAutoInc, ftBCD,
{$IFDEF CC_D6}
  ftTimestamp, ftFMTBcd,
{$ENDIF}
{$IFDEF CC_D2K6}
  ftOraInterval, ftFixedWideChar,
{$ENDIF}
{$IFDEF CC_D2K9}
  ftLongWord,
{$ENDIF}
{$IFDEF CC_D2K13}
  ftSingle,
{$ENDIF}
  ftDataSet, ftBytes, ftVarBytes, ftADT, ftFixedChar, ftWideString, ftLargeint,
    ftVariant, ftGuid] + ftBlobTypes;

  fkStoredFields = [fkData];

  GuidSize = 38;

  { Utility routines }

procedure RxAssignRecord(Source, Dest: TDataSet; ByName: Boolean);
var
  I: Integer;
  F, FSrc: TField;
begin
  if not(Dest.State in dsEditModes) then
    _DBError(SNotEditing);
  if ByName then
  begin
    for I := 0 to Source.FieldCount - 1 do
    begin
      F := Dest.FindField(Source.Fields[I].FieldName);
      if F <> nil then
      begin
{$IFDEF WIN32}
        F.Value := Source.Fields[I].Value;
{$ELSE}
        if (F.DataType = Source.Fields[I].DataType) and
          (F.DataSize = Source.Fields[I].DataSize) then
          F.Assign(Source.Fields[I])
        else
          F.AsString := Source.Fields[I].AsString;
{$ENDIF}
      end;
    end;
  end
  else
  begin
    for I := 0 to Min(Source.FieldDefs.Count - 1, Dest.FieldDefs.Count - 1) do
    begin
      F := Dest.FindField(Dest.FieldDefs[I].Name);
      FSrc := Source.FindField(Source.FieldDefs[I].Name);
      if (F <> nil) and (FSrc <> nil) then
      begin
{$IFDEF WIN32}
        F.Value := FSrc.Value;
{$ELSE}
        if F.DataType = FSrc.DataType then
          F.Assign(FSrc)
        else
          F.AsString := FSrc.AsString;
{$ENDIF}
      end;
    end;
  end;
end;

procedure _DBError(const Msg: string);
begin
  DatabaseError(Msg);
end;


{$IFDEF WIN32}

function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  FieldCount: Integer;
  Fields: TList;
{$IFDEF UNICODE}
  Bookmark: TBytes;
{$ELSE}
  Bookmark: TBookmarkStr;
{$ENDIF}
  function CompareField(Field: TField; Value: Variant): Boolean;
  var
    S: string;
  begin
    if Field.DataType = ftString then
    begin
      S := Field.AsString;
      if (loPartialKey in Options) then
        Delete(S, Length(Value) + 1, MaxInt);
      if (loCaseInsensitive in Options) then
        Result := AnsiCompareText(S, Value) = 0
      else
        Result := AnsiCompareStr(S, Value) = 0;
    end
    else
      Result := (Field.Value = Value);
  end;

  function CompareRecord: Boolean;
  var
    I: Integer;
  begin
    if FieldCount = 1 then
      Result := CompareField(TField(Fields.First), KeyValues)
    else
    begin
      Result := True;
      for I := 0 to FieldCount - 1 do
        Result := Result and CompareField(TField(Fields[I]), KeyValues[I]);
    end;
  end;

begin
  Result := False;
  with DataSet do
  begin
    CheckBrowseMode;
    if BOF and EOF then
      Exit;
  end;
  Fields := TList.Create;
  try
    DataSet.GetFieldList(Fields, KeyFields);
    FieldCount := Fields.Count;
    Result := CompareRecord;
    if Result then
      Exit;
    DataSet.DisableControls;
    try
      Bookmark := DataSet.Bookmark;
      try
        with DataSet do
        begin
          First;
          while not EOF do
          begin
            Result := CompareRecord;
            if Result then
              Break;
            Next;
          end;
        end;
      finally
{$IFDEF UNICODE}
        if not Result and
          DataSet.BookmarkValid(Bookmark) then
          DataSet.Bookmark := Bookmark;
{$ELSE}
        if not Result and
          DataSet.BookmarkValid(PChar(Bookmark)) then
          DataSet.Bookmark := Bookmark;
{$ENDIF}
      end;
    finally
      DataSet.EnableControls;
    end;
  finally
    Fields.Free;
  end;
end;
{$ENDIF}


function CompareFields(Data1, Data2: Pointer; FieldType: TFieldType;
  CaseInsensitive: Boolean): Integer;
begin
  Result := 0;
  case FieldType of
    ftString:
      if CaseInsensitive then
        Result := AnsiCompareText(PChar(Data1), PChar(Data2))
      else
        Result := AnsiCompareStr(PChar(Data1), PChar(Data2));
    ftSmallint:
      if SmallInt(Data1^) > SmallInt(Data2^) then
        Result := 1
      else if SmallInt(Data1^) < SmallInt(Data2^) then
        Result := -1;
    ftInteger, ftDate, ftTime, ftAutoInc:
      if Longint(Data1^) > Longint(Data2^) then
        Result := 1
      else if Longint(Data1^) < Longint(Data2^) then
        Result := -1;
    ftWord:
      if Word(Data1^) > Word(Data2^) then
        Result := 1
      else if Word(Data1^) < Word(Data2^) then
        Result := -1;
    ftBoolean:
      if WordBool(Data1^) and not WordBool(Data2^) then
        Result := 1
      else if not WordBool(Data1^) and WordBool(Data2^) then
        Result := -1;
    ftFloat, ftCurrency:
      if Double(Data1^) > Double(Data2^) then
        Result := 1
      else if Double(Data1^) < Double(Data2^) then
        Result := -1;
    ftDateTime:
      if TDateTime(Data1^) > TDateTime(Data2^) then
        Result := 1
      else if TDateTime(Data1^) < TDateTime(Data2^) then
        Result := -1;
{$IFDEF CC_D6}
    ftTimestamp:
      if SQLTimeStampToDateTime(TSQLTimeStamp(Data1^)) > SQLTimeStampToDateTime(TSQLTimeStamp(Data2^)) then
        Result := 1
      else if SQLTimeStampToDateTime(TSQLTimeStamp(Data1^)) < SQLTimeStampToDateTime(TSQLTimeStamp(Data2^)) then
        Result := -1;
{$ENDIF}
    ftFixedChar:
      if CaseInsensitive then
        Result := AnsiCompareText(PChar(Data1), PChar(Data2))
      else
        Result := AnsiCompareStr(PChar(Data1), PChar(Data2));
    ftWideString:
      if CaseInsensitive then
        Result := AnsiCompareText(WideCharToString(PWideChar(Data1)),
          WideCharToString(PWideChar(Data2)))
      else
        Result := AnsiCompareStr(WideCharToString(PWideChar(Data1)),
          WideCharToString(PWideChar(Data2)));
    ftLargeint:
      if Int64(Data1^) > Int64(Data2^) then
        Result := 1
      else if Int64(Data1^) < Int64(Data2^) then
        Result := -1;
    ftVariant:
      Result := 0;
    ftGuid:
      Result := AnsiCompareText(PChar(Data1), PChar(Data2));
  end;
end;

function CalcFieldLen(FieldType: TFieldType; Size: Word): Word;
begin
  if not(FieldType in ftSupported) then
    Result := 0
  else
    if FieldType in ftBlobTypes then
    Result := SizeOf(Longint)
  else
  begin
    Result := Size;
    case FieldType of
      ftString:
        Inc(Result);
      ftSmallint:
        Result := SizeOf(SmallInt);
      ftInteger:
        Result := SizeOf(Longint);
      ftWord:
        Result := SizeOf(Word);
{$IFDEF CC_D2K6}
      ftOraInterval:
        Inc(Result);
{$ENDIF}
{$IFDEF CC_D2K13}
      ftSingle:
        Result := SizeOf(single);
{$ENDIF}
{$IFDEF CC_D2K9}
      ftLongWord:
        Result := SizeOf(LongWord);
{$ENDIF}
      ftBoolean:
        Result := SizeOf(WordBool);
      ftFloat:
        Result := SizeOf(Double);
      ftCurrency:
        Result := SizeOf(Double);
      ftBCD:
        Result := 34;
{$IFDEF CC_D6}
      ftFMTBcd:
        Result := 34;
{$ENDIF}
      ftDate, ftTime:
        Result := SizeOf(Longint);
      ftDateTime:
        Result := SizeOf(TDateTime);
{$IFDEF CC_D6}
      ftTimestamp:
        Result := SizeOf(TSQLTimeStamp);
{$ENDIF}
      ftBytes:
        Result := Size;
      ftVarBytes:
        Result := Size + 2;
      ftAutoInc:
        Result := SizeOf(Longint);
      ftADT:
        Result := 0;
      ftFixedChar:
        Inc(Result);
      ftWideString:
        Result := (Result + 1) * SizeOf(WideChar);
      ftLargeint:
        Result := SizeOf(Int64);
      ftVariant:
        Result := SizeOf(Variant);
      ftGuid:
        Result := GuidSize + 1;
    end;
  end;
end;

procedure CalcDataSize(FieldDef: TFieldDef; var DataSize: Integer);
var
  I: Integer;
begin
  with FieldDef do
  begin
    if DataType in ftSupported - ftBlobTypes then
      Inc(DataSize, CalcFieldLen(DataType, Size) + 1);
    for I := 0 to ChildDefs.Count - 1 do
      CalcDataSize(ChildDefs[I], DataSize);
  end;
end;

procedure Error(const Msg: string);
begin
  DatabaseError(Msg);
end;

procedure ErrorFmt(const Msg: string; const Args: array of const);
begin
  DatabaseErrorFmt(Msg, Args);
end;

type
  TBookmarkData = Integer;
  PMemBookmarkInfo = ^TMemBookmarkInfo;

  TMemBookmarkInfo = record
    BookmarkData: TBookmarkData;
    BookmarkFlag: TBookmarkFlag;
  end;

  { TMemoryRecord }

constructor TMemoryRecord.Create(MemoryData: TCcInternalMemoryData);
begin
  CreateEx(MemoryData, True);
end;

constructor TMemoryRecord.CreateEx(MemoryData: TCcInternalMemoryData; UpdateParent: Boolean);
begin
  inherited Create;
  SetMemoryData(MemoryData, UpdateParent);
end;

destructor TMemoryRecord.Destroy;
begin
  SetMemoryData(nil, True);
  inherited Destroy;
end;

function TMemoryRecord.GetIndex: Integer;
begin
  if FMemoryData <> nil then
    Result := FMemoryData.FRecords.IndexOf(Self)
  else
    Result := -1;
end;

procedure TMemoryRecord.SetMemoryData(Value: TCcInternalMemoryData; UpdateParent: Boolean);
var
  I: Integer;
  DataSize: Integer;
begin
  if FMemoryData <> Value then
  begin
    if FMemoryData <> nil then
    begin
      FMemoryData.FRecords.Remove(Self);
      if FMemoryData.BlobFieldCount > 0 then
        Finalize(PMemBlobArray(FBlobs)[0], FMemoryData.BlobFieldCount);
      ReallocMem(FBlobs, 0);
      ReallocMem(FData, 0);
      FMemoryData := nil;
    end;
    if Value <> nil then
    begin
      if UpdateParent then
      begin
        Value.FRecords.Add(Self);
        Inc(Value.FLastID);
        FID := Value.FLastID;
      end;
      FMemoryData := Value;
      if Value.BlobFieldCount > 0 then
      begin
        ReallocMem(FBlobs, Value.BlobFieldCount * SizeOf(Pointer));
        Initialize(PMemBlobArray(FBlobs)[0], Value.BlobFieldCount);
      end;
      DataSize := 0;
      for I := 0 to Value.FieldDefs.Count - 1 do
        CalcDataSize(Value.FieldDefs[I], DataSize);
      ReallocMem(FData, DataSize);
    end;
  end;
end;

procedure TMemoryRecord.SetIndex(Value: Integer);
var
  CurIndex: Integer;
begin
  CurIndex := GetIndex;
  if (CurIndex >= 0) and (CurIndex <> Value) then
    FMemoryData.FRecords.Move(CurIndex, Value);
end;

{ TCcInternalMemoryData }

constructor TCcInternalMemoryData.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRecordPos := -1;
  FLastID := low(Integer);
  FAutoInc := 1;
  FRecords := TList.Create;
end;

destructor TCcInternalMemoryData.Destroy;
begin
  inherited Destroy;
  FreeIndexList;
  ClearRecords;
  FRecords.Free;
  ReallocMem(FOffsets, 0);
end;

{ Records Management }

function TCcInternalMemoryData.GetCapacity: Integer;
begin
  if FRecords <> nil then
    Result := FRecords.Capacity
  else
    Result := 0;
end;

procedure TCcInternalMemoryData.SetCapacity(Value: Integer);
begin
  if FRecords <> nil then
    FRecords.Capacity := Value;
end;

function TCcInternalMemoryData.AddRecord: TMemoryRecord;
begin
  Result := TMemoryRecord.Create(Self);
end;

function TCcInternalMemoryData.FindRecordID(ID: Integer): TMemoryRecord;
var
  I: Integer;
begin
  for I := 0 to FRecords.Count - 1 do
  begin
    Result := TMemoryRecord(FRecords[I]);
    if Result.ID = ID then
      Exit;
  end;
  Result := nil;
end;

function TCcInternalMemoryData.InsertRecord(Index: Integer): TMemoryRecord;
begin
  Result := AddRecord;
  Result.Index := index;
end;

function TCcInternalMemoryData.GetMemoryRecord(Index: Integer): TMemoryRecord;
begin
  Result := TMemoryRecord(FRecords[index]);
end;

{ Field Management }

procedure TCcInternalMemoryData.InitFieldDefsFromFields;
var
  I: Integer;
  Offset: Word;
begin
  if FieldDefs.Count = 0 then
  begin
    for I := 0 to FieldCount - 1 do
    begin
      with Fields[I] do
        if (FieldKind in fkStoredFields) and not(DataType in ftSupported) then
          ErrorFmt(SUnknownFieldType, [DisplayName]);
    end;
    FreeIndexList;
  end;
  Offset := 0;
  inherited InitFieldDefsFromFields;
  { Calculate fields offsets }
  ReallocMem(FOffsets, FieldDefList.Count * SizeOf(Word));
  for I := 0 to FieldDefList.Count - 1 do
  begin
    FOffsets^[I] := Offset;
    with FieldDefList[I] do
      if (DataType in ftSupported - ftBlobTypes) then
        Inc(Offset, CalcFieldLen(DataType, Size) + 1);
  end;
end;

function TCcInternalMemoryData.FindFieldData(Buffer: Pointer; Field: TField): Pointer;
var
  Index: Integer;
  DataType: TFieldType;
begin
  Result := nil;
  index := FieldDefList.IndexOf(Field.FullName);
  if (index >= 0) and (Buffer <> nil) then
  begin
    DataType := FieldDefList[index].DataType;
    if DataType in ftSupported then
      if DataType in ftBlobTypes then
        Result := Pointer(GetBlobData(Field, Buffer))
      else
        Result := (PCcMemBuffer(Buffer) + FOffsets[index]);
  end;
end;

{ Buffer Manipulation }

function TCcInternalMemoryData.CalcRecordSize: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FieldDefs.Count - 1 do
    CalcDataSize(FieldDefs[I], Result);
end;

procedure TCcInternalMemoryData.InitBufferPointers(GetProps: Boolean);
begin
  if GetProps then
    FRecordSize := CalcRecordSize;
  FBookmarkOfs := FRecordSize + CalcFieldsSize;
  FBlobOfs := FBookmarkOfs + SizeOf(TMemBookmarkInfo);
  FRecBufSize := FBlobOfs + BlobFieldCount * SizeOf(Pointer);
end;

procedure TCcInternalMemoryData.ClearRecords;
begin
  while FRecords.Count > 0 do
    TObject(FRecords.Last).Free;
  FLastID := low(Integer);
  FRecordPos := -1;
end;

function WideStrLen(AStr: PWideChar): Integer;
begin
  Result := 0;
  while (PChar(AStr)^ <> #0) or ((PChar(AStr) + 1)^ <> #0) do
  begin
    Inc(Result);
    AStr := PWideChar(PAnsiChar(AStr) + 2);
  end;
end;

{$IFDEF CC_DXE6}

procedure TCcInternalMemoryData.DataConvert(Field: TField; Source: TValueBuffer; var Dest: TValueBuffer; ToNative: Boolean);
begin
  { if (Field.DataType = ftWideString) or (Field.DataType = ftFixedWideChar) then
    StrLCopy(PChar(Dest), PChar(Source), WideStrLen(PWideChar(Source)))
    else }
  inherited DataConvert(Field, Source, Dest, ToNative);
end;
{$ENDIF}


procedure TCcInternalMemoryData.DataConvert(Field: TField; Source, Dest: Pointer; ToNative: Boolean);
{$IFNDEF CC_D2K6}
var
  L: Integer;
  p: PChar;
{$ENDIF}
begin
  if (Field.DataType = ftWideString) {$IFDEF CC_D2K6} or (Field.DataType = ftFixedWideChar){$ENDIF} then
{$IFNDEF CC_D2K6}
    if Field.FieldKind in [fkCalculated, fkLookup] then
      PLongWord(Dest)^ := PLongWord(Source)^
    else if ToNative then
    begin
      L := Length(WideString(Source^)) * SizeOf(WideChar);
      Move(WideString(Source^)[1], PWideChar(Dest)^, L);
      p := PChar(Dest) + L;
      p^ := #0;
      (p + 1)^ := #0;
    end
    else
      SetString(WideString(Dest^), PWideChar(Source), WideStrLen(PWideChar(Source)))
{$ELSE}
{$IFDEF CC_DXE6}
    StrLCopy(PChar(Dest), PChar(Source), WideStrLen(PWideChar(Source)))
{$ELSE}
    inherited DataConvert(Field, Source, Dest, ToNative)
{$ENDIF}
{$ENDIF}
  else
    inherited DataConvert(Field, Source, Dest, ToNative);
end;

function TCcInternalMemoryData.AllocRecordBuffer: PCcMemBuffer;
begin
{$IFDEF CC_D2K9}
  GetMem(Result, FRecBufSize);
{$ELSE}
  Result := StrAlloc(FRecBufSize);
{$ENDIF CC_D2K9}
  if BlobFieldCount > 0 then
    Initialize(PMemBlobArray(Result + FBlobOfs)[0], BlobFieldCount);
end;

procedure TCcInternalMemoryData.FreeRecordBuffer(var Buffer: PCcMemBuffer);
begin
  if BlobFieldCount > 0 then
    Finalize(PMemBlobArray(Buffer + FBlobOfs)[0], BlobFieldCount);
{$IFDEF CC_D2K9}
  FreeMem(Buffer);
{$ELSE}
  StrDispose(Buffer);
{$ENDIF CC_D2K9}
  Buffer := nil;
end;

procedure TCcInternalMemoryData.ClearCalcFields(Buffer: PCcMemBuffer);
begin
  FillChar(Buffer[FRecordSize], CalcFieldsSize, 0);
end;

procedure TCcInternalMemoryData.InternalInitRecord(Buffer: PCcMemBuffer);
var
  I: Integer;
begin
  FillChar(Buffer^, FBlobOfs, 0);
  for I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Buffer + FBlobOfs)[I] := '';
end;

procedure TCcInternalMemoryData.InitRecord(Buffer: PCcMemBuffer);
begin
  inherited InitRecord(Buffer);
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do
  begin
    BookmarkData := low(Integer);
    BookmarkFlag := bfInserted;
  end;
end;

function TCcInternalMemoryData.GetCurrentRecord(Buffer: PCcMemBuffer): Boolean;
begin
  Result := False;
  if not IsEmpty and (GetBookmarkFlag(ActiveBuffer) = bfCurrent) then
  begin
    UpdateCursorPos;
    if (FRecordPos >= 0) and (FRecordPos < RecordCount) then
    begin
      Move(Records[FRecordPos].Data^, Buffer^, FRecordSize);
      Result := True;
    end;
  end;
end;

procedure TCcInternalMemoryData.RecordToBuffer(Rec: TMemoryRecord; Buffer: PCcMemBuffer);
var
  I: Integer;
begin
  Move(Rec.Data^, Buffer^, FRecordSize);
  with PMemBookmarkInfo(Buffer + FBookmarkOfs)^ do
  begin
    BookmarkData := Rec.ID;
    BookmarkFlag := bfCurrent;
  end;
  for I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Buffer + FBlobOfs)[I] := PMemBlobArray(Rec.FBlobs)[I];
  GetCalcFields(Buffer);
end;

function TCcInternalMemoryData.GetRecord(Buffer: PCcMemBuffer; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;
var
  Accept: Boolean;
begin
  Result := grOk;
  Accept := True;
  case GetMode of
    gmPrior:
      if FRecordPos <= 0 then
      begin
        Result := grBOF;
        FRecordPos := -1;
      end
      else
      begin
        repeat
          Dec(FRecordPos);
          if Filtered then
            Accept := RecordFilter;
        until Accept or (FRecordPos < 0);
        if not Accept then
        begin
          Result := grBOF;
          FRecordPos := -1;
        end;
      end;
    gmCurrent:
      if (FRecordPos < 0) or (FRecordPos >= RecordCount) then
        Result := grError
      else
        if Filtered then
        if not RecordFilter then
          Result := grError;
    gmNext:
      if FRecordPos >= RecordCount - 1 then
        Result := grEOF
      else
      begin
        repeat
          Inc(FRecordPos);
          if Filtered then
            Accept := RecordFilter;
        until Accept or (FRecordPos > RecordCount - 1);
        if not Accept then
        begin
          Result := grEOF;
          FRecordPos := RecordCount - 1;
        end;
      end;
  end;
  if Result = grOk then
    RecordToBuffer(Records[FRecordPos], Buffer)
  else
    if (Result = grError) and DoCheck then
    Error(SMemNoRecords);
end;

function TCcInternalMemoryData.GetRecordSize: Word;
begin
  Result := FRecordSize;
end;

function TCcInternalMemoryData.GetActiveRecBuf(var RecBuf: PCcMemBuffer): Boolean;
begin
  case State of
    dsBrowse:
      if IsEmpty then
        RecBuf := nil
      else
        RecBuf := PCcMemBuffer(ActiveBuffer);
    dsEdit, dsInsert:
      RecBuf := PCcMemBuffer(ActiveBuffer);
    dsCalcFields:
      RecBuf := PCcMemBuffer(CalcBuffer);
    dsFilter:
      RecBuf := PCcMemBuffer(TempBuffer);

  else
    RecBuf := nil;
  end;
  Result := RecBuf <> nil;
end;

{$IFDEF CC_D2K13}

function TCcInternalMemoryData.GetFieldData(Field: TField; {$IFDEF CC_D2K14}var {$ENDIF}Buffer: TValueBuffer): Boolean;
begin
  Result := Self.GetFieldData(Field, Pointer(Buffer))
end;
{$ENDIF}


function TCcInternalMemoryData.GetFieldData(Field: TField; Buffer: Pointer): Boolean;
var
  RecBuf: PCcMemBuffer;
  Data: PCcMemBuffer;
  VarData: Variant;
begin
  Result := False;
  if not GetActiveRecBuf(RecBuf) then
    Exit;
  if Field.FieldNo > 0 then
  begin
    Data := FindFieldData(RecBuf, Field);
    if Data <> nil then
    begin
      Result := Boolean(Data[0]);
      Inc(Data);
      // if Field.DataType in [ftString, ftFixedChar,
      // ftWideString, ftGuid] then
      // Result := Result and (StrLen(Data) > 0);
      // Result := Result and (StrLen(PAnsiChar(Data)) > 0);
      if Result and (Buffer <> nil) then
        if Field.DataType in [ftVariant] then
        begin
          VarData := PVariant(Data)^;
          PVariant(Buffer)^ := VarData;
        end
        else
          Move(Data^, Buffer^, CalcFieldLen(Field.DataType, Field.Size));
    end;
  end
  else
    if State in [dsBrowse, dsEdit, dsInsert, dsCalcFields] then
  begin
    Inc(RecBuf, FRecordSize + Field.Offset);
    Result := Boolean(RecBuf[0]);
    if Result and (Buffer <> nil) then
      Move(RecBuf[1], Buffer^, Field.DataSize);
  end;
end;

{$IFDEF CC_D2K13}

procedure TCcInternalMemoryData.SetFieldData(Field: TField; Buffer: TValueBuffer);
begin
  Self.SetFieldData(Field, Pointer(Buffer));
end;
{$ENDIF}


procedure TCcInternalMemoryData.SetFieldData(Field: TField; Buffer: Pointer);
var
  RecBuf: PCcMemBuffer;
  Data: PCcMemBuffer;
  VarData: Variant;
begin
  if not(State in dsWriteModes) then
    Error(SNotEditing);
  GetActiveRecBuf(RecBuf);
  with Field do
  begin
    if FieldNo > 0 then
    begin
      if State in [dsCalcFields, dsFilter] then
        Error(SNotEditing);
      if readonly and not(State in [dsSetKey, dsFilter]) then
        ErrorFmt(SFieldReadOnly, [DisplayName]);
      Validate(Buffer);
      if FieldKind <> fkInternalCalc then
      begin
        Data := FindFieldData(RecBuf, Field);
        if Data <> nil then
        begin
          if DataType in [ftVariant] then
          begin
            if Buffer <> nil then
              VarData := PVariant(Buffer)^
            else
              VarData := EmptyParam;
            Boolean(Data[0]) := LongBool(Buffer) and not(VarIsNull(VarData) or VarIsEmpty(VarData));
            if Boolean(Data[0]) then
            begin
              Inc(Data);
              PVariant(Data)^ := VarData;
            end
            else
              FillChar(Data^, CalcFieldLen(DataType, Size), 0);
          end
          else
          begin
            Boolean(Data[0]) := LongBool(Buffer);
            Inc(Data);
            if LongBool(Buffer) then
              Move(Buffer^, Data^, CalcFieldLen(DataType, Size))
            else
              FillChar(Data^, CalcFieldLen(DataType, Size), 0);
          end;
        end;
      end;
    end
    else { fkCalculated, fkLookup }
    begin
      Inc(RecBuf, FRecordSize + Offset);
      Boolean(RecBuf[0]) := LongBool(Buffer);
      if Boolean(RecBuf[0]) then
        Move(Buffer^, RecBuf[1], DataSize);
    end;
    if not(State in [dsCalcFields, dsFilter, dsNewValue]) then
      DataEvent(deFieldChange, Longint(Field));
  end;
end;

{ Filter }

procedure TCcInternalMemoryData.SetFiltered(Value: Boolean);
begin
  if Active then
  begin
    CheckBrowseMode;
    if Filtered <> Value then
    begin
      inherited SetFiltered(Value);
      First;
    end;
  end
  else
    inherited SetFiltered(Value);
end;

procedure TCcInternalMemoryData.SetOnFilterRecord(const Value: TFilterRecordEvent);
begin
  if Active then
  begin
    CheckBrowseMode;
    inherited SetOnFilterRecord(Value);
    if Filtered then
      First;
  end
  else
    inherited SetOnFilterRecord(Value);
end;

function TCcInternalMemoryData.RecordFilter: Boolean;
var
  SaveState: TDataSetState;
begin
  Result := True;
  if Assigned(OnFilterRecord) then
  begin
    if (FRecordPos >= 0) and (FRecordPos < RecordCount) then
    begin
      SaveState := SetTempState(dsFilter);
      try
{$IFDEF CC_D2K14}
        RecordToBuffer(Records[FRecordPos], PByte(TempBuffer));
{$ELSE}
        RecordToBuffer(Records[FRecordPos], TempBuffer);
{$ENDIF}
        OnFilterRecord(Self, Result);
      except
        Application.HandleException(Self);
      end;
      RestoreState(SaveState);
    end
    else
      Result := False;
  end;
end;

{ Blobs }

function TCcInternalMemoryData.GetBlobData(Field: TField; Buffer: PCcMemBuffer): TMemBlobData;
begin
  Result := PMemBlobArray(Buffer + FBlobOfs)[Field.Offset];
end;

procedure TCcInternalMemoryData.SetBlobData(Field: TField; Buffer: PCcMemBuffer; Value: TMemBlobData);
begin
  if Buffer = PCcMemBuffer(ActiveBuffer) then
  begin
    if State = dsFilter then
      Error(SNotEditing);
    PMemBlobArray(Buffer + FBlobOfs)[Field.Offset] := Value;
  end;
end;

procedure TCcInternalMemoryData.CloseBlob(Field: TField);
begin
  if (FRecordPos >= 0) and (FRecordPos < FRecords.Count) and (State = dsEdit) then
    PMemBlobArray(ActiveBuffer + FBlobOfs)[Field.Offset] :=
      PMemBlobArray(Records[FRecordPos].FBlobs)[Field.Offset]
  else
    PMemBlobArray(ActiveBuffer + FBlobOfs)[Field.Offset] := '';
end;

function TCcInternalMemoryData.CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream;
begin
  Result := TMemBlobStream.Create(Field as TBlobField, Mode);
end;

{ Bookmarks }

function TCcInternalMemoryData.BookmarkValid(Bookmark: TBookmark): Boolean;
begin
  // Result := FActive and (TBookmarkData(Bookmark^) > Low(Integer)) and
  // (TBookmarkData(Bookmark^) <= FLastID);
  Result := (Bookmark <> nil) and FActive and
    (TBookmarkData({$IFDEF CC_D2K9}PByte(@Bookmark[0]){$ELSE}Bookmark{$ENDIF CC_D2K9}^) > low(Integer)) and
    (TBookmarkData({$IFDEF CC_D2K9}PByte(@Bookmark[0]){$ELSE}Bookmark{$ENDIF CC_D2K9}^) <= FLastID);
end;

function TCcInternalMemoryData.CompareBookmarks(Bookmark1, Bookmark2: TBookmark): Integer;
begin
  if (Bookmark1 = nil) and (Bookmark2 = nil) then
    Result := 0
  else
    if (Bookmark1 <> nil) and (Bookmark2 = nil) then
    Result := 1
  else
    if (Bookmark1 = nil) and (Bookmark2 <> nil) then
    Result := -1
    // else if TBookmarkData(Bookmark1^) > TBookmarkData(Bookmark2^) then
  else
    if TBookmarkData({$IFDEF CC_D2K9}PByte(@Bookmark1[0]){$ELSE}Bookmark1{$ENDIF CC_D2K9}^) >
    TBookmarkData({$IFDEF CC_D2K9}PByte(@Bookmark2[0]){$ELSE}Bookmark2{$ENDIF CC_D2K9}^) then
    Result := 1
    // else if TBookmarkData(Bookmark1^) < TBookmarkData(Bookmark2^) then
  else
    if TBookmarkData({$IFDEF CC_D2K9}PByte(@Bookmark1[0]){$ELSE}Bookmark1{$ENDIF CC_D2K9}^) <
    TBookmarkData({$IFDEF CC_D2K9}PByte(@Bookmark2[0]){$ELSE}Bookmark2{$ENDIF CC_D2K9}^) then
    Result := -1
  else
    Result := 0;
end;

procedure TCcInternalMemoryData.GetBookmarkData(Buffer: PCcMemBuffer; Data: Pointer);
begin
  Move(PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, Data^, SizeOf(TBookmarkData));
end;

procedure TCcInternalMemoryData.SetBookmarkData(Buffer: PCcMemBuffer; Data: Pointer);
begin
  Move(Data^, PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData, SizeOf(TBookmarkData));
end;

function TCcInternalMemoryData.GetBookmarkFlag(Buffer: PCcMemBuffer): TBookmarkFlag;
begin
  Result := PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag;
end;

procedure TCcInternalMemoryData.SetBookmarkFlag(Buffer: PCcMemBuffer; Value: TBookmarkFlag);
begin
  PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkFlag := Value;
end;

procedure TCcInternalMemoryData.InternalGotoBookmark(Bookmark: Pointer);
var
  Rec: TMemoryRecord;
  SavePos: Integer;
  Accept: Boolean;
begin
  Rec := FindRecordID(TBookmarkData(Bookmark^));
  if Rec <> nil then
  begin
    Accept := True;
    SavePos := FRecordPos;
    try
      FRecordPos := Rec.Index;
      if Filtered then
        Accept := RecordFilter;
    finally
      if not Accept then
        FRecordPos := SavePos;
    end;
  end;
end;

{ Navigation }

procedure TCcInternalMemoryData.InternalSetToRecord(Buffer: PCcMemBuffer);
begin
  InternalGotoBookmark(@PMemBookmarkInfo(Buffer + FBookmarkOfs)^.BookmarkData);
end;

procedure TCcInternalMemoryData.InternalFirst;
begin
  FRecordPos := -1;
end;

procedure TCcInternalMemoryData.InternalLast;
begin
  FRecordPos := FRecords.Count;
end;

{ Data Manipulation }

procedure TCcInternalMemoryData.AssignMemoryRecord(Rec: TMemoryRecord; Buffer: PCcMemBuffer);
var
  I: Integer;
begin
  Move(Buffer^, Rec.Data^, FRecordSize);
  for I := 0 to BlobFieldCount - 1 do
    PMemBlobArray(Rec.FBlobs)[I] := PMemBlobArray(Buffer + FBlobOfs)[I];
end;

procedure TCcInternalMemoryData.SetMemoryRecordData(Buffer: PCcMemBuffer; Pos: Integer);
var
  Rec: TMemoryRecord;
begin
  if State = dsFilter then
    Error(SNotEditing);
  Rec := Records[Pos];
  AssignMemoryRecord(Rec, Buffer);
end;

procedure TCcInternalMemoryData.SetAutoIncFields(Buffer: PCcMemBuffer);
var
  I, Count: Integer;
  Data: PByte;
begin
  Count := 0;
  for I := 0 to FieldCount - 1 do
    if (Fields[I].FieldKind in fkStoredFields) and
      (Fields[I].DataType = ftAutoInc) then
    begin
      Data := FindFieldData(Buffer, Fields[I]);
      if Data <> nil then
      begin
        // Boolean(Data[0]) := True;
        Data^ := Ord(True);
        Inc(Data);
        Move(FAutoInc, Data^, SizeOf(Longint));
        Inc(Count);
      end;
    end;
  if Count > 0 then
    Inc(FAutoInc);
end;

procedure TCcInternalMemoryData.InternalAddRecord(Buffer: Pointer; Append: Boolean);
var
  RecPos: Integer;
  Rec: TMemoryRecord;
begin
  if Append then
  begin
    Rec := AddRecord;
    FRecordPos := FRecords.Count - 1;
  end
  else
  begin
    if FRecordPos = -1 then
      RecPos := 0
    else
      RecPos := FRecordPos;
    Rec := InsertRecord(RecPos);
    FRecordPos := RecPos;
  end;
  SetAutoIncFields(Buffer);
  SetMemoryRecordData(Buffer, Rec.Index);
end;

procedure TCcInternalMemoryData.InternalDelete;
var
  Accept: Boolean;
begin
  Records[FRecordPos].Free;
  if FRecordPos >= FRecords.Count then
    Dec(FRecordPos);
  Accept := True;
  repeat
    if Filtered then
      Accept := RecordFilter;
    if not Accept then
      Dec(FRecordPos);
  until Accept or (FRecordPos < 0);
  if FRecords.Count = 0 then
    FLastID := low(Integer);
end;

procedure TCcInternalMemoryData.InternalPost;
var
  RecPos: Integer;
begin
  // inherited;
  if State = dsEdit then
{$IFDEF CC_D2K14}
    SetMemoryRecordData(PByte(ActiveBuffer), FRecordPos)
{$ELSE}
    SetMemoryRecordData(ActiveBuffer, FRecordPos)
{$ENDIF}
  else
  begin
    if State in [dsInsert] then
{$IFDEF CC_D2K14}
      SetAutoIncFields(PByte(ActiveBuffer));
{$ELSE}
      SetAutoIncFields(ActiveBuffer);
{$ENDIF}
    if FRecordPos >= FRecords.Count then
    begin
{$IFDEF CC_D2K14}
      SetMemoryRecordData(PByte(ActiveBuffer), AddRecord.Index);
{$ELSE}
      SetMemoryRecordData(ActiveBuffer, AddRecord.Index);
{$ENDIF}
      FRecordPos := FRecords.Count - 1;
    end
    else
    begin
      if FRecordPos = -1 then
        RecPos := 0
      else
        RecPos := FRecordPos;
{$IFDEF CC_D2K14}
      SetMemoryRecordData(PByte(ActiveBuffer), InsertRecord(RecPos).Index);
{$ELSE}
      SetMemoryRecordData(ActiveBuffer, InsertRecord(RecPos).Index);
{$ENDIF}
      FRecordPos := RecPos;
    end;
  end;
end;

procedure TCcInternalMemoryData.OpenCursor(InfoQuery: Boolean);
begin
  if (not InfoQuery) then
  begin
    if FieldCount > 0 then
      FieldDefs.Clear;
    InitFieldDefsFromFields;
  end;
  FActive := True;
  inherited OpenCursor(InfoQuery);
end;

procedure TCcInternalMemoryData.InternalOpen;
begin
  BookmarkSize := SizeOf(TBookmarkData);
  if DefaultFields then
    CreateFields;
  BindFields(True);
  InitBufferPointers(True);
  InternalFirst;
end;

procedure TCcInternalMemoryData.InternalClose;
begin
  ClearRecords;
  FAutoInc := 1;
  BindFields(False);
  if DefaultFields then
    DestroyFields;
  FreeIndexList;
  FActive := False;
end;

procedure TCcInternalMemoryData.InternalHandleException;
begin
  Application.HandleException(Self);
end;

procedure TCcInternalMemoryData.InternalInitFieldDefs;
begin
  // InitFieldDefsFromFields
end;

function TCcInternalMemoryData.IsCursorOpen: Boolean;
begin
  Result := FActive;
end;

{ Informational }

function TCcInternalMemoryData.GetRecordCount: Integer;
begin
  Result := FRecords.Count;
end;

function TCcInternalMemoryData.GetRecNo: Integer;
begin
  CheckActive;
  UpdateCursorPos;
  if (FRecordPos = -1) and (RecordCount > 0) then
    Result := 1
  else
    Result := FRecordPos + 1;
end;

procedure TCcInternalMemoryData.SetRecNo(Value: Integer);
begin
  if (Value > 0) and (Value <= FRecords.Count) then
  begin
    DoBeforeScroll;
    FRecordPos := Value - 1;
    Resync([]);
    DoAfterScroll;
  end;
end;

function TCcInternalMemoryData.IsSequenced: Boolean;
begin
  Result := not Filtered;
end;

function TCcInternalMemoryData.Locate(const KeyFields: string; const KeyValues: Variant;
  Options: TLocateOptions): Boolean;
begin
  DoBeforeScroll;
  Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
  if Result then
  begin
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  end;
end;

{ Table Manipulation }

procedure TCcInternalMemoryData.EmptyTable;
begin
  if Active then
  begin
    CheckBrowseMode;
    ClearRecords;
    ClearBuffers;
    DataEvent(deDataSetChange, 0);
  end;
end;

function TCcInternalMemoryData.SaveToDataSet(Dest: TDataSet; RecordCount: Integer): Integer;
var
  MovedCount: Integer;
begin
  Result := 0;
  if Dest = Self then
    Exit;
  CheckBrowseMode;
  UpdateCursorPos;
  Dest.DisableControls;
  try
    DisableControls;
    try
      if not Dest.Active then
        Dest.Open
      else
        Dest.CheckBrowseMode;
      if RecordCount > 0 then
        MovedCount := RecordCount
      else
      begin
        First;
        MovedCount := MaxInt;
      end;
      try
        while not EOF do
        begin
          Dest.Append;
          RxAssignRecord(Self, Dest, True);
          Dest.Post;
          Inc(Result);
          if Result >= MovedCount then
            Break;
          Next;
        end;
      finally
        Dest.First;
      end;
    finally
      EnableControls;
    end;
  finally
    Dest.EnableControls;
  end;
end;

{ Index Related }

procedure TCcInternalMemoryData.SortOnFields(const FieldNames: string;
  CaseInsensitive: Boolean = True; Descending: Boolean = False);
begin
  CreateIndexList(FieldNames);
  FCaseInsensitiveSort := CaseInsensitive;
  FDescendingSort := Descending;
  try
    Sort;
  except
    FreeIndexList;
    raise;
  end;
end;

procedure TCcInternalMemoryData.Sort;
var
  Pos: {$IFDEF CC_D2K9}DB.TBookmark{$ELSE}TBookmarkStr{$ENDIF CC_D2K9};
begin
  if Active and (FRecords <> nil) and (FRecords.Count > 0) then
  begin
    Pos := Bookmark;
    try
      QuickSort(0, FRecords.Count - 1, CompareRecords);
      SetBufListSize(0);
      InitBufferPointers(False);
      try
        SetBufListSize(BufferCount + 1);
      except
        SetState(dsInactive);
        CloseCursor;
        raise;
      end;
    finally
      Bookmark := Pos;
    end;
    Resync([]);
  end;
end;

procedure TCcInternalMemoryData.QuickSort(L, R: Integer; Compare: TCompareRecords);
var
  I, J: Integer;
  p: TMemoryRecord;
begin
  repeat
    I := L;
    J := R;
    p := Records[(L + R) shr 1];
    repeat
      while Compare(Records[I], p) < 0 do
        Inc(I);
      while Compare(Records[J], p) > 0 do
        Dec(J);
      if I <= J then
      begin
        FRecords.Exchange(I, J);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(L, J, Compare);
    L := I;
  until I >= R;
end;

function TCcInternalMemoryData.CompareRecords(Item1, Item2: TMemoryRecord): Integer;
var
  Data1, Data2: PChar;
  F: TField;
  I: Integer;
begin
  Result := 0;
  if FIndexList <> nil then
  begin
    for I := 0 to FIndexList.Count - 1 do
    begin
      F := TField(FIndexList[I]);
      Data1 := FindFieldData(Item1.Data, F);
      if Data1 <> nil then
      begin
        Data2 := FindFieldData(Item2.Data, F);
        if Data2 <> nil then
        begin
          if Boolean(Data1[0]) and Boolean(Data2[0]) then
          begin
            Inc(Data1);
            Inc(Data2);
            Result := CompareFields(Data1, Data2, F.DataType,
              FCaseInsensitiveSort);
          end
          else if Boolean(Data1[0]) then
            Result := 1
          else if Boolean(Data2[0]) then
            Result := -1;
          if FDescendingSort then
            Result := -Result;
        end;
      end;
      if Result <> 0 then
        Exit;
    end;
  end;
  if Result = 0 then
  begin
    if Item1.ID > Item2.ID then
      Result := 1
    else
      if Item1.ID < Item2.ID then
      Result := -1;
    if FDescendingSort then
      Result := -Result;
  end;
end;

function TCcInternalMemoryData.GetIsIndexField(Field: TField): Boolean;
begin
  if FIndexList <> nil then
    Result := FIndexList.IndexOf(Field) >= 0
  else
    Result := False;
end;

procedure TCcInternalMemoryData.CreateIndexList(const FieldNames: string);
var
  Pos: Integer;
  F: TField;
begin
  if FIndexList = nil then
    FIndexList := TList.Create
  else
    FIndexList.Clear;
  Pos := 1;
  while Pos <= Length(FieldNames) do
  begin
    F := FieldByName(ExtractFieldName(FieldNames, Pos));
    if (F.FieldKind = fkData) and (F.DataType in ftSupported - ftBlobTypes) then
      FIndexList.Add(F)
    else
      ErrorFmt(SFieldTypeMismatch, [F.DisplayName]);
  end;
end;

procedure TCcInternalMemoryData.FreeIndexList;
begin
  if FIndexList <> nil then
  begin
    FIndexList.Free;
    FIndexList := nil;
  end;
end;

{ TMemBlobStream }

constructor TMemBlobStream.Create(Field: TBlobField; Mode: TBlobStreamMode);
begin
  FMode := Mode;
  FField := Field;
  FDataSet := FField.DataSet as TCcInternalMemoryData;
  if not FDataSet.GetActiveRecBuf(FBuffer) then
    Exit;
  if not FField.Modified and (Mode <> bmRead) then
  begin
    if FField.ReadOnly then
      ErrorFmt(SFieldReadOnly, [FField.DisplayName]);
    if not(FDataSet.State in [dsEdit, dsInsert]) then
      Error(SNotEditing);
    FCached := True;
  end
  else
{$IFDEF CC_D2K14}
    FCached := (FBuffer = PByte(FDataSet.ActiveBuffer));
{$ELSE}
    FCached := (FBuffer = FDataSet.ActiveBuffer);
{$ENDIF}
  FOpened := True;
  if Mode = bmWrite then
    Truncate;
end;

destructor TMemBlobStream.Destroy;
begin
  if FOpened and FModified then
    FField.Modified := True;
  if FModified then
    try
      FDataSet.DataEvent(deFieldChange, Longint(FField));
    except
      Application.HandleException(Self);
    end;
end;

function TMemBlobStream.GetBlobFromRecord(Field: TField): TMemBlobData;
var
  Rec: TMemoryRecord;
  Pos: Integer;
begin
  Result := '';
  Pos := FDataSet.FRecordPos;
  if (Pos < 0) and (FDataSet.RecordCount > 0) then
    Pos := 0
  else
    if Pos >= FDataSet.RecordCount then
    Pos := FDataSet.RecordCount - 1;
  if (Pos >= 0) and (Pos < FDataSet.RecordCount) then
  begin
    Rec := FDataSet.Records[Pos];
    if Rec <> nil then
      Result := PMemBlobArray(Rec.FBlobs)[FField.Offset];
  end;
end;

function TMemBlobStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := 0;
  if FOpened then
  begin
    if Count > Size - FPosition then
      Result := Size - FPosition
    else
      Result := Count;
    if Result > 0 then
    begin
      if FCached then
      begin
        Move(PAnsiChar(FDataSet.GetBlobData(FField, FBuffer))[FPosition], Buffer,
          Result);
        Inc(FPosition, Result);
      end
      else
      begin
        Move(PAnsiChar(GetBlobFromRecord(FField))[FPosition], Buffer, Result);
        Inc(FPosition, Result);
      end;
    end;
  end;
end;

function TMemBlobStream.Write(const Buffer; Count: Longint): Longint;
var
  Temp: TMemBlobData;
begin
  Result := 0;
  if FOpened and FCached and (FMode <> bmRead) then
  begin
    Temp := FDataSet.GetBlobData(FField, FBuffer);
    if Length(Temp) < FPosition + Count then
      SetLength(Temp, FPosition + Count);
    Move(Buffer, PAnsiChar(Temp)[FPosition], Count);
    FDataSet.SetBlobData(FField, FBuffer, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
  end;
end;

{$IFDEF CC_D2K13}

function TMemBlobStream.Write(const Buffer: TBytes; Offset, Count: Longint): Longint;
var
  Temp: TMemBlobData;
begin
  Result := 0;
  if FOpened and FCached and (FMode <> bmRead) then
  begin
    Temp := FDataSet.GetBlobData(FField, FBuffer);
    if Length(Temp) < FPosition + Count then
      SetLength(Temp, FPosition + Count);
    Move(Buffer, PAnsiChar(Temp)[FPosition], Count);
    FDataSet.SetBlobData(FField, FBuffer, Temp);
    Inc(FPosition, Count);
    Result := Count;
    FModified := True;
  end;
end;
{$ENDIF}


function TMemBlobStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    0:
      FPosition := Offset;
    1:
      Inc(FPosition, Offset);
    2:
      FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;

{$IFDEF CC_D2K12}

function TMemBlobStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning:
      FPosition := Offset;
    soCurrent:
      Inc(FPosition, Offset);
    soEnd:
      FPosition := GetBlobSize + Offset;
  end;
  Result := FPosition;
end;
{$ENDIF}


procedure TMemBlobStream.Truncate;
begin
  if FOpened and FCached and (FMode <> bmRead) then
  begin
    FDataSet.SetBlobData(FField, FBuffer, '');
    FModified := True;
  end;
end;

function TMemBlobStream.GetBlobSize: Longint;
begin
  Result := 0;
  if FOpened then
    if FCached then
      Result := Length(FDataSet.GetBlobData(FField, FBuffer))
    else
      Result := Length(GetBlobFromRecord(FField));
end;

{ TCcMemoryData }

procedure TCcMemoryData.EmptyAndClose;
begin
  Close;
  FreeIndexList;
end;

function TCcMemoryData.LoadFromDataSet(Source: TCCQuery): Integer;
begin
  Result := LoadFromDataSet(Source, False, True, False);
end;

function TCcMemoryData.LoadFromDataSet(Source: TCCQuery; lTrimCharFields: Boolean; lCopyStructure: Boolean; lEmptyStringsToNull: Boolean): Integer;
var
  I: Integer;
  F: TField;
  str: string;
begin
  Result := 0;
  if not Source.Active then
    Exit;
  DisableControls;
  try
    Filtered := False;
    EmptyAndClose;
    if lCopyStructure then
      CopyStructure(Source);

    if not Active then
      Open;
    CheckBrowseMode;
    try
      while not Source.EOF do
      begin
        Append;
        for I := 0 to Source.FieldCount - 1 do
        begin
          if Source.FieldByIndex[I].IsNull then
            Continue
          else if (Source.FieldByIndex[I].DataType = ftString) or (Source.FieldByIndex[I].DataType = ftMemo) then
          begin
            str := Source.FieldByIndex[I].AsString;
            if lTrimCharFields then
              str := Trim(str);
            // Changed by Kick Martens
            F := FieldByName(Source.FieldByIndex[I].FieldName);
            if F = nil then
              raise Exception.createfmt('field %s not found while loading dataset %s', [Source.FieldByIndex[I].FieldName, Source.SQL.Text]);

            F.AsString := str;
            // FieldByName(Source.FieldByIndex[I].FieldName).AsString := str;
          end
          // else if Source.FieldByIndex[I].DataType = ft then
          // FieldByName(Source.FieldByIndex[I].FieldName).AsString := Trim(Source.FieldByIndex[I].AsString)
          else
          begin
            F := FieldByName(Source.FieldByIndex[I].FieldName);
            // Added by Kick Martens
            if F = nil then
              raise Exception.createfmt('field %s not found while loading dataset %s', [Source.FieldByIndex[I].FieldName, Source.SQL.Text]);
            try
              if lEmptyStringsToNull and (Source.FieldByIndex[I].AsString = '') then
                F.Clear
              else
              begin
                F.Value := Source.FieldByIndex[I].Value;
              end;
            except
              on E: EDatabaseError do
                raise Exception.Create(F.FieldName + ' = ' + Source.FieldByIndex[I].AsString + #13 + #10 + E.Message);
            end;
          end
        end;
        Post;
        Inc(Result);
        Source.Next;
      end;
    finally
      First;
    end;
  finally
    EnableControls;
  end;
end;

procedure TCcMemoryData.AddField(Name: string; DataType: TFieldType;
  Size: Integer);
var
  Field: TField;
begin
  if (FindField(name) = nil) then
  begin
    if (DataType = ftInteger) then
      Field := TIntegerField.Create(Self)
    else if (DataType = ftString) then
      Field := TStringField.Create(Self)
    else if (DataType = ftFloat) then
      Field := TFloatField.Create(Self)
    else if (DataType = ftBoolean) then
      Field := TBooleanField.Create(Self)
    else if (DataType = ftDateTime) then
      Field := TDateTimeField.Create(Self)
    else if (DataType = ftMemo) then
      Field := TMemoField.Create(Self)
    else if (DataType = ftBlob) then
      Field := TBlobField.Create(Self)
    else
      Exit;
    Field.FieldName := name;
    Field.Name := name;
    Field.DataSet := Self;
    Field.Size := Size;
    // This is to indicate that this field was created automatically
    Field.Tag := 1;
  end;
end;

procedure TCcMemoryData.CopyStructure(Source: TCCQuery);

  procedure CheckDataTypes(FieldDefs: TFieldDefs);
  var
    I: Integer;
  begin
    for I := FieldDefs.Count - 1 downto 0 do
    begin
      if not(FieldDefs.Items[I].DataType in ftSupported) then
        raise Exception.Create('Data type ' + IntToStr(Integer(FieldDefs.Items[I].DataType)) + ' not supported by CopyCat')
        // FieldDefs.Items[I].Free
      else
        CheckDataTypes(FieldDefs[I].ChildDefs);
    end;
  end;

var
  I: Integer;
begin
  CheckInactive;
  if (Source = nil) then
    Exit;
  for I := FieldCount - 1 downto 0 do
{$IFDEF NEXTGEN}
    Fields[I].DisposeOf;
{$ELSE}
    Fields[I].Free;
{$ENDIF}
  DestroyFields;

  with FieldDefs do
  begin
    Clear;
    for I := 0 to Source.FieldCount - 1 do
      with AddFieldDef do
      begin
        name := Source.FieldByIndex[I].FieldName;
        DataType := Source.FieldByIndex[I].DataType;
        if (DataType = ftString) or (DataType = ftWideString) or (DataType = ftBytes) or
          (DataType = ftFixedChar) or (DataType = ftBytes) or (DataType = ftBCD) or {$IFDEF CC_D6} (DataType = ftFMTBcd) or {$ENDIF} (DataType = ftGuid) then
          Size := Source.FieldByIndex[I].Size
        else
          Size := 0;
      end;
  end;
  CheckDataTypes(FieldDefs);
  CreateFields;
  CreateDataSetFields;
end;

procedure TCcMemoryData.SortRows(const FieldNames: string; CaseInsensitive: Boolean);
begin
  SortOnFields(FieldNames, CaseInsensitive, False);
end;

function Min(A, B: Longint): Longint;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

procedure TCcMemoryData.OpenCursor(InfoQuery: Boolean);
begin
  if (not InfoQuery) then
  begin
    if FAutoCreateFieldDefs then
      if FieldCount > 0 then
        FieldDefs.Clear;
    InitFieldDefsFromFields;
  end;
  FActive := True;
  inherited OpenCursor(InfoQuery);
end;

constructor TCcMemoryData.Create(AOwner: TComponent);
begin
  inherited;
  FAutoCreateFieldDefs := True;
  lFirst := True;
end;

function TCcMemoryData.LoadFromDataSet(Source: TDataSet; RecordCount: Integer;
  Mode: TLoadMode): Integer;
var
  SourceActive: Boolean;
  MovedCount: Integer;
begin
  Result := 0;
  if Source = Self then
    Exit;
  SourceActive := Source.Active;
  Source.DisableControls;
  try
    DisableControls;
    try
      Filtered := False;
      with Source do
      begin
        Open;
        CheckBrowseMode;
        UpdateCursorPos;
      end;
      if Mode = lmCopy then
      begin
        Close;
        CopyStructure(Source);
      end;
      EmptyAndClose;
      if not Active then
        Open;
      CheckBrowseMode;
      if RecordCount > 0 then
        MovedCount := RecordCount
      else
      begin
        Source.First;
        MovedCount := MaxInt;
      end;
      try
        while not Source.EOF do
        begin
          Append;
          RxAssignRecord(Source, Self, True);
          Post;
          Inc(Result);
          if Result >= MovedCount then
            Break;
          Source.Next;
        end;
      finally
        First;
      end;
    finally
      EnableControls;
    end;
  finally
    if not SourceActive then
      Source.Close;
    Source.EnableControls;
  end;
end;

procedure TCcMemoryData.CopyStructure(Source: TDataSet);

  procedure CheckDataTypes(FieldDefs: TFieldDefs);
  var
    I: Integer;
  begin
    for I := FieldDefs.Count - 1 downto 0 do
    begin
      if not(FieldDefs.Items[I].DataType in ftSupported) then
        raise Exception.Create('Data type ' + IntToStr(Integer(FieldDefs.Items[I].DataType)) + ' not supported by CopyCat')
        // FieldDefs.Items[I].Free
      else
        CheckDataTypes(FieldDefs[I].ChildDefs);
    end;
  end;

var
  I: Integer;
begin
  CheckInactive;
  for I := FieldCount - 1 downto 0 do
    Fields[I].Free;
  if (Source = nil) then
    Exit;
  Source.FieldDefs.Update;
  FieldDefs := Source.FieldDefs;

  CheckDataTypes(FieldDefs);
  CreateFields;
  CreateDataSetFields;
end;

procedure TCcMemoryData.CreateDataSetFields;
begin
  Open;
end;

procedure TCcMemoryData.DoBeforeOpen;
begin
  inherited;
end;

procedure TCcMemoryData.DoBeforeClose;
begin
  FreeIndexList;
  inherited;
end;

function TCcInternalMemoryData.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  Result := DefaultFieldClasses[FieldType];
{$IFDEF CC_D2K6}
  if FieldType = ftWideMemo then
    Result := TCcWideMemoField
  else
{$ENDIF}
  if FieldType = ftMemo then
    Result := TCcMemoField
  else if FieldType = ftOraClob then
    Result := TCcMemoField;
end;

{$IFDEF CC_D2K6}
function TCcWideMemoField.GetIsNull: Boolean;
var
  LStream: TStream;
begin
  LStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    Result := (LStream.Size = 0);
  finally
    LStream.Free;
  end;
end;

function TCcWideMemoField.GetAsVariant: Variant;
begin
  if IsNull then
    Result := Null
  else
    Result := GetAsString;
end;

procedure TCcWideMemoField.SetVarValue(const Value: Variant);
begin
  if Value = Null then
    Clear
  else
    SetAsString(Value);
end;

{$ENDIF}

function TCcMemoField.GetIsNull: Boolean;
var
  LStream: TStream;
begin
  LStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    Result := (LStream.Size = 0);
  finally
    LStream.Free;
  end;
end;

function TCcMemoField.GetAsVariant: Variant;
begin
  if IsNull then
    Result := Null
  else
  begin
{$IFDEF CC_D2K9}
{$IFDEF NEXTGEN}
    Result := GetAsString;
{$ELSE}
    Result := GetAsAnsiString;
{$ENDIF NEXTGEN}
{$ELSE}
    Result := GetAsString;
{$ENDIF}
  end;
end;

procedure TCcMemoField.SetVarValue(const Value: Variant);
begin
  if Value = Null then
    Clear
  else
  begin
{$IFDEF CC_D2K9}
{$IFDEF NEXTGEN}
    SetAsString(Value);
{$ELSE}
    SetAsAnsiString(Value);
{$ENDIF NEXTGEN}
{$ELSE}
    SetAsString(Value);
{$ENDIF}
  end;
end;

{$ENDIF}

end.


