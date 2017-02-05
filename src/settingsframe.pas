unit SettingsFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TreeFilterEdit, Forms, Controls, StdCtrls, ExtCtrls, ComCtrls, Spin, Dialogs, Types,
  IDELocale, ResourceStrings, KControls, KHexEditor, KEditCommon, Graphics, AppSettings;

type

  { TSettingsFrame }

  TSettingsFrame = class(TFrame)
    AssemblerTabSheet: TTabSheet;
    BUColorChange: TButton;
    CBDropFiles: TCheckBox;
    CBFontName: TComboBox;
    CBFontStyleBold: TCheckBox;
    CBFontStyleItalic: TCheckBox;
    CBGroupUndo: TCheckBox;
    CBShowAddress: TCheckBox;
    CBShowDigits: TCheckBox;
    CBShowHorzLines: TCheckBox;
    CBShowInactiveCaret: TCheckBox;
    CBShowSeparators: TCheckBox;
    CBShowText: TCheckBox;
    CBShowVertLines: TCheckBox;
    CBUndoAfterSave: TCheckBox;
    CDChange: TColorDialog;
    CompilerTabSheet: TTabSheet;
    EDAddressPrefix: TEdit;
    EDAddressSize: TSpinEdit;
    EDCharSpacing: TSpinEdit;
    EDDigitGrouping: TSpinEdit;
    EDFontSize: TSpinEdit;
    EDLineHeightPercent: TSpinEdit;
    EDLineSize: TSpinEdit;
    EDUndoLimit: TSpinEdit;
    GBAppearance: TGroupBox;
    GBColors: TGroupBox;
    GBGeneral: TGroupBox;
    GeneralTabSheet: TTabSheet;
    HexEditorColorsTabSheet: TTabSheet;
    HexEditorFontTabSheet: TTabSheet;
    HexEditorTabSheet: TTabSheet;
    LBAddressPrefix: TLabel;
    LBAddressSize: TLabel;
    LBAttributes: TLabel;
    LBbytes: TLabel;
    LBbytes2: TLabel;
    LBCharSpacing: TLabel;
    LBDigitGrouping: TLabel;
    LBFontName: TLabel;
    LBFontSize: TLabel;
    LBHighFG: TLabel;
    LBLineHeightPercent: TLabel;
    LBLineSize: TLabel;
    LBpercent: TLabel;
    LBpoints: TLabel;
    LBSample: TLabel;
    LBUndoLimit: TLabel;
    LiBColors: TListBox;
    LocaleComboBox: TComboBox;
    LocaleLabel: TLabel;
    OptionsPageControl: TPageControl;
    OptionsTreeFilterEdit: TTreeFilterEdit;
    OptionsTreeView: TTreeView;
    Panel1: TPanel;
    PNFontSample: TPanel;
    ReOpenCheckBox: TCheckBox;
    RGAddressMode: TRadioGroup;
    RGDisabledDrawStyle: TRadioGroup;
    SHColor: TShape;
    Splitter1: TSplitter;
    procedure BUColorChangeClick(Sender: TObject);
    procedure LiBColorsClick(Sender: TObject);
    procedure LiBColorsDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure OptionsTreeViewClick(Sender: TObject);
  private
    FColors: TKColorArray;
    procedure InitColors(var Colors: TKColorArray);
    procedure UpdateFontSample(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.lfm}

{ TSettingsFrame }

procedure TSettingsFrame.OptionsTreeViewClick(Sender: TObject);
var
  node: TTreeNode;
  i: integer;
begin
  node := OptionsTreeView.Selected;
  if node <> nil then
  begin
    for i := 0 to OptionsPageControl.PageCount - 1 do
    begin
      if OptionsPageControl.Pages[i].Caption = node.Text then
      begin
        OptionsPageControl.ActivePageIndex := i;
        exit;
      end;
    end;
  end;
end;

procedure TSettingsFrame.LiBColorsClick(Sender: TObject);
begin
  SHColor.Brush.Color := FColors[TKHexEditorColorIndex(LiBColors.ItemIndex)];
end;

procedure TSettingsFrame.BUColorChangeClick(Sender: TObject);
begin
  CDChange.Color := FColors[TKHexEditorColorIndex(LiBColors.ItemIndex)];
  if CDChange.Execute then
  begin
    FColors[TKHexEditorColorIndex(LiBColors.ItemIndex)] := CDChange.Color;
    LiBColors.Invalidate;
    LiBColorsClick(nil);
  end;
end;

procedure TSettingsFrame.LiBColorsDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  with (Control as TListBox).Canvas do
  begin
    FillRect(ARect);
    Brush.Color := FColors[TKHexEditorColorIndex(Index)];
    Pen.Color := clWindowText;
    Rectangle(ARect.Left + 2, ARect.Top + 1, ARect.Left + 16, ARect.Bottom - 1);
    Brush.Color := clDefault;
    Brush.Style := bsClear;
    TextOut(ARect.Left + 20, ARect.Top, LiBColors.Items[Index]);
  end;
end;

