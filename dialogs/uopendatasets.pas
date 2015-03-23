unit uopendatasets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls;

type

  { TdlgOpenDataSets }

  TdlgOpenDataSets = class(TForm)
    progBar: TProgressBar;
  private
    { private declarations }
  public
    { public declarations }
    procedure openDataSets;
  end;

var
  dlgOpenDataSets: TdlgOpenDataSets;

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TdlgOpenDataSets }

procedure TdlgOpenDataSets.openDataSets;
const
  MAX_PROGRESS : Integer = 5;
begin
  self.progBar.Position:= 0;
  self.progBar.Max:= MAX_PROGRESS;
  self.ModalResult:= mrOK;
end;

end.
