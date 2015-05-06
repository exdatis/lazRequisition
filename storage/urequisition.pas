unit urequisition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ExtendedNotebook, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, ActnList, Buttons, ComCtrls, StdCtrls,
  DbCtrls, DBGrids, Menus, utemplate, DBDateTimePicker, db, sqldb;

type

  { TfrmRequisition }

  TfrmRequisition = class(TfrmTemplate)
    acFProductByName: TAction;
    acFProductByCode: TAction;
    bitBtnItems: TBitBtn;
    bitBtnOrders: TBitBtn;
    btnGetItems: TButton;
    btnNotThisProduct: TButton;
    btnThisProduct: TButton;
    cmbSearchArg: TComboBox;
    dbOrderDate: TDBDateTimePicker;
    dbgItems: TDBGrid;
    dbgProductsFound: TDBGrid;
    dbMeasure: TDBEdit;
    dbProduct: TDBEdit;
    dbQuantity: TDBEdit;
    dsFindProduct: TDataSource;
    dsItems: TDataSource;
    dbcApplied: TDBCheckBox;
    dbcFinished: TDBCheckBox;
    dbcCanceled: TDBCheckBox;
    DBGrid1: TDBGrid;
    dblDoc: TDBLookupComboBox;
    dblSupplierStorage: TDBLookupComboBox;
    dblUserStorage: TDBLookupComboBox;
    dbmNotes: TDBMemo;
    edtSearchProduct: TEdit;
    enbForms: TExtendedNotebook;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    panelProductDlg: TPanel;
    popFindProduct: TPopupMenu;
    prgBar: TProgressBar;
    qFindProduct: TSQLQuery;
    qFindProductag_naziv: TStringField;
    qFindProductart_id: TLongintField;
    qFindProductart_naziv: TStringField;
    qFindProductart_sifra: TStringField;
    qFindProductjm_naziv: TStringField;
    qItems: TSQLQuery;
    qItemsag_naziv: TStringField;
    qItemsart_naziv: TStringField;
    qItemsart_sifra: TStringField;
    qItemsjm_naziv: TStringField;
    qItemsts_artikal: TLongintField;
    qItemsts_id: TLongintField;
    qItemsts_kolicina: TBCDField;
    qItemsts_veza: TLongintField;
    sbtnFindProduct: TSpeedButton;
    tsItems: TTabSheet;
    tsOrders: TTabSheet;
    procedure acFProductByCodeExecute(Sender: TObject);
    procedure acFProductByNameExecute(Sender: TObject);
    procedure bitBtnItemsClick(Sender: TObject);
    procedure bitBtnOrdersClick(Sender: TObject);
    procedure btnGetItemsClick(Sender: TObject);
    procedure btnNotThisProductClick(Sender: TObject);
    procedure btnThisProductClick(Sender: TObject);
    procedure cmbSearchArgChange(Sender: TObject);
    procedure dbcAppliedChange(Sender: TObject);
    procedure dbcCanceledChange(Sender: TObject);
    procedure dbcFinishedClick(Sender: TObject);
    procedure dbgItemsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgItemsTitleClick(Column: TColumn);
    procedure dbgProductsFoundKeyPress(Sender: TObject; var Key: char);
    procedure DBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure dbProductKeyPress(Sender: TObject; var Key: char);
    procedure edtSearchProductKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure enbFormsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure qItemsAfterDelete(DataSet: TDataSet);
    procedure qItemsAfterPost(DataSet: TDataSet);
    procedure qItemsBeforeDelete(DataSet: TDataSet);
    procedure qItemsBeforeEdit(DataSet: TDataSet);
    procedure qItemsBeforeOpen(DataSet: TDataSet);
    procedure qItemsBeforePost(DataSet: TDataSet);
    procedure qItemsNewRecord(DataSet: TDataSet);
    procedure sbtnFindProductClick(Sender: TObject);
  private
    { private declarations }
    sql_find_product : String;
    function doFindProduct(const sql_clause : String) : Boolean;
    procedure reopenItems;
    procedure onPageItems;
    procedure genItems;
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
  frmRequisition: TfrmRequisition;
const
  DEFAULT_TITLE : String = 'Trebovanje robe'; //dodavati title stranice

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TfrmRequisition }

