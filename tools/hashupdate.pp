program hashupdate;

uses
  Classes, Process, SysUtils;

var
  str: string;
  sl: TStringList;
begin
  //git log --pretty=format:'%h' -n 1 > hash.inc

  sl := TStringList.Create;

  if RunCommand('git', ['log', '--pretty=format:''%h''', '-n 1'], str) then
    sl.Add(str)
  else
    sl.Add('''unknown''');

  sl.SaveToFile(SetDirSeparators('..\src\hash.inc'));

  sl.Free;
end.
