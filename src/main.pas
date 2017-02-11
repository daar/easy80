unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynFacilHighlighter, Resource,
  Forms, Controls, ResourceStrings, SplashScreen,
  Dialogs, ComCtrls, ExtCtrls, Menus, StdCtrls, ActnList, khexeditor, SettingsFrame,
  //The pascal compiler
  Compiler,
  Configuration;

type
  TProjectFile = record
    Dirty: boolean;
    Editor: TComponent;
    FileName: string;
    FullFileName: string;
    TabSheet: TTabSheet;
    TreeNode: TTreeNode;
    hlt : TSynFacilSyn;
  end;
  pProjectFile = ^TProjectFile;

  { TMainForm }

  TMainForm = class(TForm)
    actDuplicate: TAction;
    actShowInExplorer: TAction;
    actDelete: TAction;
    actCopy: TAction;
    actCut: TAction;
    actPaste: TAction;
    actCopyFullPath: TAction;
    actCopyProjectPath: TAction;
    actOpenInNewWindow: TAction;
    actSearchInDirectory: TAction;
    actRename: TAction;
    actNewFolder: TAction;
    actNewFile: TAction;
    ActionList: TActionList;
    EditorsPageControl: TPageControl;
    EditorsPanel: TPanel;
    FeedbackPageControl: TPageControl;
    FeedbackPanel: TPanel;
    ImageList16: TImageList;
    MainMenu: TMainMenu;
    miProjNewFile: TMenuItem;
    miCut: TMenuItem;
    miPaste: TMenuItem;
    MenuItem12: TMenuItem;
    miAddProjectFolder: TMenuItem;
    miRemoveProjectFolder: TMenuItem;
    miCopyFullPath: TMenuItem;
    MenuItem16: TMenuItem;
    miCopyProjectPath: TMenuItem;
    miOpenInNewWindow: TMenuItem;
    miSearchInDirectory: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem3: TMenuItem;
    miProjNewFolder: TMenuItem;
    MenuItem5: TMenuItem;
    miCopy: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    miDuplicate: TMenuItem;
    MessagesMemo: TMemo;
    MessagesPopupMenu: TPopupMenu;
    MessagesTabSheet: TTabSheet;
    miAbout: TMenuItem;
    miAssemble: TMenuItem;
    miCloseAllOther: TMenuItem;
    miClosePage: TMenuItem;
    miCompile: TMenuItem;
    miDeleteFile: TMenuItem;
    miEdit: TMenuItem;
    miFile: TMenuItem;
    miFileSep1: TMenuItem;
    miFileSep2: TMenuItem;
    miHelp: TMenuItem;
    miMessagesMemoClearAll: TMenuItem;
    miMessagesMemoCopy: TMenuItem;
    miMessagesMemoSelectAll: TMenuItem;
    miMoveLeft: TMenuItem;
    miMoveRight: TMenuItem;
    miMoveRightMost: TMenuItem;
    miNew: TMenuItem;
    miNewFile: TMenuItem;
    miNewFolder: TMenuItem;
    miOpenProjectFolder: TMenuItem;
    miProject: TMenuItem;
    miQuit: TMenuItem;
    miSave: TMenuItem;
    miSaveAll: TMenuItem;
    miSaveAs: TMenuItem;
    miSaveAsTab: TMenuItem;
    miSaveTab: TMenuItem;
    miSettings: TMenuItem;
    miShowInExplorer: TMenuItem;
    miTools: TMenuItem;
    moMoveLeftMost: TMenuItem;
    ProjectPopupMenu: TPopupMenu;
    ProjectTreeView: TTreeView;
    SaveDialog: TSaveDialog;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    TabsPopupMenu: TPopupMenu;
    Timer: TTimer;

    procedure actCopyExecute(Sender: TObject);
    procedure actCopyFullPathExecute(Sender: TObject);
    procedure actCopyProjectPathExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDuplicateExecute(Sender: TObject);
    procedure actNewFileExecute(Sender: TObject);
    procedure actNewFolderExecute(Sender: TObject);
    procedure actOpenInNewWindowExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actRenameExecute(Sender: TObject);
    procedure actSearchInDirectoryExecute(Sender: TObject);
    procedure actShowInExplorerExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miAssembleClick(Sender: TObject);
    procedure miCloseAllOtherClick(Sender: TObject);
    procedure miClosePageClick(Sender: TObject);
    procedure miCompileClick(Sender: TObject);
    procedure miMessagesMemoClearAllClick(Sender: TObject);
    procedure miMessagesMemoCopyClick(Sender: TObject);
    procedure miMessagesMemoSelectAllClick(Sender: TObject);
    procedure miMoveLeftClick(Sender: TObject);
    procedure miMoveRightClick(Sender: TObject);
    procedure miMoveRightMostClick(Sender: TObject);
    procedure miOpenProjectFolderClick(Sender: TObject);
    procedure miQuitClick(Sender: TObject);
    procedure miSaveAllClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miSettingsClick(Sender: TObject);
    procedure moMoveLeftMostClick(Sender: TObject);
  private
    FProjectFolder: string;

    FProjectFiles: TFPList;

    { private declarations }
    procedure OnEditorChange(Sender: TObject);
    procedure SaveEditorFile(const idx: integer);
    procedure SetProjectFolder(Folder: string);

    //projectfile related functions
    function AddProjectFile(const path: string; var node: TTreeNode): pProjectFile;
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
  icons, AppSettings, ASMZ80, MessageIntf, Graphics, Process, Clipbrd;