procedure TfrmRequisition.enbFormsChange(Sender: TObject);
var
  newTitle : String;
begin
  case enbForms.ActivePageIndex of
    0: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi trebovanja]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
    1: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Stavke trebovanja]';
         lblFormCaption.Caption:= newTitle;
         if qItems.IsEmpty then
           btnGetItems.Enabled:= True
         else
           btnGetItems.Enabled:= False;
         Application.ProcessMessages;
       end;
  else
    begin
      newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi trebovanja]';
      lblFormCaption.Caption:= newTitle;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TfrmRequisition.FormCreate(Sender: TObject);
begin
  sql_find_product:= 'SELECT art_id, art_sifra, art_naziv, jm_naziv, ag_naziv ' +
                      'FROM  vproduct ';
end;

procedure TfrmRequisition.dbcFinishedClick(Sender: TObject);
begin
   ShowMessage(READ_ONLY_ERROR);
   btnCancel.SetFocus;
end;

procedure TfrmRequisition.dbgItemsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  dbgItems.Cursor:= crHandPoint;
end;

procedure TfrmRequisition.dbgItemsTitleClick(Column: TColumn);
begin
  if not qItems.IsEmpty then
    qItems.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.dbgProductsFoundKeyPress(Sender: TObject;
  var Key: char);
begin
  if Key = #32 then
    btnThisProduct.Click; //space
end;

procedure TfrmRequisition.dbcCanceledChange(Sender: TObject);
const
  ALREDY_CANCELED : String = 'Greška: dokument je već storniran.';
  ALREDY_FINISHED : String = 'Greška: dokument je obradjen ili u obradi.';
  APPLY_CHANGES : String = 'Dokument je storniran.';
  DO_EDIT : String = 'Dokument je spreman za izmene.';
var
  is_canceled : String = '';
