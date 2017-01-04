unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, OpenGLContext, SynEdit, SynHighlighterPas,
  Forms, Controls, Graphics,
  Dialogs, ComCtrls, ExtCtrls, Menus, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    PageControl1: TPageControl;
    PageControl2: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Splitter1: TSplitter;
    SynFreePascalSyn1: TSynFreePascalSyn;
    TabSheet1: TTabSheet;
    Timer1: TTimer;
    ProjectTreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
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
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    SetProjectFolder(SelectDirectoryDialog1.FileName);
end;

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
  //quit the main app
  Close;
end;

procedure TForm1.OpenGLControl1Click(Sender: TObject);
begin
end;

procedure TForm1.ProjectTreeViewDblClick(Sender: TObject);
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
      ShowMessage('Not yet supported');
    end;
    '.hex':
    begin
      ShowMessage('Not yet supported');
    end;
    '.pas', '.pp', '.p', '.inc':
    begin
      ts := PageControl1.AddTabSheet;
      ts.ImageIndex := 2;
      ts.Caption := ExtractFileName(sn.Text);

      se := TSynEdit.Create(ts);
      se.Parent := ts;
      se.Align := alClient;
      se.Highlighter := SynFreePascalSyn1;
      se.Lines.LoadFromFile(IncludeTrailingPathDelimiter(FProjectFolder) + sn.Text);
    end;
  end;
end;

procedure TForm1.SetProjectFolder(Folder: string);
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
  mainnode.ImageIndex := 4;
  mainnode.SelectedIndex := 4;

  AllFiles := FindAllFiles(FProjectFolder, '*.asm;*.hex;*.pas;*.pp;*.p;*.inc', False);
  try
    for i := 0 to AllFiles.Count - 1 do
    begin
      node := ProjectTreeView.Items.AddChild(mainnode, ExtractFileName(AllFiles[i]));
      ext := ExtractFileExt(AllFiles[i]);

      case ext of
        '.asm': node.ImageIndex := 0;
        '.hex': node.ImageIndex := 1;
        '.pas', '.pp', '.p', '.inc': node.ImageIndex := 2;
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
