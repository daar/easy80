unit AppSettings;

{$mode objfpc}{$H+}

interface

uses
  Typinfo, Classes, SysUtils, SynEdit, khexeditor, kcontrols, keditcommon;

type

  { TCustomSettings }

  TCustomSettings = class(TPersistent)
  private
    FFileName: string;
    FIgnoreProperty: TStrings;
    procedure SetIgnoreProperty(Value: TStrings);
  protected
  public
    constructor Create(const FileName: string); virtual;
    destructor Destroy; override;
    procedure Save; virtual;
    procedure Load; virtual;
    property IgnoreProperty: TStrings read FIgnoreProperty write SetIgnoreProperty;
  end;

  { TAppSettings }

  TAppSettings = class(TCustomSettings)
  private
    FHexAddressMode: TKHexEditorAddressMode;
    FHexAddressPrefix: string;
    FHexAddressSize: integer;
    FHexCharSpacing: integer;
    FHexDigitGrouping: integer;
    FHexDisableDrawStyle: TKEditDisabledDrawStyle;
    FHexDropFiles: boolean;
    FHexFontName: string;
    FHexFontSize: integer;
    FHexFontStyleBold: boolean;
    FHexFontStyleItalic: boolean;
    FHexGroupUndo: boolean;
    FHexLineHeightPercent: integer;
    FHexLineSize: integer;
    FHexShowAddress: boolean;
    FHexShowDigits: boolean;
    FHexShowHorzLines: boolean;
    FHexShowInactiveCaret: boolean;
    FHexShowSeparators: boolean;
    FHexShowText: boolean;
    FHexShowVertLines: boolean;
    FHexUndoAfterSave: boolean;
    FHexUndoLimit: integer;
    FLanguage: string;
    FLastProjectFolder: string;
    FReOpenAtStart: boolean;
  public
    constructor Create(const FileName: string); override;
  published
    //all published properties will be written to the settings file

    //General
    property Language: string read FLanguage write FLanguage;
    property ReOpenAtStart: boolean read FReOpenAtStart write FReOpenAtStart;
    property LastProjectFolder: string read FLastProjectFolder write FLastProjectFolder;

    //Hex editor general
    property HexDropFiles: boolean read FHexDropFiles write FHexDropFiles;
    property HexUndoAfterSave: boolean read FHexUndoAfterSave write FHexUndoAfterSave;
    property HexGroupUndo: boolean read FHexGroupUndo write FHexGroupUndo;

    property HexShowAddress: boolean read FHexShowAddress write FHexShowAddress;
    property HexShowDigits: boolean read FHexShowDigits write FHexShowDigits;
    property HexShowText: boolean read FHexShowText write FHexShowText;
    property HexShowHorzLines: boolean read FHexShowHorzLines write FHexShowHorzLines;
    property HexShowVertLines: boolean read FHexShowVertLines write FHexShowVertLines;
    property HexShowSeparators: boolean read FHexShowSeparators write FHexShowSeparators;
    property HexShowInactiveCaret: boolean read FHexShowInactiveCaret write FHexShowInactiveCaret;

    property HexAddressPrefix: string read FHexAddressPrefix write FHexAddressPrefix;
    property HexAddressSize: integer read FHexAddressSize write FHexAddressSize;
    property HexCharSpacing: integer read FHexCharSpacing write FHexCharSpacing;
    property HexLineSize: integer read FHexLineSize write FHexLineSize;
    property HexDigitGrouping: integer read FHexDigitGrouping write FHexDigitGrouping;
    property HexLineHeightPercent: integer read FHexLineHeightPercent write FHexLineHeightPercent;
    property HexUndoLimit: integer read FHexUndoLimit write FHexUndoLimit;
    property HexDisableDrawStyle:TKEditDisabledDrawStyle read FHexDisableDrawStyle write FHexDisableDrawStyle;
    property HexAddressMode:TKHexEditorAddressMode read FHexAddressMode write FHexAddressMode;

    property HexFontName: string read FHexFontName write FHexFontName;
    property HexFontStyleBold: boolean read FHexFontStyleBold write FHexFontStyleBold;
    property HexFontStyleItalic: boolean read FHexFontStyleItalic write FHexFontStyleItalic;
    property HexFontSize: integer read FHexFontSize write FHexFontSize;
 end;

procedure CloneClass(Src, Dest: TPersistent);
function GetPropCount(Instance: TPersistent): integer;
function GetPropName(Instance: TPersistent; Index: integer): string;

procedure UpdateSynEdit(var edt: TSynEdit);
procedure UpdateHexEditor(var edt: TKHexEditor);

var
  Settings: TAppSettings;

implementation

uses
  XMLConf;

procedure UpdateSynEdit(var edt: TSynEdit);
begin

end;

procedure UpdateHexEditor(var edt: TKHexEditor);
var
  Options: TKEditOptions;
  DrawStyles: TKHexEditorDrawStyles;