procedure UIVerboseMsg(Level: VERBOSITY_LEVELS; aMessage: STRING);
begin
  IF Level IN Configuration.Verbose THEN
    Messages.Log(aMessage);
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Messages.RegisterView(MessagesMemo);
  VerboseMsg := @UIVerboseMsg;

  LoadFromResource(ImageList16);

  FProjectFiles := TFPList.Create;

  //new menu is disabled until a project is opened
  miNew.Enabled := False;

  if Settings.ReOpenAtStart then
    SetProjectFolder(Settings.LastProjectFolder);

  //show about in editor
  miAboutClick(nil);
end;

procedure TMainForm.actNewFileExecute(Sender: TObject);
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

procedure TMainForm.actDeleteExecute(Sender: TObject);
var
  tn: TTreeNode;
  pf: pProjectFile;
begin
  tn := ProjectTreeView.Selected;

  if tn = nil then
    exit;

  if MessageDlg(rsDeleteFile, rsAreYouSureToPermanen, mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    if not DeleteFile(IncludeTrailingPathDelimiter(FProjectFolder) + tn.Text) then
      Messages.LogFmt(rsCouldNotDeleteFileS, [SysErrorMessage(GetLastOSError)])
    else
    begin
      //close file in editor
      pf := pProjectFile(tn.Data);
      pf^.TabSheet.Free;

      //rebuild project tree view
      SetProjectFolder(FProjectFolder);
    end;
  end;
end;

procedure TMainForm.actDuplicateExecute(Sender: TObject);
var
  tn: TTreeNode;
  src, dest: string;
begin
  tn := ProjectTreeView.Selected;

  if tn <> nil then
  begin
    if tn.Parent <> nil then
    begin
      src := IncludeTrailingPathDelimiter(FProjectFolder) + tn.Text;

      dest := tn.Text;
      InputQuery(rsDestinationFilename, rsPleaseEnterTheDestin, dest);
      dest := IncludeTrailingPathDelimiter(FProjectFolder) + dest;

      if src = dest then
        exit;

      if not CopyFile(src, dest, True, False) then
      begin
        Messages.LogFmt(rsErrorCouldNotDulicat, [SysErrorMessage(GetLastOSError)]);
      end
      else
        SetProjectFolder(FProjectFolder);
    end;
  end;
end;

procedure TMainForm.actCopyExecute(Sender: TObject);
begin

end;

procedure TMainForm.actCopyFullPathExecute(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn := ProjectTreeView.Selected;

  if tn <> nil then
  begin
    if tn.Parent <> nil then
      Clipboard.AsText := IncludeTrailingPathDelimiter(FProjectFolder) + tn.Text;
  end;
end;

procedure TMainForm.actCopyProjectPathExecute(Sender: TObject);
var
  tn: TTreeNode;
begin
  tn := ProjectTreeView.Selected;

  if tn <> nil then
  begin
    if tn.Parent <> nil then
      Clipboard.AsText := IncludeTrailingPathDelimiter(FProjectFolder);
  end;
end;

procedure TMainForm.actCutExecute(Sender: TObject);
begin

end;

procedure TMainForm.actNewFolderExecute(Sender: TObject);
var
  path: string;
begin
  InputQuery(rsCreateNewFolder, rsEnterThePathForTheNe, path);

  if path <> '' then
  begin
    path := IncludeTrailingPathDelimiter(FProjectFolder) + path;
    if not ForceDirectories(path) then
      Messages.LogFmt(rsErrorCouldNotCreateD, [SysErrorMessage(GetLastOSError)])
    else
      SetProjectFolder(FProjectFolder);
  end;
end;

procedure TMainForm.actOpenInNewWindowExecute(Sender: TObject);
var
  tn: TTreeNode;
  ext: string;
  pf: pProjectFile;
  idx: integer;

  procedure CreateSynEditHighlighter;
  begin
    TSynEdit(pf^.Editor) := TSynEdit.Create(pf^.TabSheet);
    TSynEdit(pf^.Editor).Parent := pf^.TabSheet;
    TSynEdit(pf^.Editor).Align := alClient;
    TSynEdit(pf^.Editor).Lines.LoadFromFile(pf^.FullFileName);
    TSynEdit(pf^.Editor).OnChange := @OnEditorChange;
  end;

begin
  tn := ProjectTreeView.Selected;

  if tn = nil then
    exit;
  if tn.Parent = nil then
    exit;

  //check if projectfile already is opened in the editor
  idx := ProjectFileTabIndex(tn.Text);
  if idx <> -1 then
  begin
    EditorsPageControl.PageIndex := idx;
    exit;
  end;

  ext := LowerCase(ExtractFileExt(tn.Text));

  pf := AddProjectFile(FProjectFolder, tn);

  case ext of
    '.asm':
    begin
      pf^.TabSheet.ImageIndex := ICON_ASM_SOURCE;

      //create the editor
      CreateSynEditHighlighter;

      //highlighter
      pf^.hlt := TSynFacilSyn.Create(self);
      TSynEdit(pf^.Editor).Highlighter := pf^.hlt;
      pf^.hlt.LoadFromResourceName(HInstance, 'HL_Z80ASM');

      UpdateSynEdit(TSynEdit(pf^.Editor));
    end;
    '.obj':
    begin
      pf^.TabSheet.ImageIndex := ICON_OBJ_SOURCE;

      //create the editor
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
      pf^.TabSheet.ImageIndex := ICON_PAS_SOURCE;

      //create the editor
      CreateSynEditHighlighter;

      //highlighter
      pf^.hlt := TSynFacilSyn.Create(self);
      TSynEdit(pf^.Editor).Highlighter := pf^.hlt;
      pf^.hlt.LoadFromResourceName(HInstance, 'HL_PASCAL');

      UpdateSynEdit(TSynEdit(pf^.Editor));
    end;
  else
    begin
      //for all other files open the SynEdit editor without highlighter

      pf^.TabSheet.ImageIndex := ICON_FILE;

      //create the editor
      CreateSynEditHighlighter;

      UpdateSynEdit(TSynEdit(pf^.Editor));
    end;
  end;
end;

procedure TMainForm.actPasteExecute(Sender: TObject);
begin

end;

procedure TMainForm.actRenameExecute(Sender: TObject);
var
  tn: TTreeNode;
  src, dest: string;
begin
  tn := ProjectTreeView.Selected;

  if tn <> nil then
  begin
    if tn.Parent <> nil then
    begin
      src := IncludeTrailingPathDelimiter(FProjectFolder) + tn.Text;

      dest := tn.Text;
      InputQuery(rsNewFilename, rsPleaseEnterTheNewFil, dest);
      dest := IncludeTrailingPathDelimiter(FProjectFolder) + dest;

      if src = dest then
        exit;

      if not RenameFile(src, dest) then
      begin
        Messages.LogFmt(rsErrorCouldNotRenameF, [SysErrorMessage(GetLastOSError)]);
      end
      else
        SetProjectFolder(FProjectFolder);
    end;
  end;
end;

procedure TMainForm.actSearchInDirectoryExecute(Sender: TObject);
begin

end;

procedure TMainForm.actShowInExplorerExecute(Sender: TObject);
var
  tn: TTreeNode;
  s: string;
  exec: string;
  arg: string;
begin
  tn := ProjectTreeView.Selected;

  if tn <> nil then
  begin
    {$IFDEF MSWINDOWS}
    exec := 'explorer';

    if tn.Parent = nil then
      arg := FProjectFolder
    else
      arg := Format('/select,%s%s', [IncludeTrailingPathDelimiter(FProjectFolder), tn.Text]);
    {$ENDIF}
    {$IFDEF LINUX}
    exec := 'gnome-open';

    if tn.Parent = nil then
      arg := FProjectFolder
    else
      arg := Format('%s%s', [IncludeTrailingPathDelimiter(FProjectFolder), tn.Text]);
    {$ENDIF}
    {$IFDEF DARWIN}
    exec := 'open';

    if tn.Parent = nil then
      arg := FProjectFolder
    else
      arg := Format('%s%s', [IncludeTrailingPathDelimiter(FProjectFolder), tn.Text]);
    {$ENDIF}

    RunCommand(exec, [arg], s);
  end;
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

procedure TMainForm.miMessagesMemoClearAllClick(Sender: TObject);
begin
  MessagesMemo.Lines.Clear;
end;

procedure TMainForm.miMessagesMemoCopyClick(Sender: TObject);
begin
  MessagesMemo.CopyToClipboard;
end;

procedure TMainForm.miMessagesMemoSelectAllClick(Sender: TObject);
begin
  MessagesMemo.SelectAll;
end;

procedure TMainForm.miCompileClick(Sender: TObject);
var
  PascalCompiler: TCompiler;
  ts: TTabSheet;
  pf: pProjectFile;
  time: double;
begin
  ts := EditorsPageControl.ActivePage;

  //exit if no tabsheet is selected
  if ts = nil then
    exit;

  pf := pProjectFile(ts.Tag);

  //exit if file is not pascal sourcefile
  if LowerCase(ExtractFileExt(pf^.FileName)) <> '.pas' then
    exit;

  //save all editor files
  miSaveAllClick(nil);

  try
    time := Now;

    Messages.Log('Z80 Pascal compiler (WIP version)');
    Messages.Log('(c) 2009, 2010 by Guillermo Martínez');
    Messages.Log('');

    Configuration.InputFileName := pf^.FullFileName;
    Configuration.OutputFileName := ChangeFileExt(pf^.FullFileName, '.asm');;
    Configuration.ListsComments := FALSE;
    Configuration.Verbose := [vblErrors, vblWarnings];

    PascalCompiler := TCompiler.Create;
    PascalCompiler.FileName := Configuration.InputFileName;
    PascalCompiler.Compile;
    Messages.Log('Compilation finished.');
    PascalCompiler.SaveToFile (Configuration.OutputFileName);
    Messages.LogFmt('File saved at ''%s''.', [Configuration.OutputFileName]);

    if vblWarnings in Configuration.Verbose then
    begin
       Messages.Log('');
       Messages.LogFmt('%d lines compiled, %.1f sec, %d bytes code', [TSynEdit(pf^.Editor).Lines.Count, (Now - time) * 24 * 3600, Length(TSynEdit(pf^.Editor).Lines.Text)]);
       //Messages.LogFmt('%d warning(s) issued', [warnCount]);
       //Messages.LogFmt('%d note(s) issued', [noteCount]);
       //Messages.LogFmt('%d error(s) issued', [errCount]);
       Messages.Log('');
    end;
  except
    on Error: Exception do
      Messages.Log(Error.Message);
  end;
  Configuration.Unload;

  //update projectfolder
  SetProjectFolder(FProjectFolder);
end;

procedure TMainForm.miAssembleClick(Sender: TObject);
var
  ts: TTabSheet;
  pf: pProjectFile;
  lis: string;
  obj: RawByteString;
begin
  ts := EditorsPageControl.ActivePage;

  //exit if no tabsheet is selected
  if ts = nil then
    exit;

  pf := pProjectFile(ts.Tag);

  //exit if file is not ASM
  if LowerCase(ExtractFileExt(pf^.FileName)) <> '.asm' then
    exit;

  miSaveAllClick(nil);

  lis := ChangeFileExt(pf^.FullFileName, '.lis');
  obj := ChangeFileExt(pf^.FullFileName, '.obj');
  ASMZ80_execute(pf^.FullFileName, lis, obj, Settings.AsmVerbose);

  //update projectfolder
  SetProjectFolder(FProjectFolder);
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
  pf^.TabSheet.Caption := '*' + pf^.FileName;
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
var
  pf: pProjectFile;
  idx: integer;
  node: TTreeNode = nil;
begin
  //check if settings already is opened in the editor
  idx := ProjectFileTabIndex(rsAbout);
  if idx <> -1 then
  begin
    EditorsPageControl.PageIndex := idx;
    exit;
  end;

  pf := AddProjectFile(FProjectFolder, node);

  pf^.TabSheet.ImageIndex := ICON_INFO;
  pf^.TabSheet.Caption := rsAbout;

  pf^.Editor := TSplash.Create(pf^.TabSheet);
  TSplash(pf^.Editor).Parent := pf^.TabSheet;
  TSplash(pf^.Editor).Align := alClient;
end;

procedure TMainForm.miSettingsClick(Sender: TObject);
var
  pf: pProjectFile;
  idx: integer;
  node: TTreeNode = nil;
begin
  //check if settings already is opened in the editor
  idx := ProjectFileTabIndex(rsSettings);
  if idx <> -1 then
  begin
    EditorsPageControl.PageIndex := idx;
    exit;
  end;

  pf := AddProjectFile(FProjectFolder, node);

  pf^.TabSheet.ImageIndex := ICON_SETTINGS;
  pf^.TabSheet.Caption := rsSettings;

  pf^.Editor := TSettingsFrame.Create(pf^.TabSheet);
  TSettingsFrame(pf^.Editor).Parent := pf^.TabSheet;
  TSettingsFrame(pf^.Editor).Align := alClient;
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
        Messages.LogFmt(rsCannotDeleteFileS, [SysErrorMessage(GetLastOSError)]);
    end;
  end;
end;

procedure TMainForm.SetProjectFolder(Folder: string);
var
  AllFiles: TStringList;
  mainnode: TTreeNode;
  node: TTreeNode;
  i: integer;
  ext: string;
begin
  //if folder does not exist then exit
  if not DirectoryExists(Folder) then
    exit;

  //if new folder selected
  if Folder <> FProjectFolder then
  begin
    //save the last opened projectfolder to the settings file
    Settings.LastProjectFolder := Folder;
    Settings.Save;

    //clear the open projectfile list
    while FProjectFiles.Count > 0 do
      CloseProjectFile(0);
  end;

  FProjectFolder := Folder;

  //enable new menu, when a project is opened
  miNew.Enabled := True;

  //now search all files in the project folder
  ProjectTreeView.Items.Clear;
  mainnode := ProjectTreeView.Items.Add(nil, ExtractFileName(FProjectFolder));
  mainnode.ImageIndex := ICON_EASY80;
  mainnode.SelectedIndex := mainnode.ImageIndex;

  AllFiles := FindAllFiles(FProjectFolder, '*', False);
  try
    for i := 0 to AllFiles.Count - 1 do
    begin
      node := ProjectTreeView.Items.AddChild(mainnode, ExtractFileName(AllFiles[i]));
      ext := LowerCase(ExtractFileExt(AllFiles[i]));

      case ext of
        '.asm': node.ImageIndex := ICON_ASM_SOURCE;
        '.obj': node.ImageIndex := ICON_OBJ_SOURCE;
        '.pas', '.pp', '.p', '.inc': node.ImageIndex := ICON_PAS_SOURCE;
      else
        node.ImageIndex := ICON_FILE;
      end;

      node.SelectedIndex := node.ImageIndex;
    end;

    //expand all items in project
    mainnode.Expand(True);

    //sort the items
    ProjectTreeView.SortType := stText;
    ProjectTreeView.AlphaSort;
  finally
    AllFiles.Free;
  end;
end;

function TMainForm.AddProjectFile(const path: string; var node: TTreeNode): pProjectFile;
var
  pf: pProjectFile;
begin
  New(pf);
  FProjectFiles.Add(pf);

  if node <> nil then
  begin
    pf^.FullFileName := IncludeTrailingPathDelimiter(path) + node.Text;

    //link the projectfile to the treenode
    node.Data := pf;
  end
  else
    pf^.FullFileName := '';

  pf^.FileName := ExtractFileName(pf^.FullFileName);
  pf^.Dirty := False;
  pf^.TreeNode := node;

  pf^.TabSheet := EditorsPageControl.AddTabSheet;
  pf^.TabSheet.Caption := pf^.FileName;

  //link the tabsheet to the projectfile record
  pf^.TabSheet.Tag := PtrInt(pf);
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
    edt := StringReplace(EditorsPageControl.Pages[i].Caption, '*', '', [rfReplaceAll]);

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
