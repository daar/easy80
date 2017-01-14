unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, OpenGLContext, SynEdit, SynHighlighterPas,
  Forms, Controls, Graphics, ResourceStrings, SplashScreen, OptionsDialog,
  Dialogs, ComCtrls, ExtCtrls, Menus, StdCtrls, ATBinHex;

type
  TProjectFile = record
    Dirty: boolean;
    Editor: TComponent;
    FileName: string;
    FullFileName: string;
    TabSheet: TTabSheet;
    TreeNode: TTreeNode;
  end;
  pProjectFile = ^TProjectFile;

  { TMainForm }

  TMainForm = class(TForm)
    ImageList16: TImageList;
    MainMenu: TMainMenu;
    MessagesMemo: TMemo;
    miFile: TMenuItem;
    miEdit: TMenuItem;
    miSaveAll: TMenuItem;
    miFileSep2: TMenuItem;
    miOpenProjectFolder: TMenuItem;
    miQuit: TMenuItem;
    miFileSep1: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    miTools: TMenuItem;
    miOptions: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    EditorsPageControl: TPageControl;
    FeedbackPageControl: TPageControl;
    EditorsPanel: TPanel;
    FeedbackPanel: TPanel;
    ProjectPopupMenu: TPopupMenu;
    SaveDialog: TSaveDialog;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    SynFreePascalSyn: TSynFreePascalSyn;
    MessagesTabSheet: TTabSheet;
    Timer: TTimer;
    ProjectTreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure miSaveAllClick(Sender: TObject);
    procedure miOpenProjectFolderClick(Sender: TObject);
    procedure miQuitClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miOptionsClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure ProjectTreeViewDblClick(Sender: TObject);
  private
    FProjectFolder: string;

    FProjectFiles: array of TProjectFile;
    FProjectFilesCount: integer;

    { private declarations }
    procedure OnEditorChange(Sender: TObject);
    procedure Open(hx: TATBinHex; const Filename: string);
    procedure SaveEditorFile(const idx: integer);
    procedure SetProjectFolder(Folder: string);

    function AddProjectFile(const path: string; node: TTreeNode): pProjectFile;
  public
    { public declarations }
    fs: TFileStream;
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

  LoadFromResource(ImageList16);

  FProjectFilesCount := 0;
end;

procedure TMainForm.miSaveAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FProjectFilesCount - 1 do
    SaveEditorFile(i);
end;

procedure TMainForm.Open(hx: TATBinHex; const Filename: string);
begin
  if Assigned(fs) then
  begin
    hx.OpenStream(nil);
    FreeAndNil(fs);
  end;

  fs := TFileStream.Create(Filename, fmOpenRead);
  hx.OpenStream(fs);
  hx.Redraw;
end;

procedure TMainForm.SaveEditorFile(const idx: integer);
var
  pf: pProjectFile;
begin
  pf := @FProjectFiles[idx];

  if pf^.Dirty then
  begin
    if pf^.Editor.ClassType = TSynEdit then
      TSynEdit(pf^.Editor).Lines.SaveToFile(pf^.FullFileName);

    pf^.TabSheet.Caption := pf^.FileName;
  end;
end;

procedure TMainForm.OnEditorChange(Sender: TObject);
var
  pf: pProjectFile;
  idx: integer;
begin
  idx := EditorsPageControl.TabIndex;

  pf := @FProjectFiles[idx];
  pf^.TabSheet.Caption := '* ' + pf^.FileName;
  pf^.Dirty := True;
end;

procedure TMainForm.miOpenProjectFolderClick(Sender: TObject);
begin
  if SelectDirectoryDialog.Execute then
    SetProjectFolder(SelectDirectoryDialog.FileName);
end;

procedure TMainForm.miQuitClick(Sender: TObject);
begin
  //quit the main app
  Close;
end;

procedure TMainForm.miAboutClick(Sender: TObject);
begin
  Splash := TSplash.Create(Application);
  Splash.ShowModal;

  Splash.Close;
  Splash.Release;
end;

