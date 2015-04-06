unit ustoragein;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ExtendedNotebook, DBZVDateTimePicker, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ActnList, Buttons, ComCtrls,
  DbCtrls, DBGrids, utemplate;

type

  { TfrmStorageIn }

  TfrmStorageIn = class(TfrmTemplate)
    bitBtnItems: TBitBtn;
    bitBtnOrders: TBitBtn;
    btnGenAll: TButton;
    dbcApplied: TDBCheckBox;
    dbcCanceled: TDBCheckBox;
    dbgOrder: TDBGrid;
    dblDoc: TDBLookupComboBox;
    dblSupplierStorage: TDBLookupComboBox;
    dblUserStorage: TDBLookupComboBox;
    dbmNotes: TDBMemo;
    dbOrderDate: TDBZVDateTimePicker;
    enbForms: TExtendedNotebook;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    tsItems: TTabSheet;
    tsOrder: TTabSheet;
    procedure dbgOrderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgOrderTitleClick(Column: TColumn);
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
  frmStorageIn: TfrmStorageIn;
const
  DEFAULT_TITLE : String = 'Interni prijem robe u magacin'; //dodavati title stranice

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TfrmStorageIn }

procedure TfrmStorageIn.dbgOrderMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  dbgOrder.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.dbgOrderTitleClick(Column: TColumn);
begin
  if not dbm.qStorageIn.IsEmpty then
    dbm.qStorageIn.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.doNewRec;
begin
  inherited doNewRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onNewRec(dbm.qStorageIn);
         //set focus
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         Screen.Cursor:= crDefault;
       end;
    1: begin
         {Screen.Cursor:= crSQLWait;
         //set focus
         dbProduct.SetFocus;
         onNewRec(qItems);
         Screen.Cursor:= crDefault;}
       end;
  end;
end;

procedure TfrmStorageIn.doRemoveRec;
begin
  inherited doRemoveRec;
  case enbForms.ActivePageIndex of
    0: onRemoveRec(dbm.qStorageIn);
    1:begin
         {if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         if (LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         if (LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         onRemoveRec(qItems);}
       end;
  end;
end;

procedure TfrmStorageIn.doSaveRec;
begin
  inherited doSaveRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onSaveRec(dbm.qStorageIn);
         Screen.Cursor:= crDefault;
       end;
    1: begin
         {if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         if (LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         if (LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         onSaveRec(qItems);}
       end;
  end;
end;

procedure TfrmStorageIn.doCancelRec;
begin
  inherited doCancelRec;
  case enbForms.ActivePageIndex of
    0: onCancelRec(dbm.qStorageIn);
    //1: onCancelRec(qItems);
  end;
end;

procedure TfrmStorageIn.doEditRec;
begin
  inherited doEditRec;
  case enbForms.ActivePageIndex of
    0: begin
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         onEditRec(dbm.qStorageIn);
       end;
    1: begin
         {if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         if (LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         if (LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         onEditRec(qItems);
         dbProduct.SetFocus;
         dbProduct.SelectAll;}
       end;
  end;
end;

procedure TfrmStorageIn.doFirstRec;
begin
  inherited doFirstRec;
  case enbForms.ActivePageIndex of
    0: onFirstRec(dbm.qStorageIn);
    //1: onFirstRec(qItems);
  end;
end;

procedure TfrmStorageIn.doPriorRec;
begin
  inherited doPriorRec;
  case enbForms.ActivePageIndex of
    0: onPriorRec(dbm.qStorageIn);
    //1: onPriorRec(qItems);
  end;
end;

procedure TfrmStorageIn.doNextRec;
begin
  inherited doNextRec;
  case enbForms.ActivePageIndex of
    0: onNextRec(dbm.qStorageIn);
    //1: onNextRec(qItems);
  end;
end;

procedure TfrmStorageIn.doLastRec;
begin
  inherited doLastRec;
  case enbForms.ActivePageIndex of
    0: onLastRec(dbm.qStorageIn);
    //1: onLastRec(qItems);
  end;
end;

procedure TfrmStorageIn.doCloseForm;
begin
  inherited doCloseForm;
  onCheckDataSets(dbm.qStorageIn);
  //onCheckDataSets(qItems);
  self.Close;
  enableStorageSettings;
end;

end.

