unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, OpenGLContext, SynEdit, SynHighlighterPas,
  Forms, Controls, Graphics, ResourceStrings, SplashScreen, OptionsDialog,
  Dialogs, ComCtrls, ExtCtrls, Menus, StdCtrls, khexeditor;

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
    miNew: TMenuItem;
    MenuItem2: TMenuItem;
    miNewFile: TMenuItem;
    miNewProjectFolder: TMenuItem;
    miClosePage: TMenuItem;
    miMoveRightMost: TMenuItem;
    miCloseAllOther: TMenuItem;
    MenuItem3: TMenuItem;
    miSaveTab: TMenuItem;
    MenuItem5: TMenuItem;
    miSaveAsTab: TMenuItem;
    miMoveLeft: TMenuItem;
    miMoveRight: TMenuItem;
    moMoveLeftMost: TMenuItem;
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
    TabsPopupMenu: TPopupMenu;
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
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miNewFileClick(Sender: TObject);
    procedure miNewProjectFolderClick(Sender: TObject);
    procedure miMoveRightMostClick(Sender: TObject);
    procedure miClosePageClick(Sender: TObject);
    procedure miCloseAllOtherClick(Sender: TObject);
    procedure miMoveLeftClick(Sender: TObject);
    procedure miMoveRightClick(Sender: TObject);
    procedure moMoveLeftMostClick(Sender: TObject);
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

    FProjectFiles: TFPList;

    { private declarations }
    procedure OnEditorChange(Sender: TObject);
    procedure SaveEditorFile(const idx: integer);
    procedure SetProjectFolder(Folder: string);

    //projectfile related functions
    function AddProjectFile(const path: string; node: TTreeNode): pProjectFile;
    function ProjectFileTabIndex(const FileName: string): integer;
  public
    { public declarations }
    procedure EnvironmentChanged;
    procedure CloseProjectFile(index: integer);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  icons, AppSettings;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LoadFromResource(ImageList16);

  FProjectFiles := TFPList.Create;

  //new menu is disabled until a project is opened
  miNew.Enabled := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  while FProjectFiles.Count > 0 do
    CloseProjectFile(0);

  FProjectFiles.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Caption := Format(rsEasy80IDEVS, [{$i version.inc}]);
end;

procedure TMainForm.miNewFileClick(Sender: TObject);
var
  sl: TStrings;
begin
  if SaveDialog.Execute then
  begin
    sl := TStringList.Create;
    sl.SaveToFile(SaveDialog.FileName);
    SetProjectFolder(FProjectFolder);
    sl.Free;
  end;
end;

procedure TMainForm.miNewProjectFolderClick(Sender: TObject);
begin
  if SelectDirectoryDialog.Execute then
    SetProjectFolder(SelectDirectoryDialog.FileName);
end;

procedure TMainForm.miMoveRightMostClick(Sender: TObject);
begin
  EditorsPageControl.ActivePage.PageIndex := EditorsPageControl.PageCount - 1;
end;

procedure TMainForm.miClosePageClick(Sender: TObject);
begin
  CloseProjectFile(EditorsPageControl.PageIndex);
end;

procedure TMainForm.miCloseAllOtherClick(Sender: TObject);
var
  i: integer;
begin
  for i := EditorsPageControl.PageCount -1 downto 0 do
  begin
    if i <> EditorsPageControl.PageIndex then
      CloseProjectFile(i);
  end;
end;

procedure TMainForm.miMoveLeftClick(Sender: TObject);
var
  idx: integer;
begin
  idx := EditorsPageControl.PageIndex;

  if idx <> 0 then
    EditorsPageControl.ActivePage.PageIndex := idx - 1;
end;

procedure TMainForm.miMoveRightClick(Sender: TObject);
var
  idx: integer;
begin
  idx := EditorsPageControl.PageIndex;

  if idx <> EditorsPageControl.PageCount then
    EditorsPageControl.ActivePage.PageIndex := idx + 1;
end;

procedure TMainForm.moMoveLeftMostClick(Sender: TObject);
begin
  EditorsPageControl.ActivePage.PageIndex := 0;
end;

