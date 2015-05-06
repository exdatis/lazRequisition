unit udeleteconfirmation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DividerBevel, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls;

type

  { TdlgDeleteConfirmation }

  TdlgDeleteConfirmation = class(TForm)
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
  dlgDeleteConfirmation: TdlgDeleteConfirmation;

implementation

{$R *.lfm}

end.

