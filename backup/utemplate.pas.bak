unit utemplate;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ActnList, db, sqldb;

type

  { TfrmTemplate }

  TfrmTemplate = class(TForm)
    acFirstRec: TAction;
    acPriorRec: TAction;
    acNextRec: TAction;
    acLastError: TAction;
    acNewRec: TAction;
    acRemoveRec: TAction;
    acSaveRec: TAction;
    acCancelAll: TAction;
    acEditRec: TAction;
    acCloseForm: TAction;
    alTemplate: TActionList;
    btnCancel: TButton;
    btnClose: TButton;
    btnEdit: TButton;
    btnFirst: TButton;
    btnPrior: TButton;
    btnNext: TButton;
    btnLast: TButton;
    btnNew: TButton;
    btnDelete: TButton;
    btnSave: TButton;
    lblFormCaption: TLabel;
    Panel1: TPanel;
    procedure acCancelAllExecute(Sender: TObject);
    procedure acCloseFormExecute(Sender: TObject);
    procedure acEditRecExecute(Sender: TObject);
    procedure acFirstRecExecute(Sender: TObject);
    procedure acLastErrorExecute(Sender: TObject);
    procedure acNewRecExecute(Sender: TObject);
    procedure acNextRecExecute(Sender: TObject);
    procedure acPriorRecExecute(Sender: TObject);
    procedure acRemoveRecExecute(Sender: TObject);
    procedure acSaveRecExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
    procedure doNewRec; virtual;
    procedure doRemoveRec; virtual;
    procedure doSaveRec; virtual;
    procedure doCancelRec; virtual;
    procedure doEditRec; virtual;
    procedure doFirstRec; virtual;
    procedure doPriorRec; virtual;
    procedure doNextRec; virtual;
    procedure doLastRec; virtual;
    procedure doCloseForm; virtual;
    // on events
    procedure onNewRec(var dataSet : TSQLQuery);
    procedure onRemoveRec(var dataSet : TSQLQuery);
    procedure onSaveRec(var dataSet : TSQLQuery);
    procedure onCancelRec(var dataSet : TSQLQuery);
    procedure onEditRec(var dataSet : TSQLQuery);
    procedure onFirstRec(var dataSet : TSQLQuery);
    procedure onPriorRec(var dataSet : TSQLQuery);
    procedure onNextRec(var dataSet : TSQLQuery);
    procedure onLastRec(var dataSet : TSQLQuery);
    procedure onCheckDataSets(var dataSet : TSQLQuery);
  end;

var
  frmTemplate: TfrmTemplate;

implementation
uses
  udeleteconfirmation, usavechanges;
{$R *.lfm}

{ TfrmTemplate }

procedure TfrmTemplate.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:= caFree;
  self:= nil;
end;

procedure TfrmTemplate.acFirstRecExecute(Sender: TObject);
begin
  doFirstRec;
end;

procedure TfrmTemplate.acCancelAllExecute(Sender: TObject);
begin
  doCancelRec;
end;

procedure TfrmTemplate.acCloseFormExecute(Sender: TObject);
begin
  doCloseForm;
end;

procedure TfrmTemplate.acEditRecExecute(Sender: TObject);
begin
  doEditRec;
end;

procedure TfrmTemplate.acLastErrorExecute(Sender: TObject);
begin
  doLastRec;
end;

procedure TfrmTemplate.acNewRecExecute(Sender: TObject);
begin
  doNewRec;
end;

procedure TfrmTemplate.acNextRecExecute(Sender: TObject);
begin
  doNextRec;
end;

procedure TfrmTemplate.acPriorRecExecute(Sender: TObject);
begin
  doPriorRec;
end;

procedure TfrmTemplate.acRemoveRecExecute(Sender: TObject);
begin
  doRemoveRec;
end;

procedure TfrmTemplate.acSaveRecExecute(Sender: TObject);
begin
  doSaveRec;
end;

procedure TfrmTemplate.doNewRec;
begin

end;

procedure TfrmTemplate.doRemoveRec;
begin

end;

procedure TfrmTemplate.doSaveRec;
begin

end;

procedure TfrmTemplate.doCancelRec;
begin

end;

procedure TfrmTemplate.doEditRec;
begin

end;

procedure TfrmTemplate.doFirstRec;
begin

end;

procedure TfrmTemplate.doPriorRec;
begin

end;

procedure TfrmTemplate.doNextRec;
begin

end;

procedure TfrmTemplate.doLastRec;
begin

end;

procedure TfrmTemplate.doCloseForm;
begin

end;

procedure TfrmTemplate.onNewRec(var dataSet: TSQLQuery);
begin
  //new record
  dataSet.Insert;
end;

procedure TfrmTemplate.onRemoveRec(var dataSet: TSQLQuery);
var
  newDialog : TdlgDeleteConfirmation;
begin
  {can't be empty}
  if(dataSet.IsEmpty) then
    Exit;
  {check state}
  if(dataSet.State in [dsEdit, dsInsert]) then
    Exit;
  {confirm}
  newDialog:= TdlgDeleteConfirmation.Create(nil);
  if(newDialog.ShowModal = mrOK) then
    dataSet.Delete;
  {free dialog}
  newDialog.Free;
end;

procedure TfrmTemplate.onSaveRec(var dataSet: TSQLQuery);
begin
  {check state}
  if(dataSet.State in [dsEdit, dsInsert]) then
    dataSet.Post;
end;

procedure TfrmTemplate.onCancelRec(var dataSet: TSQLQuery);
begin
  {check state}
  if(dataSet.State in [dsEdit, dsInsert]) then
    dataSet.Cancel;
end;

procedure TfrmTemplate.onEditRec(var dataSet: TSQLQuery);
begin
  if(dataSet.State in [dsBrowse]) then
    dataSet.Edit;
end;

procedure TfrmTemplate.onFirstRec(var dataSet: TSQLQuery);
begin
  {can't be empty}
  if(not dataSet.IsEmpty) then
    if(not dataSet.BOF) then
      dataSet.First;
end;

procedure TfrmTemplate.onPriorRec(var dataSet: TSQLQuery);
begin
  {can't be empty}
  if(not dataSet.IsEmpty) then
    if(not dataSet.BOF) then
      dataSet.Prior;
end;

procedure TfrmTemplate.onNextRec(var dataSet: TSQLQuery);
begin
  {can't be empty}
  if(not dataSet.IsEmpty) then
    if(not dataSet.EOF) then
      dataSet.Next;
end;

procedure TfrmTemplate.onLastRec(var dataSet: TSQLQuery);
begin
  {can't be empty}
  if(not dataSet.IsEmpty) then
    if(not dataSet.EOF) then
      dataSet.Last;
end;

procedure TfrmTemplate.onCheckDataSets(var dataSet: TSQLQuery);
var
  newDialog : TdlgSaveChanges;
begin
  {check states(changes)}
  if(dataSet.State in [dsEdit, dsInsert]) then
    begin
      {confirm}
      newDialog:= TdlgSaveChanges.Create(nil);
      if(newDialog.ShowModal = mrOK) then
        dataSet.Post
      else
        dataSet.Cancel;
      {free dialog}
      newDialog.Free;
    end;
end;



end.

