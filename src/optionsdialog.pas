unit OptionsDialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TreeFilterEdit, Forms, Controls, Graphics,
  Dialogs, ButtonPanel, ExtCtrls, ComCtrls, StdCtrls, IDELocale, ResourceStrings,
  XMLConf;

type

  { TOptionsDlg }

  TOptionsDlg = class(TForm)
    ButtonPanel1: TButtonPanel;
    LocaleComboBox: TComboBox;
    LocaleLabel: TLabel;
    OptionsPageControl: TPageControl;
    Panel1: TPanel;
    Splitter1: TSplitter;
    EditorTabSheet: TTabSheet;
    CompilerTabSheet: TTabSheet;
    AssemblerTabSheet: TTabSheet;
    GeneralTabSheet: TTabSheet;
    OptionsTreeFilterEdit: TTreeFilterEdit;
    OptionsTreeView: TTreeView;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure OptionsTreeViewClick(Sender: TObject);
  private

  public
    xml: TXMLConfig;
  end;

var
  OptionsDlg: TOptionsDlg;

implementation

{$R *.lfm}

uses
  LCLTranslator;

{ TOptionsDlg }

procedure TOptionsDlg.OptionsTreeViewClick(Sender: TObject);
var
  node: TTreeNode;
begin
  node := OptionsTreeView.Selected;
  if node <> nil then
    OptionsPageControl.ActivePageIndex := node.Index;
end;

procedure TOptionsDlg.FormCreate(Sender: TObject);
begin
  xml := TXMLConfig.Create(nil);
  xml.Filename := 'easy80-ide.xml';

  OptionsPageControl.ShowTabs := False;

  OptionsTreeView.Items[0].Selected:= True;
  OptionsPageControl.ActivePageIndex := 0;

  LoadTranslations(LocaleComboBox);
  LocaleComboBox.Text := xml.GetValue('/language', rsSystemLanguage);
end;

procedure TOptionsDlg.FormDestroy(Sender: TObject);
begin
  xml.Free;
end;

procedure TOptionsDlg.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TOptionsDlg.OKButtonClick(Sender: TObject);
begin
  //save all settings
  xml.SetValue('/language', LocaleComboBox.Text);

  xml.Flush;
end;

end.
