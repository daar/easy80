unit MessageIntf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls;

type

  { TMessageIntf }

  TMessageIntf = class
  private
    FMessageView: TMemo;

  public

    constructor Create;
    destructor Destroy; override;

    procedure RegisterView(MessageView: TMemo);

    procedure Log(Msg: string);
    procedure LogFmt(Msg: string; Args: array of const);
  end;

var
  Messages: TMessageIntf;

implementation

{ TMessageIntf }

constructor TMessageIntf.Create;
begin

end;

destructor TMessageIntf.Destroy;
begin
  inherited Destroy;
end;

procedure TMessageIntf.RegisterView(MessageView: TMemo);
begin
  FMessageView := MessageView;
end;

procedure TMessageIntf.Log(Msg: string);
begin
  if FMessageView <> nil then
    FMessageView.Lines.Add(Msg);
end;

procedure TMessageIntf.LogFmt(Msg: string; Args: array of const);
begin
  if FMessageView <> nil then
    FMessageView.Lines.Add(Format(Msg, Args));
end;

initialization
  Messages := TMessageIntf.Create;

finalization
  Messages.Free;

end.