begin
  Options := [];
  if Settings.HexDropFiles then
    Include(Options, eoDropFiles);
  if Settings.HexGroupUndo then
    Include(Options, eoGroupUndo);
  if Settings.HexUndoAfterSave then
    Include(Options, eoUndoAfterSave);
  edt.Options := Options;

  DrawStyles := [];
  if Settings.HexShowAddress then
    Include(DrawStyles, edAddress);
  if Settings.HexShowDigits then
    Include(DrawStyles, edDigits);
  if Settings.HexShowText then
    Include(DrawStyles, edText);
  if Settings.HexShowHorzLines then
    Include(DrawStyles, edHorzLines);
  if Settings.HexShowVertLines then
    Include(DrawStyles, edVertLines);
  if Settings.HexShowSeparators then
    Include(DrawStyles, edSeparators);
  if Settings.HexShowInactiveCaret then
    Include(DrawStyles, edInactiveCaret);
  edt.DrawStyles := DrawStyles;

  edt.AddressPrefix := Settings.HexAddressPrefix;
  edt.AddressSize := Settings.HexAddressSize;
  edt.CharSpacing := Settings.HexCharSpacing;
  edt.LineSize := Settings.HexLineSize;
  edt.DigitGrouping := Settings.HexDigitGrouping;
  edt.LineHeightPercent := Settings.HexLineHeightPercent;
  edt.UndoLimit := Settings.HexUndoLimit;

  edt.AddressMode := Settings.HexAddressMode;
  edt.DisabledDrawStyle := Settings.HexDisableDrawStyle;

  edt.Font.Size :=  Settings.HexFontSize;
  edt.Font.Name := Settings.HexFontName;
  edt.Font.Bold := Settings.HexFontStyleBold;
  edt.Font.Italic := Settings.HexFontStyleItalic;
end;

//returns the number of properties of a given object
function GetPropCount(Instance: TPersistent): integer;
var
  Data: PTypeData;
begin
  Data := GetTypeData(Instance.Classinfo);
  Result := Data^.PropCount;
end;

//returns the property name of an instance at a certain index
function GetPropName(Instance: TPersistent; Index: integer): string;
var
  PropList: PPropList;
  PropInfo: PPropInfo;
  Data: PTypeData;
begin
  Result := '';
  Data := GetTypeData(Instance.Classinfo);
  GetMem(PropList, Data^.PropCount * Sizeof(PPropInfo));
  try
    GetPropInfos(Instance.ClassInfo, PropList);
    PropInfo := PropList^[Index];
    Result := PropInfo^.Name;
  finally
    FreeMem(PropList, Data^.PropCount * Sizeof(PPropInfo));
  end;
end;

//copy RTTI properties from one class to another
procedure CloneClass(Src, Dest: TPersistent);
var
  Index: integer;
  SrcPropInfo: PPropInfo;
  DestPropInfo: PPropInfo;
begin
  for Index := 0 to GetPropCount(Src) - 1 do
  begin
    if (CompareText(GetPropName(Src, Index), 'Name') = 0) then
      Continue;
    SrcPropInfo := GetPropInfo(Src.ClassInfo, GetPropName(Src, Index));
    DestPropInfo := GetPropInfo(Dest.ClassInfo, GetPropName(Src, Index));
    if DestPropInfo <> nil then
      if DestPropInfo^.PropType^.Kind = SrcPropInfo^.PropType^.Kind then
      begin
        case DestPropInfo^.PropType^.Kind of
          tkLString, tkString:
            SetStrProp(Dest, DestPropInfo, GetStrProp(Src, SrcPropInfo));
          tkInteger, tkChar, tkEnumeration, tkSet:
            SetOrdProp(Dest, DestPropInfo, GetOrdProp(Src, SrcPropInfo));
          tkFloat: SetFloatProp(Dest, DestPropInfo, GetFloatProp(Src, SrcPropInfo));
          tkClass:
          begin
            if (TPersistent(GetOrdProp(Src, SrcPropInfo)) is TStrings) and
              (TPersistent(GetOrdProp(Dest, DestPropInfo)) is TStrings) then
              TPersistent(GetOrdProp(Dest, DestPropInfo)).Assign(
                TPersistent(GetOrdProp(Src, SrcPropInfo)));
          end;
          tkMethod: SetMethodProp(Dest, DestPropInfo, GetMethodProp(Src, SrcPropInfo));
        end;
      end;
  end;
end;

{ TAppSettings }

