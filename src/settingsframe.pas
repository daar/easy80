unit SettingsFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, TreeFilterEdit, Forms, StdCtrls, ExtCtrls, ComCtrls, Spin, Dialogs,
  IDELocale, AppSettings;

type

  { TSettingsFrame }

  TSettingsFrame = class(TFrame)
    AssemblerTabSheet: TTabSheet;
    CDChange: TColorDialog;
    AsmVerboseCheckBox: TCheckBox;
    CompilerTabSheet: TTabSheet;
    FontSizeSpinEdit: TSpinEdit;
    GeneralTabSheet: TTabSheet;
    HexEditorFontTabSheet: TTabSheet;
    FontNameLabel: TLabel;
    FontSizeLabel: TLabel;
    LocaleComboBox: TComboBox;
    FontNameComboBox: TComboBox;
    LocaleLabel: TLabel;
    OptionsPageControl: TPageControl;
    OptionsTreeFilterEdit: TTreeFilterEdit;
    OptionsTreeView: TTreeView;
    Panel1: TPanel;
    ReOpenCheckBox: TCheckBox;
    Splitter1: TSplitter;
    procedure OnComponentChange(Sender: TObject);
    procedure OptionsTreeViewClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  private
    initialize: boolean;
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

procedure TSettingsFrame.OnComponentChange(Sender: TObject);
begin
  if initialize then
    exit;

  //General
  Settings.Language := LocaleComboBox.Text;
  Settings.ReOpenAtStart := ReOpenCheckBox.Checked;

  //Editor general
  Settings.FontName := FontNameComboBox.Text;
  Settings.FontSize := FontSizeSpinEdit.Value;

  //assembler
  Settings.AsmVerbose := AsmVerboseCheckBox.Checked;
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

  initialize := True;

  //General
  LocaleComboBox.Text := Settings.Language;
  ReOpenCheckBox.Checked := Settings.ReOpenAtStart;

  //Editor
  FontNameComboBox.Items.Assign(Screen.Fonts);
  FontNameComboBox.Text := Settings.FontName;
  FontSizeSpinEdit.Value := Settings.FontSize;

  //Assembler
  AsmVerboseCheckBox.Checked := Settings.AsmVerbose;

  initialize := False;
end;

destructor TSettingsFrame.Destroy;
begin
  //save all settings
  Settings.Save;

  inherited Destroy;
end;

end.

