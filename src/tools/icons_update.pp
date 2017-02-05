program icons_update;

uses
  Process,
  FileUtil,
  Classes,
  SysUtils;

var
  i: integer;
  img_files: TStringList;
  rc: TStringList;
  inc: TStringList;
  res: TStringList;
  s, inkscape_path, inkscape_app_path, cmd: string;

begin
  img_files := FindAllFiles(SetDirSeparators('..\datafiles\icons'), '*.svg', false);
  inkscape_path := 'inkscape';

{$IFDEF WINDOWS}
  inkscape_app_path := 'C:\Program Files\Inkscape\inkscape.exe';
  if FileExists(inkscape_app_path) then
    inkscape_path := inkscape_app_path;
{$ENDIF}

{$IFDEF DARWIN}
  inkscape_app_path := '/Applications/Inkscape.app/Contents/Resources/script';
  if DirectoryExists(inkscape_app_path) then
    inkscape_path := inkscape_app_path;
{$ENDIF}

  for i := 0 to img_files.Count - 1 do
  begin
    writeln('-- converting: ', img_files[i]);
    cmd := Format('%s "%s" --export-dpi=90 --without-gui --export-png="%s"',
      [inkscape_path, img_files[i], ChangeFileExt(img_files[i], '.png')]);
    RunCommand(cmd, s);
  end;
  img_files.Free;

  img_files := FindAllFiles(SetDirSeparators('..\datafiles\icons'), '*.png', false);
  rc := TStringList.Create;
  inc := TStringList.Create;
  res := TStringList.Create;
  try
    for i := 0 to img_files.Count - 1 do
    begin
      s := ChangeFileExt(ExtractFileName(img_files[i]), '');
      rc.Add(Format('%s RCDATA "%s"', [s, img_files[i]]));
      inc.Add(Format('  %s: integer = %d;', [s, i]));
      res.Add(Format('  ImageList.AddResourceName(HInstance, ''%s'');', [s]));
    end;

    rc.SaveToFile(SetDirSeparators('..\datafiles\icons.rc'));
    inc.SaveToFile(SetDirSeparators('..\datafiles\icons.inc'));
    res.SaveToFile(SetDirSeparators('..\datafiles\load_res.inc'));
  finally
    img_files.Free;
    rc.Free;
    inc.Free;
    res.Free;
  end;
end.
