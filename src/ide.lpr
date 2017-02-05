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
  main, SplashScreen, OptionsDialog, AppSettings, MessageIntf;

{$R *.res}
{$R .\datafiles\icons.rc}

var
  LangID: string;
  ShowSplash: Boolean;
begin
  Application.Title := 'easy80-ide';
  RequireDerivedFormResource := True;
  Application.Initialize;

  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TOptionsDlg, OptionsDlg);

  ShowSplash := not Application.HasOption('no-splash');

  //the splash screen
  if ShowSplash then
    Splash := TSplash.Create(Application);

  //set the language at startup
  LangID := GetLangIDFromLanguage(Settings.Language);
  if LangID <> 'en_US' then
    SetDefaultLang(LangID, 'locale', True);

  if ShowSplash then
  begin
    Splash.ShowModal;
    Splash.Close;
    Splash.Release;
  end;

  Application.Run;
end.