constructor TAppSettings.Create(const FileName: string);
begin
  inherited Create(FileName);

  //initialize all settings here

  //General
  FLanguage := 'System language';
  FReOpenAtStart := True;
  FLastProjectFolder := '';

  //Hex editor general
  FHexDropFiles := True;
  FHexUndoAfterSave := False;
  FHexGroupUndo := True;

  FHexShowAddress := True;
  FHexShowDigits := True;
  FHexShowText := True;
  FHexShowHorzLines := False;
  FHexShowVertLines := False;
  FHexShowSeparators := True;
  FHexShowInactiveCaret := True;

  FHexAddressPrefix := '0x';
  FHexAddressSize := 8;
  FHexCharSpacing := 0;
  FHexLineSize := 16;
  FHexDigitGrouping := 2;
  FHexLineHeightPercent := 130;
  FHexUndoLimit := 1000;

  FHexDisableDrawStyle := eddBright;
  FHexAddressMode := eamHex;

  FHexFontName := 'Courier New';
  FHexFontSize := 10;
  FHexFontStyleBold := False;
  FHexFontStyleItalic := False;
end;

{ TCustomSettings }

procedure TCustomSettings.SetIgnoreProperty(Value: TStrings);
begin
  FIgnoreProperty.Assign(Value);
end;

constructor TCustomSettings.Create(const FileName: string);
begin
  FIgnoreProperty := TStringList.Create;
  FFileName := FileName;
end;

destructor TCustomSettings.Destroy;
begin
  FIgnoreProperty.Free;

  inherited Destroy;
end;

procedure TCustomSettings.Save;
var
  xml: TXMLConfig;
  idx: integer;
  PropName, PropPath: string;
  pt: TTypeKind;
begin
  if FFileName = '' then
    exit;

  xml := TXMLConfig.Create(nil);
  try
    xml.Filename := FFileName;

    for idx := 0 to GetPropCount(Self) - 1 do
    begin
      PropName := GetPropName(Self, idx);
      if (FIgnoreProperty.Indexof(Propname) >= 0) then
        Continue;

      PropPath := '/Settings/' + PropName + '/Value';
      pt := PropType(Self, GetPropName(Self, idx));
      case pt of
        tkSString, tkLString, tkAString, tkWString, tkUString:
          xml.SetValue(PropPath, GetStrProp(Self, PropName));

        tkChar, tkWChar, tkUChar, tkEnumeration, tkInteger, tkQWord:
          xml.SetValue(PropPath, GetOrdProp(Self, PropName));

        tkBool:
          xml.SetValue(PropPath, GetEnumProp(Self, PropName));

        tkInt64:
          xml.SetValue(PropPath, GetInt64Prop(Self, PropName));

        tkFloat:
          xml.SetValue(PropPath, FloatToStr(GetFloatProp(Self, PropName)));

        tkClass:
        begin
          //saving classes
          if (TPersistent(GetOrdProp(Self, PropName)) is TStrings) then
            xml.SetValue(PropPath, TStrings(GetOrdProp(Self, PropName)).Text);
        end;
        else
          //this should never occur!
          raise Exception.CreateFmt('Unknown property type for property %s', [PropName]);
      end;
    end;
  finally
    xml.Flush;
    xml.Free;
  end;
end;

procedure TCustomSettings.Load;
var
  xml: TXMLConfig;
  idx: integer;
  PropName, PropPath: string;
  pt: TTypeKind;
begin
  if FFileName = '' then
    exit;

  xml := TXMLConfig.Create(nil);
  try
    xml.Filename := FFileName;

    for idx := 0 to GetPropCount(Self) - 1 do
    begin
      PropName := GetPropName(Self, idx);
      if (FIgnoreProperty.Indexof(Propname) >= 0) then
        Continue;

      PropPath := '/Settings/' + PropName + '/Value';
      pt := PropType(Self, GetPropName(Self, idx));
      case pt of
        tkSString, tkLString, tkAString, tkWString, tkUString:
          SetStrProp(Self, PropName, xml.GetValue(PropPath, GetStrProp(Self,PropName)));

        tkChar, tkWChar, tkUChar, tkEnumeration, tkInteger, tkQWord:
          SetOrdProp(Self, PropName, xml.GetValue(PropPath, GetOrdProp(Self,PropName)));

        tkBool:
          SetEnumProp(Self, PropName, xml.GetValue(PropPath, GetEnumProp(Self,PropName)));

        tkInt64:
          Setint64Prop(Self, PropName, xml.GetValue(PropPath, GetInt64Prop(Self,PropName)));

        tkFloat:
          SetFloatProp(Self, PropName, StrToFloat(xml.GetValue(PropPath, FloatToStr(GetFloatProp(Self,PropName)))));

        tkClass:
        begin
          //saving classes
          if (TPersistent(GetOrdProp(Self, PropName)) is TStrings) then
            TStrings(GetOrdProp(Self, PropName)).Text := xml.GetValue(PropPath, TStrings(GetOrdProp(Self, PropName)).Text);
        end;
        else
          //this should never occur!
          raise Exception.CreateFmt('Unknown property type for property %s', [PropName]);
      end;
    end;
  finally
    xml.Free;
  end;
end;

initialization
  Settings := TAppSettings.Create('easy80-ide.xml');
  Settings.Load;

finalization
  Settings.Free;

end.
