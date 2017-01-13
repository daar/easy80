unit IDELocale;

interface

uses
  Classes, StdCtrls, ResourceStrings;

procedure LoadTranslations(cb: TComboBox);
function GetLangIDFromLanguage(Language: string): string;

implementation

procedure LoadTranslations(cb: TComboBox);
begin
  cb.Items.Add(rsSystemLanguage);

  cb.Items.Add(rsChineseZh_CN);
  cb.Items.Add(rsDutchNl_NL);
  cb.Items.Add(rsEnglishEn_US);
  cb.Items.Add(rsFrenchFr_FR);
  cb.Items.Add(rsGermanDe_DE);
  cb.Items.Add(rsItalianIt_IT);
  cb.Items.Add(rsPolishPl_PL);
  cb.Items.Add(rsSpanishEs_ES);

  cb.Sorted := True;
end;

function GetLangIDFromLanguage(Language: string): string;
var
  i: integer;
begin
  i := pos('(', Language);

  //no parentheses found so revert to default
  if i = -1 then
    exit('');

  exit(copy(Language, i + 1, pos(')', Language) - i - 1));
end;

end.