procedure TMainForm.miOptionsClick(Sender: TObject);
begin
  OptionsDlg.ShowModal;
end;

procedure TMainForm.miSaveClick(Sender: TObject);
var
  idx: integer;
begin
  idx := EditorsPageControl.TabIndex;

  SaveEditorFile(idx);
end;

procedure TMainForm.miSaveAsClick(Sender: TObject);
var
  pf: pProjectFile;
  idx: integer;
  Msg, OldFileName: string;
begin
  idx := EditorsPageControl.TabIndex;
  pf := @FProjectFiles[idx];

  if SaveDialog.Execute then
  begin
    OldFileName := pf^.FullFileName;

    pf^.Dirty := True;
    pf^.FullFileName := SaveDialog.FileName;
    pf^.FileName := ExtractFileName(SaveDialog.FileName);
    pf^.TreeNode.Text := pf^.FileName;
    SaveEditorFile(EditorsPageControl.TabIndex);

    Msg := Format('Delete old file "%s"?', [ExtractFileName(OldFileName)]);
    if MessageDlg('Delete old file?', Msg, mtConfirmation , mbYesNo, '') = mrYes then
    begin
      if not DeleteFile(UTF8ToAnsi(OldFileName)) then
      begin
        Msg := Format('Cannot delete file: %s.', [SysErrorMessage(GetLastOSError)]);
        MessageDlg('Error deleting file', Msg, mtError , [mbOK], '');
      end;
    end;
  end;
end;

procedure TMainForm.ProjectTreeViewDblClick(Sender: TObject);
var
  sn: TTreeNode;
  ext: RawByteString;
  pf: pProjectFile;
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
      pf := AddProjectFile(FProjectFolder, sn);

      pf^.TabSheet := EditorsPageControl.AddTabSheet;
      pf^.TabSheet.ImageIndex := ICON_HEX_SOURCE;
      pf^.TabSheet.Caption := pf^.FileName + ' [readonly]';
      EditorsPageControl.ActivePage := pf^.TabSheet;

      pf^.Editor := TATBinHex.Create(pf^.TabSheet);
      TATBinHex(pf^.Editor).Parent := pf^.TabSheet;
      TATBinHex(pf^.Editor).Align := alClient;
      TATBinHex(pf^.Editor).TextGutter:= true;
      TATBinHex(pf^.Editor).TextGutterLinesStep:= 10;
      TATBinHex(pf^.Editor).Mode:= vbmodeHex;

      Open(TATBinHex(pf^.Editor), pf^.FullFileName);
    end;
    '.pas', '.pp', '.p', '.inc':
    begin
      pf := AddProjectFile(FProjectFolder, sn);

      pf^.TabSheet := EditorsPageControl.AddTabSheet;
      pf^.TabSheet.ImageIndex := ICON_PAS_SOURCE;
      pf^.TabSheet.Caption := pf^.FileName;
      EditorsPageControl.ActivePage := pf^.TabSheet;

      TSynEdit(pf^.Editor) := TSynEdit.Create(pf^.TabSheet);
      TSynEdit(pf^.Editor).Parent := pf^.TabSheet;
      TSynEdit(pf^.Editor).Align := alClient;
      TSynEdit(pf^.Editor).Highlighter := SynFreePascalSyn;
      TSynEdit(pf^.Editor).OnChange:=@OnEditorChange;
      TSynEdit(pf^.Editor).Lines.LoadFromFile(pf^.FullFileName);
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

function TMainForm.AddProjectFile(const path: string; node: TTreeNode): pProjectFile;
var
  pf: pProjectFile;
begin
  inc(FProjectFilesCount);
  SetLength(FProjectFiles, FProjectFilesCount);

  pf := @FProjectFiles[FProjectFilesCount - 1];

  pf^.FullFileName := IncludeTrailingPathDelimiter(path) + node.Text;
  pf^.FileName := ExtractFileName(pf^.FullFileName);
  pf^.Dirty := False;
  pf^.TreeNode := node;

  Result := pf;
end;

end.