procedure TMainForm.miSaveAllClick(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to FProjectFiles.Count - 1 do
    SaveEditorFile(i);
end;

procedure TMainForm.SaveEditorFile(const idx: integer);
var
  pf: pProjectFile;
begin
  pf := FProjectFiles[idx];

  if pf^.Dirty then
  begin
    if pf^.Editor.ClassType = TSynEdit then
      TSynEdit(pf^.Editor).Lines.SaveToFile(pf^.FullFileName);

    if pf^.Editor.ClassType = TKHexEditor then
      TKHexEditor(pf^.Editor).SaveToFile(pf^.FullFileName);

    pf^.TabSheet.Caption := pf^.FileName;
  end;
end;

procedure TMainForm.OnEditorChange(Sender: TObject);
var
  pf: pProjectFile;
  idx: integer;
begin
  idx := EditorsPageControl.TabIndex;

  pf := FProjectFiles[idx];
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
  if OptionsDlg.ShowModal = mrOK then
    EnvironmentChanged;
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
  pf := FProjectFiles[idx];

  if SaveDialog.Execute then
  begin
    OldFileName := pf^.FullFileName;

    pf^.Dirty := True;
    pf^.FullFileName := SaveDialog.FileName;
    pf^.FileName := ExtractFileName(SaveDialog.FileName);
    pf^.TreeNode.Text := pf^.FileName;
    SaveEditorFile(EditorsPageControl.TabIndex);

    Msg := Format(rsDeleteOldFileS, [ExtractFileName(OldFileName)]);
    if MessageDlg(rsDeleteOldFile, Msg, mtConfirmation , mbYesNo, '') = mrYes then
    begin
      if not DeleteFile(UTF8ToAnsi(OldFileName)) then
      begin
        Msg := Format(rsCannotDeleteFileS, [SysErrorMessage(GetLastOSError)]);
        MessageDlg(rsErrorDeletingFile, Msg, mtError , [mbOK], '');
      end;
    end;
  end;
end;

procedure TMainForm.ProjectTreeViewDblClick(Sender: TObject);
var
  sn: TTreeNode;
  ext: string;
  pf: pProjectFile;
  idx: integer;
begin
  sn := ProjectTreeView.Selected;

  if sn = nil then
    exit;

  //check if projectfile already is opened in the editor
  idx := ProjectFileTabIndex(sn.Text);
  if idx <> -1 then
  begin
    EditorsPageControl.PageIndex := idx;
    exit;
  end;

  ext := LowerCase(ExtractFileExt(sn.Text));

  case ext of
    '.asm':
    begin
      pf := AddProjectFile(FProjectFolder, sn);

      pf^.TabSheet.ImageIndex := ICON_ASM_SOURCE;
      pf^.TabSheet.Caption := pf^.FileName;

      TSynEdit(pf^.Editor) := TSynEdit.Create(pf^.TabSheet);
      TSynEdit(pf^.Editor).Parent := pf^.TabSheet;
      TSynEdit(pf^.Editor).Align := alClient;
      TSynEdit(pf^.Editor).Highlighter := SynFreePascalSyn;
      TSynEdit(pf^.Editor).Lines.LoadFromFile(pf^.FullFileName);
      TSynEdit(pf^.Editor).OnChange := @OnEditorChange;

      UpdateSynEdit(TSynEdit(pf^.Editor));
    end;
    '.hex':
    begin
      pf := AddProjectFile(FProjectFolder, sn);

      pf^.TabSheet.ImageIndex := ICON_HEX_SOURCE;
      pf^.TabSheet.Caption := pf^.FileName;

      pf^.Editor := TKHexEditor.Create(pf^.TabSheet);
      TKHexEditor(pf^.Editor).Parent := pf^.TabSheet;
      TKHexEditor(pf^.Editor).Align := alClient;
      TKHexEditor(pf^.Editor).Font.Style := [];
      TKHexEditor(pf^.Editor).LoadFromFile(pf^.FullFileName);
      TKHexEditor(pf^.Editor).OnChange := @OnEditorChange;

      UpdateHexEditor(TKHexEditor(pf^.Editor));
    end;
    '.pas', '.pp', '.p', '.inc':
    begin
      pf := AddProjectFile(FProjectFolder, sn);

      pf^.TabSheet.ImageIndex := ICON_PAS_SOURCE;
      pf^.TabSheet.Caption := pf^.FileName;

      TSynEdit(pf^.Editor) := TSynEdit.Create(pf^.TabSheet);
      TSynEdit(pf^.Editor).Parent := pf^.TabSheet;
      TSynEdit(pf^.Editor).Align := alClient;
      TSynEdit(pf^.Editor).Highlighter := SynFreePascalSyn;
      TSynEdit(pf^.Editor).Lines.LoadFromFile(pf^.FullFileName);
      TSynEdit(pf^.Editor).OnChange := @OnEditorChange;

      UpdateSynEdit(TSynEdit(pf^.Editor));
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

  //enable new menu, when a project is opened
  miNew.Enabled := True;

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
      ext := LowerCase(ExtractFileExt(AllFiles[i]));

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
  New(pf);
  FProjectFiles.Add(pf);

  pf^.FullFileName := IncludeTrailingPathDelimiter(path) + node.Text;
  pf^.FileName := ExtractFileName(pf^.FullFileName);
  pf^.Dirty := False;
  pf^.TreeNode := node;

  pf^.TabSheet := EditorsPageControl.AddTabSheet;
  //pf^.TabSheet.PopupMenu := TabsPopupMenu;
  EditorsPageControl.ActivePage := pf^.TabSheet;

  Result := pf;
end;

function TMainForm.ProjectFileTabIndex(const FileName: string): integer;
var
  fname: string;
  i: integer;
  edt : string;
begin
  fname := ExtractFileName(FileName);

  for i := 0 to EditorsPageControl.PageCount - 1 do
  begin
    //ignore the 'dirty' file indicator
    edt := StringReplace(EditorsPageControl.Pages[i].Caption, '* ', '', [rfReplaceAll]);

    if edt = fname then
    begin
      Result := i;
      exit;
    end;
  end;
  Result := -1;
end;

procedure TMainForm.EnvironmentChanged;
var
  i: integer;
  pf: pProjectFile;
begin
  //update all editor settings
  for i := 0 to FProjectFiles.Count - 1 do
  begin
    pf := FProjectFiles[i];

    if pf^.Editor.ClassType = TSynEdit then
      UpdateSynEdit(TSynEdit(pf^.Editor));

    if pf^.Editor.ClassType = TKHexEditor then
      UpdateHexEditor(TKHexEditor(pf^.Editor));
  end;
end;

procedure TMainForm.CloseProjectFile(index: integer);
var
  pf: pProjectFile;
begin
  //get the projectfile object from the list
  pf := FProjectFiles[index];

  //free and delete the projectfile object
  Dispose(pf);
  FProjectFiles.Delete(index);

  //close the tab
  EditorsPageControl.Pages[index].Free;
end;

end.
