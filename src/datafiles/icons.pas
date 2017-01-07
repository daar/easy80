unit icons;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls;

procedure LoadFromResource(ImageList: TImageList);

var
{$i icons.inc}

implementation

procedure LoadFromResource(ImageList: TImageList);
begin
{$i load_res.inc}
end;

end.

