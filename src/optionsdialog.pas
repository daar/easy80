unit OptionsDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TreeFilterEdit, Forms, Controls, Graphics,
  Dialogs, ButtonPanel, ExtCtrls, ComCtrls, StdCtrls, Spin, IDELocale, ResourceStrings,
  Types, KControls, KHexEditor, KEditCommon;

type

  { TOptionsDlg }

  TOptionsDlg = class(TForm)
    BUColorChange: TButton;
    ButtonPanel1: TButtonPanel;
    CBDropFiles: TCheckBox;
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
    CBFontName: TComboBox;
    EDAddressPrefix: TEdit;
    EDAddressSize: TSpinEdit;
    EDCharSpacing: TSpinEdit;
    EDDigitGrouping: TSpinEdit;
    EDFontSize: TSpinEdit;
    EDLineHeightPercent: TSpinEdit;
    EDLineSize: TSpinEdit;
    EDUndoLimit: TSpinEdit;
    FontDialog1: TFontDialog;
    GBAppearance: TGroupBox;
    GBColors: TGroupBox;
    GBGeneral: TGroupBox;
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
    Panel1: TPanel;
    PNFontSample: TPanel;
    RGAddressMode: TRadioGroup;
    RGDisabledDrawStyle: TRadioGroup;
    SHColor: TShape;
    Splitter1: TSplitter;
    HexEditorTabSheet: TTabSheet;
    CompilerTabSheet: TTabSheet;
    AssemblerTabSheet: TTabSheet;
    GeneralTabSheet: TTabSheet;
    OptionsTreeFilterEdit: TTreeFilterEdit;
    OptionsTreeView: TTreeView;
    HexEditorColorsTabSheet: TTabSheet;
    HexEditorFontTabSheet: TTabSheet;
    procedure BUColorChangeClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure UpdateFontSample(Sender: TObject);
    procedure LiBColorsClick(Sender: TObject);
    procedure LiBColorsDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure OKButtonClick(Sender: TObject);
    procedure OptionsTreeViewClick(Sender: TObject);
  private
    FColors: TKColorArray;
    procedure InitColors(var Colors: TKColorArray);
  end;

var
  OptionsDlg: TOptionsDlg;

implementation

{$R *.lfm}

uses
  LCLTranslator, AppSettings;

{ TOptionsDlg }

procedure TOptionsDlg.OptionsTreeViewClick(Sender: TObject);
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

procedure TOptionsDlg.InitColors(var Colors: TKColorArray);
var
  i: TKHexEditorColorIndex;
begin
  SetLength(Colors, ciHexEditorColorsMax + 1);
  for i := 0 to Length(Colors) - 1 do
    Colors[i] := GetColorSpec(i).Def;
end;

procedure TOptionsDlg.UpdateFontSample(Sender: TObject);
begin
  if CBFontName.Text <> '' then
  begin
    PNFontSample.Font.Name := CBFontName.Text;
    PNFontSample.Font.Size := EDFontSize.Value;
    PNFontSample.Font.Bold := CBFontStyleBold.Checked;
    PNFontSample.Font.Italic := CBFontStyleItalic.Checked;
  end;
end;

procedure TOptionsDlg.LiBColorsClick(Sender: TObject);
begin
  SHColor.Brush.Color := FColors[TKHexEditorColorIndex(LiBColors.ItemIndex)];
end;

procedure TOptionsDlg.LiBColorsDrawItem(Control: TWinControl;
  Index: integer; ARect: TRect; State: TOwnerDrawState);
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

procedure TOptionsDlg.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TOptionsDlg.FormActivate(Sender: TObject);
var
  i: integer;
begin
  OptionsPageControl.ShowTabs := false;

  OptionsTreeView.Items[0].Selected := true;
  OptionsPageControl.ActivePageIndex := 0;

  LoadTranslations(LocaleComboBox);

  //General
  LocaleComboBox.Text := Settings.Language;

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

procedure TOptionsDlg.BUColorChangeClick(Sender: TObject);
begin
  CDChange.Color := FColors[TKHexEditorColorIndex(LiBColors.ItemIndex)];
  if CDChange.Execute then
  begin
    FColors[TKHexEditorColorIndex(LiBColors.ItemIndex)] := CDChange.Color;
    LiBColors.Invalidate;
    LiBColorsClick(nil);
  end;
end;

procedure TOptionsDlg.OKButtonClick(Sender: TObject);
begin
  //save all settings

  //General
  Settings.Language := LocaleComboBox.Text;

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
end;

end.
