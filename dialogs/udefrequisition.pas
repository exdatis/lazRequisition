unit udefrequisition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, ActnList, DbCtrls, Buttons, DBGrids, utemplate;

type

  { TfrmDefRequisition }

  TfrmDefRequisition = class(TfrmTemplate)
    cmbSearchArg: TComboBox;
    dbgDefaultRequisition: TDBGrid;
    dbProduct: TDBEdit;
    dbQuantity: TDBEdit;
    dbMeasure: TDBEdit;
    edtSearchProduct: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel2: TPanel;
    sbtnFindProduct: TSpeedButton;
    procedure dbgDefaultRequisitionMouseEnter(Sender: TObject);
    procedure dbgDefaultRequisitionMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure dbgDefaultRequisitionTitleClick(Column: TColumn);
  private
    { private declarations }
  public
    { public declarations }
    procedure doNewRec; override;
    procedure doRemoveRec; override;
    procedure doSaveRec; override;
    procedure doCancelRec; override;
    procedure doEditRec; override;
    procedure doFirstRec; override;
    procedure doPriorRec; override;
    procedure doNextRec; override;
    procedure doLastRec; override;
    procedure doCloseForm; override;
  end;

var
  frmDefRequisition: TfrmDefRequisition;

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TfrmDefRequisition }

procedure TfrmDefRequisition.dbgDefaultRequisitionMouseEnter(Sender: TObject);
begin
  dbgDefaultRequisition.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmDefRequisition.dbgDefaultRequisitionMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  dbgDefaultRequisition.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmDefRequisition.dbgDefaultRequisitionTitleClick(Column: TColumn);
begin
  if not dbm.qTemplate.IsEmpty then
    dbm.qTemplate.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmDefRequisition.doNewRec;
begin
  inherited doNewRec;
  onNewRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doRemoveRec;
begin
  inherited doRemoveRec;
  onRemoveRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doSaveRec;
begin
  inherited doSaveRec;
  onSaveRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doCancelRec;
begin
  inherited doCancelRec;
  onCancelRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doEditRec;
begin
  inherited doEditRec;
  dbProduct.SetFocus;
  dbProduct.SelectAll;
  onEditRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doFirstRec;
begin
  inherited doFirstRec;
  onFirstRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doPriorRec;
begin
  inherited doPriorRec;
  onPriorRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doNextRec;
begin
  inherited doNextRec;
  onNextRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doLastRec;
begin
  inherited doLastRec;
  onLastRec(dbm.qTemplate);
end;

procedure TfrmDefRequisition.doCloseForm;
begin
  inherited doCloseForm;
  onCheckDataSets(dbm.qTemplate);
  self.Close;
  enableStorageSettings;
end;

end.

