unit usavechanges;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TdlgSaveChanges }

  TdlgSaveChanges = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    DividerBevel1: TDividerBevel;
    Image1: TImage;
    Label1: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  dlgSaveChanges: TdlgSaveChanges;

implementation

{$R *.lfm}

end.