procedure TSettingsFrame.InitColors(var Colors: TKColorArray);
var
  i: TKHexEditorColorIndex;
begin
  SetLength(Colors, ciHexEditorColorsMax + 1);
  for i := 0 to Length(Colors) - 1 do
    Colors[i] := GetColorSpec(i).Def;
end;

procedure TSettingsFrame.UpdateFontSample(Sender: TObject);
begin
  if CBFontName.Text <> '' then
  begin
    PNFontSample.Font.Name := CBFontName.Text;
    PNFontSample.Font.Size := EDFontSize.Value;
    PNFontSample.Font.Bold := CBFontStyleBold.Checked;
    PNFontSample.Font.Italic := CBFontStyleItalic.Checked;
  end;
end;

constructor TSettingsFrame.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited Create(AOwner);

  OptionsPageControl.ShowTabs := false;

  OptionsTreeView.Items[0].Selected := true;
  OptionsPageControl.ActivePageIndex := 0;

  LoadTranslations(LocaleComboBox);

  //General
  LocaleComboBox.Text := Settings.Language;
  ReOpenCheckBox.Checked := Settings.ReOpenAtStart;

  //Hex editor general
  CBDropFiles.Checked := Settings.HexDropFiles;
  CBUndoAfterSave.Checked := Settings.HexUndoAfterSave;
  CBGroupUndo.Checked := Settings.HexGroupUndo;

  CBShowAddress.Checked := Settings.HexShowAddress;
  CBShowDigits.Checked := Settings.HexShowDigits;
  CBShowText.Checked := Settings.HexShowText;
  CBShowHorzLines.Checked := Settings.HexShowHorzLines;
  CBShowVertLines.Checked := Settings.HexShowVertLines;
  CBShowSeparators.Checked := Settings.HexShowSeparators;
  CBShowInactiveCaret.Checked := Settings.HexShowInactiveCaret;

  EDAddressPrefix.Text := Settings.HexAddressPrefix;
  EDAddressSize.Value := Settings.HexAddressSize;
  EDCharSpacing.Value := Settings.HexCharSpacing;
  EDLineSize.Value := Settings.HexLineSize;
  EDDigitGrouping.Value := Settings.HexDigitGrouping;
  EDLineHeightPercent.Value := Settings.HexLineHeightPercent;
  EDUndoLimit.Value := Settings.HexUndoLimit;

  RGDisabledDrawStyle.ItemIndex := Ord(Settings.HexDisableDrawStyle);
  RGAddressMode.ItemIndex := Ord(Settings.HexAddressMode);

  //Hex editor fonts
  CBFontName.Items.Assign(Screen.Fonts);
  CBFontName.Text := Settings.HexFontName;
  CBFontStyleBold.Checked := Settings.HexFontStyleBold;
  CBFontStyleItalic.Checked := Settings.HexFontStyleItalic;
  EDFontSize.Value := Settings.HexFontSize;

  //Hex editor colors
  InitColors(FColors);
  for i := 0 to Length(FColors) - 1 do
    LiBColors.Items.Add(GetColorSpec(i).Name);
end;

destructor TSettingsFrame.Destroy;
begin
  //save all settings

  //General
  Settings.Language := LocaleComboBox.Text;
  Settings.ReOpenAtStart := ReOpenCheckBox.Checked;

  //Hex editor general
  Settings.HexDropFiles := CBDropFiles.Checked;
  Settings.HexUndoAfterSave := CBUndoAfterSave.Checked;
  Settings.HexGroupUndo := CBGroupUndo.Checked;

  Settings.HexShowAddress := CBShowAddress.Checked;
  Settings.HexShowDigits := CBShowDigits.Checked;
  Settings.HexShowText := CBShowText.Checked;
  Settings.HexShowHorzLines := CBShowHorzLines.Checked;
  Settings.HexShowVertLines := CBShowVertLines.Checked;
  Settings.HexShowSeparators := CBShowSeparators.Checked;
  Settings.HexShowInactiveCaret := CBShowInactiveCaret.Checked;

  Settings.HexAddressPrefix := EDAddressPrefix.Text;
  Settings.HexAddressSize := EDAddressSize.Value;
  Settings.HexCharSpacing := EDCharSpacing.Value;
  Settings.HexLineSize := EDLineSize.Value;
  Settings.HexDigitGrouping := EDDigitGrouping.Value;
  Settings.HexLineHeightPercent := EDLineHeightPercent.Value;
  Settings.HexUndoLimit := EDUndoLimit.Value;

  Settings.HexDisableDrawStyle := TKEditDisabledDrawStyle(RGDisabledDrawStyle.ItemIndex);
  Settings.HexAddressMode := TKHexEditorAddressMode(RGAddressMode.ItemIndex);

  //Hex editor fonts
  Settings.HexFontName := CBFontName.Text;
  Settings.HexFontStyleBold := CBFontStyleBold.Checked;
  Settings.HexFontStyleItalic := CBFontStyleItalic.Checked;
  Settings.HexFontSize := EDFontSize.Value;

  //Hex editor colors

  Settings.Save;

  inherited Destroy;
end;

end.

