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
    procedure btnGenAllClick(Sender: TObject);
    procedure dbgOrderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgOrderTitleClick(Column: TColumn);
  private
    { private declarations }
    procedure genInput;
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
  udbm, uexdatis, uopendatasets;
{$R *.lfm}

{ TfrmStorageIn }

procedure TfrmStorageIn.dbgOrderMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  dbgOrder.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.btnGenAllClick(Sender: TObject);
begin
  // check storages
  if MessageDlg('ExDatis', 'Proverili ste magacin prijema?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    genInput;
end;

procedure TfrmStorageIn.dbgOrderTitleClick(Column: TColumn);
begin
  if not dbm.qStorageIn.IsEmpty then
    dbm.qStorageIn.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.genInput;
var
  thisOrder : Integer = -1;
  thisUser : Integer = -1;
  orderAsString : String = '';
  sql : String;
  new_id : Integer = -1;
  error_msg, successMsgText : String;
  newDialog : TdlgOpenDataSets;
begin
  orderAsString:= InputBox('Broj predatnice', 'Unesite broj predatnice:', '');
  orderAsString:= StringReplace(orderAsString, #13, '', [rfReplaceAll]);
  try
    thisOrder:= StrToInt(orderAsString);
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  //if ok, get user-id
  thisUser:= getUserId;
  //run query
  Screen.Cursor:= crSQLWait;
  // prepare sql
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;

  sql:= 'SELECT * FROM copy_out(' + IntToStr(thisOrder) + ', ' + IntToStr(thisUser) + ')';
  //debug msg
  //ShowMessage(sql);
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
    //check new rec
    if dbm.qGeneral.IsEmpty then
      begin
        error_msg:= 'Nepoznata greška.' + #13#10;
        error_msg:= error_msg + 'Nemojte pokušavati ponovo.' + #13#10;
        error_msg:= error_msg + 'Pozovite: 062-804-8432' + #13#10;
        Screen.Cursor:= crDefault;
        ShowMessage(error_msg);
        Exit;
      end;
    new_id:= dbm.qGeneral.Fields[0].AsInteger;
    dbm.qGeneral.ApplyUpdates;
    dbm.dbt.CommitRetaining;
  except
    on e : Exception do
    begin
      dbm.qGeneral.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      Exit;
    end;
  end;

  //else reopen order
  dbm.qStorageIn.DisableControls;
  //cretate dialog
  newDialog:= TdlgOpenDataSets.Create(nil);
  //dbm.qStorageIn.Close;
  try
    dbm.dbh.CloseDataSets;
    dbm.dbh.Close();
    dbm.dbh.Open;
    //osvezi sve za probu
    //dbm.qStorageIn.Open;
    newDialog.openDataSets;
  except
    on e : Exception do
    begin
      newDialog.Free;
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      dbm.qStorageIn.EnableControls;
      Exit;
    end;
  end;
  //free dialog
  newDialog.Free;
  //locate
  if dbm.qStorageIn.Locate('mu_id', new_id, []) then
    dbm.qStorageIn.EnableControls
  else
    dbm.qStorageIn.EnableControls;
  //set cursor
  Screen.Cursor:= crDefault;
  successMsgText:= 'Kreirana je prijemnica broj: ' + IntToStr(new_id);
  ShowMessage(successMsgText);
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

