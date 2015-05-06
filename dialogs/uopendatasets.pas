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
  MAX_PROGRESS : Integer = 8;
begin
  self.progBar.Position:= 0;
  self.progBar.Max:= MAX_PROGRESS;
  // open dataSet storages
  dbm.qStorages.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet product
  dbm.qProducts.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet template
  dbm.qTemplate.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet doc storage-in
  dbm.qDocStorageIn.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet doc storage-out
  dbm.qDocStorageOut.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet requisition
  dbm.qRequisition.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet storage-in
  dbm.qStorageIn.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  // open dataSet storage-out
  dbm.qStorageOut.Open;
  self.progBar.StepBy(1);
  Application.ProcessMessages;
  //return ok
  //Sleep(1500);
  self.ModalResult:= mrOK;
  self.Close;
end;

end.