begin

    if(LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
    begin
      ShowMessage(ALREDY_FINISHED);
      btnCancel.Click;
      Exit;
    end;

    //sacuvaj
    if(LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
      begin
        dbm.qRequisition.FieldByName('t_potvrda').AsString:= 'Ne';
        btnSave.Click;
        ShowMessage(APPLY_CHANGES);
        Exit;
      end;

    if(LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Ne')) then
      begin
        btnSave.Click;
        ShowMessage(DO_EDIT);
        Exit;
      end;
end;

procedure TfrmRequisition.dbcAppliedChange(Sender: TObject);
const
  ALREDY_FINISHED : String = 'Greška: dokument je obradjen ili u obradi.';
  APPLY_CHANGES : String = 'Dokument je potvrdjen.';
  DO_CANCEL : String = 'Greška: stornirajte dokument.';
var
  is_canceled : String = '';
begin

    if(LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
    begin
      ShowMessage(ALREDY_FINISHED);
      btnCancel.Click;
      Exit;
    end;

    //sacuvaj
    if(LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Da')) then
      begin
        dbm.qRequisition.FieldByName('t_storniran').AsString:= 'Ne';
        btnSave.Click;
        ShowMessage(APPLY_CHANGES);
        Exit;
      end;

    if(LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Ne')) then
      begin
        btnCancel.Click;
        ShowMessage(DO_CANCEL);
        Exit;
      end;
end;

procedure TfrmRequisition.acFProductByNameExecute(Sender: TObject);
var
  sql_clause : String;
begin
  // proveri dali je u insert ili edit modu
  if not(qItems.State in [dsInsert, dsEdit]) then
    begin
      ShowMessage(EDIT_MOD_ERROR);
      Exit;
    end;
  sql_clause:= ' WHERE lower(art_naziv) LIKE lower(:art_naziv) Order By art_naziv';
  //run query
  if doFindProduct(sql_clause) then
    begin
      if qFindProduct.IsEmpty then
        begin
          ShowMessage(EMPTY_SET_ERROR);
          Exit;
        end;
      // ako postoji samo jedan zapis
      if(qFindProduct.RecordCount < 2) then
        begin
          qItems.FieldByName('ts_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
          qItems.FieldByName('art_naziv').AsString:= qFindProduct.FieldByName('art_naziv').AsString;
          qItems.FieldByName('jm_naziv').AsString:= qFindProduct.FieldByName('jm_naziv').AsString;
          dbQuantity.SetFocus;  //naredni za popunjavanje
          Exit;
        end;
      //else show result
      panelProductDlg.Visible:= True;
      dbgProductsFound.SetFocus;
    end;
end;

procedure TfrmRequisition.bitBtnItemsClick(Sender: TObject);
begin
  onPageItems;
end;

procedure TfrmRequisition.bitBtnOrdersClick(Sender: TObject);
begin
  //set active page
  enbForms.ActivePageIndex:= 0;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.btnGetItemsClick(Sender: TObject);
begin
  genItems;
end;

procedure TfrmRequisition.btnNotThisProductClick(Sender: TObject);
begin
  panelProductDlg.Visible:= False;
  dbProduct.SetFocus;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.btnThisProductClick(Sender: TObject);
begin
  qItems.FieldByName('ts_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
  qItems.FieldByName('art_naziv').AsString:= qFindProduct.FieldByName('art_naziv').AsString;
  qItems.FieldByName('jm_naziv').AsString:= qFindProduct.FieldByName('jm_naziv').AsString;
  panelProductDlg.Visible:= False;
  dbQuantity.SetFocus;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.cmbSearchArgChange(Sender: TObject);
begin
  //obrisi tekst i dodeli fokus polju za pretragu
  edtSearchProduct.Clear;
  edtSearchProduct.SetFocus;
end;

procedure TfrmRequisition.acFProductByCodeExecute(Sender: TObject);
var
  sql_clause : String;
begin
  // proveri dali je u insert ili edit modu
  if not(qItems.State in [dsInsert, dsEdit]) then
    begin
      ShowMessage(EDIT_MOD_ERROR);
      Exit;
    end;
  sql_clause:= ' WHERE lower(art_sifra) LIKE lower(:art_sifra) Order By art_naziv';
  //run query
  if doFindProduct(sql_clause) then
    begin
      if qFindProduct.IsEmpty then
        begin
          ShowMessage(EMPTY_SET_ERROR);
          Exit;
        end;
      // ako postoji samo jedan zapis
      if(qFindProduct.RecordCount < 2) then
        begin
          qItems.FieldByName('ts_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
          qItems.FieldByName('art_naziv').AsString:= qFindProduct.FieldByName('art_naziv').AsString;
          qItems.FieldByName('jm_naziv').AsString:= qFindProduct.FieldByName('jm_naziv').AsString;
          dbQuantity.SetFocus;  //naredni za popunjavanje
          Exit;
        end;
      //else show result
      panelProductDlg.Visible:= True;
      dbgProductsFound.SetFocus;
    end;
end;

procedure TfrmRequisition.DBGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  DBGrid1.Cursor:= crHandPoint;
end;

procedure TfrmRequisition.DBGrid1TitleClick(Column: TColumn);
begin
  if not dbm.qRequisition.IsEmpty then
    dbm.qRequisition.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.dbProductKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    acFProductByName.Execute;
end;

procedure TfrmRequisition.edtSearchProductKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  currArg : String = '';
begin
  case cmbSearchArg.ItemIndex of
    1: currArg:= 'art_naziv'; // trazi po imenu proizvoda
    2: currArg:= 'art_sifra'; // trazi po sifri proizvoda;
  else
    currArg:= 'art_naziv'; // trazi po imenu proizvoda;
  end;
  if not qItems.Locate(currArg, edtSearchProduct.Text, [loCaseInsensitive, loPartialKey]) then
    begin
      Beep;
      edtSearchProduct.SetFocus;
      edtSearchProduct.SelectAll;
    end;
end;

procedure TfrmRequisition.FormShow(Sender: TObject);
var
  newTitle : String;
begin
  enbForms.ActivePageIndex:= 0;
  // set title
  newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi trebovanja]';
  lblFormCaption.Caption:= newTitle;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.qItemsAfterDelete(DataSet: TDataSet);
begin
  dbm.postChanges(TSQLQuery(DataSet));
end;

procedure TfrmRequisition.qItemsAfterPost(DataSet: TDataSet);
begin
  dbm.postChanges(TSQLQuery(DataSet));
end;

procedure TfrmRequisition.qItemsBeforeDelete(DataSet: TDataSet);
begin
  if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
  if (LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
  if (LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
end;

procedure TfrmRequisition.qItemsBeforeEdit(DataSet: TDataSet);
begin
  if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  if (LowerCase(dbm.qRequisition.FieldByName('t_potvrda').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  if (LowerCase(dbm.qRequisition.FieldByName('t_uradjen').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
end;

procedure TfrmRequisition.qItemsBeforeOpen(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).Params[0].AsInteger:= dbm.qRequisition.FieldByName('t_id').AsInteger;
end;

procedure TfrmRequisition.qItemsBeforePost(DataSet: TDataSet);
const
  ID_KEY : String = 'ts_id';
  SEQUENCE_NAME : String = 'trebovanje_stavke_ts_id_seq';
  FK_ORDER_FIELD : String = 'ts_veza';
var
  currHost, currPort : String;
  new_id : Integer = -1;
  currOrder : Integer = -1;
begin
  { check server before}
  currHost:= getCurrentHost;
  currPort:= getCurrentPort;
  if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
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
  //ShowMessage(currHost);
  //ShowMessage(currPort);
  if not dbm.checkServer(getCurrentHost, getCurrentPort) then
      dbm.cancelAll(TSQLQuery(DataSet))
    else
      begin
        if TSQLQuery(DataSet).FieldByName(ID_KEY).IsNull then
          begin
            new_id:= dbm.getNewKey(SEQUENCE_NAME);
            TSQLQuery(DataSet).FieldByName(ID_KEY).AsInteger:= new_id;
          end;
        //nalog kao spoljni kljuc
        currOrder:= dbm.qRequisition.FieldByName('t_id').AsInteger;
        TSQLQuery(DataSet).FieldByName(FK_ORDER_FIELD).AsInteger:= currOrder;
      end;
end;

procedure TfrmRequisition.qItemsNewRecord(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).FieldByName('ts_kolicina').AsFloat:= 1;
end;

procedure TfrmRequisition.sbtnFindProductClick(Sender: TObject);
begin
  popFindProduct.PopUp(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

function TfrmRequisition.doFindProduct(const sql_clause: String): Boolean;
var
  sql, search_param : String;
begin
  //kreiraj upit
  sql:= sql_find_product + sql_clause;
  //zatvori upit
  qFindProduct.DisableControls;
  qFindProduct.Close;
  qFindProduct.SQL.Clear;
  qFindProduct.SQL.Text:= sql;
  //param
  search_param:= '%' + dbProduct.Text + '%';
  qFindProduct.Params[0].AsString:= search_param;
  try
    qFindProduct.Open;
  except
    on e : Exception do
    begin
      qFindProduct.Close;
      qFindProduct.EnableControls;
      ShowMessage(e.Message);
      result:= False;
      Exit;
    end;
  end;
  // omoguci kontrole
  qFindProduct.EnableControls;
  result:= True;
end;

procedure TfrmRequisition.reopenItems;
begin
  qItems.DisableControls;
  try
    qItems.Close;
    qItems.Open;
  finally
    qItems.EnableControls;
  end;
end;

procedure TfrmRequisition.onPageItems;
begin
  // check order state
  if(dbm.qRequisition.State in [dsEdit, dsInsert]) then
    begin
      raise ESaveOrderException(SAVE_ORDER_ERROR);
      Exit;
    end;
  // check order(for id)
  if dbm.qRequisition.IsEmpty then
    begin
      raise ENoOrderException(NO_ORDER_ERROR);
      Exit;
    end;
  //open items
  Screen.Cursor:= crSQLWait;
  reopenItems;
  Screen.Cursor:= crDefault;
  //set active page
  enbForms.ActivePageIndex:= 1;
end;

procedure TfrmRequisition.genItems;
const
  MAX_PROGRESS : Integer = 5;
var
  sql : String = '';
  thisStorage : Integer = -1;
  thisOrder : Integer = -1;
begin
  //generisi stavke
  btnGetItems.Visible:= False;
  //progress
  prgBar.Max:= MAX_PROGRESS;
  prgBar.Visible:= True;
  //set sql on qGeneral
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  //progress
  prgBar.StepBy(1);
  Application.ProcessMessages;
  //create sql
  sql:= 'SELECT * FROM set_requisition_items(:storage_id, :order_id)';
  thisStorage:= getUserStorageId;
  thisOrder:= dbm.qRequisition.FieldByName('t_id').AsInteger;
  //progress
  prgBar.StepBy(1);
  Application.ProcessMessages;
  //set params
  dbm.qGeneral.SQL.Text:= sql;
  dbm.qGeneral.Params[0].AsInteger:= thisStorage;
  dbm.qGeneral.Params[1].AsInteger:= thisOrder;
  //progress
  prgBar.StepBy(1);
  Application.ProcessMessages;
  try
    dbm.qGeneral.Open;
    //progress
    prgBar.StepBy(1);
    Application.ProcessMessages;
  except
    on e : Exception do
    begin
      prgBar.Visible:= False;
      btnGetItems.Visible:= True;
      btnGetItems.Enabled:= False;
      ShowMessage(e.Message);
      dbm.qGeneral.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  end;
  //else
  if not dbm.qGeneral.IsEmpty then
    if dbm.qGeneral.Fields[0].AsInteger = 1 then
      begin
        dbm.qGeneral.ApplyUpdates;
        dbm.dbt.CommitRetaining;
        //progress
        prgBar.StepBy(1);
        Application.ProcessMessages;
        reopenItems;
        ShowMessage('Uspešno generisane stavke.');
      end;
  //reset progress
  prgBar.Position:= 0;
  prgBar.Visible:= False;

  btnGetItems.Visible:= True;
  btnGetItems.Enabled:= False;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.doNewRec;
begin
  inherited doNewRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onNewRec(dbm.qRequisition);
         //set focus
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         Screen.Cursor:= crDefault;
       end;
    1: begin
         Screen.Cursor:= crSQLWait;
         //set focus
         dbProduct.SetFocus;
         onNewRec(qItems);
         Screen.Cursor:= crDefault;
       end;
  end;
end;

procedure TfrmRequisition.doRemoveRec;
begin
  inherited doRemoveRec;
  case enbForms.ActivePageIndex of
    0: onRemoveRec(dbm.qRequisition);
    1:begin
         if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
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
         onRemoveRec(qItems);
       end;
  end;
end;

procedure TfrmRequisition.doSaveRec;
begin
  inherited doSaveRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onSaveRec(dbm.qRequisition);
         Screen.Cursor:= crDefault;
       end;
    1: begin
         if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
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
         onSaveRec(qItems);
       end;
  end;
end;

procedure TfrmRequisition.doCancelRec;
begin
  inherited doCancelRec;
  case enbForms.ActivePageIndex of
    0: onCancelRec(dbm.qRequisition);
    1: onCancelRec(qItems);
  end;
end;

procedure TfrmRequisition.doEditRec;
begin
  inherited doEditRec;
  case enbForms.ActivePageIndex of
    0: begin
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         onEditRec(dbm.qRequisition);
       end;
    1: begin
         if (LowerCase(dbm.qRequisition.FieldByName('t_storniran').AsString) = LowerCase('Da')) then
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
         dbProduct.SelectAll;
       end;
  end;
end;

procedure TfrmRequisition.doFirstRec;
begin
  inherited doFirstRec;
  case enbForms.ActivePageIndex of
    0: onFirstRec(dbm.qRequisition);
    1: onFirstRec(qItems);
  end;
end;

procedure TfrmRequisition.doPriorRec;
begin
  inherited doPriorRec;
  case enbForms.ActivePageIndex of
    0: onPriorRec(dbm.qRequisition);
    1: onPriorRec(qItems);
  end;
end;

procedure TfrmRequisition.doNextRec;
begin
  inherited doNextRec;
  case enbForms.ActivePageIndex of
    0: onNextRec(dbm.qRequisition);
    1: onNextRec(qItems);
  end;
end;

procedure TfrmRequisition.doLastRec;
begin
  inherited doLastRec;
  case enbForms.ActivePageIndex of
    0: onLastRec(dbm.qRequisition);
    1: onLastRec(qItems);
  end;
end;

procedure TfrmRequisition.doCloseForm;
begin
  inherited doCloseForm;
  onCheckDataSets(dbm.qRequisition);
  onCheckDataSets(qItems);
  self.Close;
  enableStorageSettings;
end;

end.

