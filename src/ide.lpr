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
  LazOpenGLContext, lazcontrols,
  LCLTranslator, ResourceStrings, IDELocale,
  main, SplashScreen, OptionsDialog
  { you can add units after this };

{$R *.res}
{$R .\datafiles\icons.rc}

var
  LangID: string;
begin
  Application.Title := 'easy80-ide';
  RequireDerivedFormResource := True;
  Application.Initialize;

  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TOptionsDlg, OptionsDlg);

  //the splash screen
  Splash := TSplash.Create(Application);

  LangID := GetLangIDFromLanguage(OptionsDlg.xml.GetValue('/language', rsSystemLanguage));
  if LangID <> 'en_US' then
    SetDefaultLang(LangID, 'locale', True);

  Splash.ShowModal;
  Splash.Close;
  Splash.Release;

  Application.Run;
end.
