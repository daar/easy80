program ide;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}
  {$IFDEF UseCThreads}
    cthreads,
  {$ENDIF}
{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  lazcontrols,
  LCLTranslator, ResourceStrings, IDELocale,
  main, SplashScreen, AppSettings, MessageIntf, SettingsFrame;

{$R *.res}
{$R .\datafiles\icons.rc}
{$R .\datafiles\highlighters.rc}

var
  LangID: string;
begin
  Application.Title := 'easy80-ide';
  RequireDerivedFormResource := True;
  Application.Initialize;

  Application.CreateForm(TMainForm, MainForm);

  //set the language at startup
  LangID := GetLangIDFromLanguage(Settings.Language);
  if LangID <> 'en_US' then
    SetDefaultLang(LangID, 'locale', True);

  Application.Run;
end.
