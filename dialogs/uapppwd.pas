unit uapppwd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TdlgAppPwd }

  TdlgAppPwd = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    edtPwd: TEdit;
    edtUser: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  dlgAppPwd: TdlgAppPwd;

implementation

{$R *.lfm}

end.

