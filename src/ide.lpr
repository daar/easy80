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
  LazOpenGLContext,
  DefaultTranslator, ResourceStrings,
  main, SplashScreen
  { you can add units after this };

{$R *.res}
{$R .\datafiles\icons.rc}

begin
  Application.Title := 'easy80-ide';
  RequireDerivedFormResource := True;
  Application.Initialize;

  Application.CreateForm(TMainForm, MainForm);

  Application.Run;
end.
