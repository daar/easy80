unit AppSettings;

{$mode objfpc}{$H+}

interface

uses
  Typinfo, Classes, SysUtils, SynEdit, khexeditor;

const
{$IFDEF MSWINDOWS}
  DefaultFontName = 'Consolas';
{$ELSE}
  {$IFDEF LINUX}
    DefaultFontName = 'DejaVu Sans Mono';
  {$ELSE}
    {$IFDEF DARWIN}
      DefaultFontName = 'Menlo';
    {$ELSE}
      DefaultFontName = 'Courier New';
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

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
    FAsmVerbose: boolean;
    FFontName: string;
    FFontSize: integer;
    FLanguage: string;
    FLastProjectFolder: string;
    FReOpenAtStart: boolean;
  public
    constructor Create(const FileName: string); override;

    procedure Load; override;
  published
    //all published properties will be written to the settings file

    //General
    property Language: string read FLanguage write FLanguage;
    property ReOpenAtStart: boolean read FReOpenAtStart write FReOpenAtStart;
    property LastProjectFolder: string read FLastProjectFolder write FLastProjectFolder;

    //Editor
    property FontName: string read FFontName write FFontName;
    property FontSize: integer read FFontSize write FFontSize;

    //assembler
    property AsmVerbose: boolean read FAsmVerbose write FAsmVerbose;
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
  Forms, Graphics, XMLConf;

procedure UpdateSynEdit(var edt: TSynEdit);
begin
  edt.Font.Name := Settings.FontName;
  edt.Font.Pitch := fpDefault;
  edt.Font.Quality := fqDefault;
  edt.Font.Size := Settings.FontSize;
end;

procedure UpdateHexEditor(var edt: TKHexEditor);
begin
  edt.Font.Name := Settings.FontName;
  edt.Font.Pitch := fpDefault;
  edt.Font.Quality := fqDefault;
  edt.Font.Size := Settings.FontSize;
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

  //Editor
  FFontName := DefaultFontName;

  //Assembler
  FAsmVerbose := True;

  FFontSize := 10;
end;

procedure TAppSettings.Load;
begin
  inherited Load;

  //assign the default font in case the settings font is not available on the system
  if Screen.Fonts.IndexOf(FontName) = -1 then
  begin
    FontName := DefaultFontName;

    //in case not found on the system then assign fallback font
    if Screen.Fonts.IndexOf(FontName) = -1 then
      FontName := 'Courier New';

    //if all fails then assign the first available font in the list
    if Screen.Fonts.IndexOf(FontName) = -1 then
      FontName := Screen.Fonts[0];
  end;
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
