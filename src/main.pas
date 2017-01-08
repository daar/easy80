unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, OpenGLContext, SynEdit, SynHighlighterPas,
  Forms, Controls, Graphics, ResourceStrings, SplashScreen,
  Dialogs, ComCtrls, ExtCtrls, Menus, StdCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    ImageList16: TImageList;
    MainMenu: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    AboutMenuItem: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    ProjectPopupMenu: TPopupMenu;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    SynFreePascalSyn: TSynFreePascalSyn;
    TabSheet1: TTabSheet;
    Timer: TTimer;
    ProjectTreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure AboutMenuItemClick(Sender: TObject);
    procedure OpenGLControl1Click(Sender: TObject);
    procedure ProjectTreeViewDblClick(Sender: TObject);
  private
    FProjectFolder: string;
    { private declarations }
    procedure SetProjectFolder(Folder: string);
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  icons;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := rsEasy80IDE;

  AboutMenuItemClick(Sender);
  LoadFromResource(ImageList16);
end;

procedure TMainForm.MenuItem2Click(Sender: TObject);
begin
  if SelectDirectoryDialog.Execute then
    SetProjectFolder(SelectDirectoryDialog.FileName);
end;

procedure TMainForm.MenuItem3Click(Sender: TObject);
begin
  //quit the main app
  Close;
end;

procedure TMainForm.AboutMenuItemClick(Sender: TObject);
begin
  Splash := TSplash.Create(Application);
  Splash.ShowModal;

  Splash.Close;
  Splash.Release;
end;

procedure TMainForm.OpenGLControl1Click(Sender: TObject);
begin
end;

procedure TMainForm.ProjectTreeViewDblClick(Sender: TObject);
var
  sn: TTreeNode;
  ts: TTabSheet;
  ext: RawByteString;
  se: TSynEdit;
begin
  sn := ProjectTreeView.Selected;

  if sn = nil then
    exit;

  ext := ExtractFileExt(sn.Text);

  case ext of
    '.asm':
    begin
      ShowMessage(rsNotYetSupported);
    end;
    '.hex':
    begin
      ShowMessage(rsNotYetSupported);
    end;
    '.pas', '.pp', '.p', '.inc':
    begin
      ts := PageControl1.AddTabSheet;
      ts.ImageIndex := ICON_PAS_SOURCE;
      ts.Caption := ExtractFileName(sn.Text);

      se := TSynEdit.Create(ts);
      se.Parent := ts;
      se.Align := alClient;
      se.Highlighter := SynFreePascalSyn;
      se.Lines.LoadFromFile(IncludeTrailingPathDelimiter(FProjectFolder) + sn.Text);
    end;
  end;
end;

procedure TMainForm.SetProjectFolder(Folder: string);
var
  AllFiles: TStringList;
  mainnode: TTreeNode;
  node: TTreeNode;
  i: Integer;
  ext: RawByteString;
begin
  FProjectFolder := Folder;

  //now search all files in the project folder
  ProjectTreeView.Items.Clear;
  mainnode := ProjectTreeView.Items.Add(nil, ExtractFileName(FProjectFolder));
  mainnode.ImageIndex := ICON_EASY80;
  mainnode.SelectedIndex := mainnode.ImageIndex;

  AllFiles := FindAllFiles(FProjectFolder, '*.asm;*.hex;*.pas;*.pp;*.p;*.inc', False);
  try
    for i := 0 to AllFiles.Count - 1 do
    begin
      node := ProjectTreeView.Items.AddChild(mainnode, ExtractFileName(AllFiles[i]));
      ext := ExtractFileExt(AllFiles[i]);

      case ext of
        '.asm': node.ImageIndex := ICON_ASM_SOURCE;
        '.hex': node.ImageIndex := ICON_HEX_SOURCE;
        '.pas', '.pp', '.p', '.inc': node.ImageIndex := ICON_PAS_SOURCE;
      end;

      node.SelectedIndex := node.ImageIndex;
    end;

    //expand all items in project
    mainnode.Expand(True);
  finally
    AllFiles.Free;
  end;
end;

end.
