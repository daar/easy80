unit SplashScreen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ResourceStrings;

type

  { TSplash }

  TSplash = class(TFrame)
    BackgroundImage: TImage;
    BeCreativeLabel: TLabel;
    BuildDateLabel: TLabel;
    CompilerVersionLabel: TLabel;
    DescriptionLabel: TLabel;
    Easy80Label: TLabel;
    Easy80LogoImage: TImage;
    HashLabel: TLabel;
    ScrollBox1: TScrollBox;
    VersionLabel: TLabel;
  private
    function GetLocalizedBuildDate: string;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  Splash: TSplash;

implementation

{$R *.lfm}

{ TSplash }

{The compiler generated date string is always of the form y/m/d.
 This function gives it a string respresentation according to the
 shortdateformat}
function TSplash.GetLocalizedBuildDate: string;
var
  BuildDate, BuildTime: string;
  SlashPos1, SlashPos2: integer;
  Date, Time: TDateTime;
begin
  BuildDate := {$i %date%};
  BuildTime := {$i %time%};

  SlashPos1 := Pos('/',BuildDate);
  SlashPos2 := SlashPos1 + Pos('/', Copy(BuildDate, SlashPos1+1, Length(BuildDate)-SlashPos1));
  Date := EncodeDate(StrToInt(Copy(BuildDate,1,SlashPos1-1)),
    StrToInt(Copy(BuildDate,SlashPos1+1,SlashPos2-SlashPos1-1)),
    StrToInt(Copy(BuildDate,SlashPos2+1,Length(BuildDate)-SlashPos2)));

  Time := EncodeTime(StrToInt(Copy(BuildTime, 1, 2)), StrToInt(Copy(BuildTime, 4, 2)), 0, 0);

  Result := FormatDateTime('c', Date) + ' ' + FormatDateTime('t', Time);
end;

constructor TSplash.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Caption := Format(rsEasy80IDEVS, [{$i version.inc}]);
  VersionLabel.Caption := Format(rsEasy80IDEVS, [{$i version.inc}]);

  BuildDateLabel.Caption := Format(rsDateS, [GetLocalizedBuildDate]);
  HashLabel.Caption := Format('Hash: %s', [{$i hash.inc}]);
  CompilerVersionLabel.Caption:= Format('FPC: %s (%s-%s)', [{$i %FPCVERSION%}, {$I %FPCTARGETCPU%}, {$I %FPCTARGETOS%}]);
end;

end.

