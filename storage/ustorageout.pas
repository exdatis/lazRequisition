unit ustorageout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ExtendedNotebook, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ActnList, Buttons, ComCtrls,
  DbCtrls, DBGrids, Menus, utemplate, DBDateTimePicker, db, sqldb;

type

  { TfrmStorageOut }

  TfrmStorageOut = class(TfrmTemplate)
    acFProductByName: TAction;
    acFProductByCode: TAction;
    bitBtnItems: TBitBtn;
    bitBtnOrders: TBitBtn;
    btnNotThisProduct: TButton;
    btnThisProduct: TButton;
    cmbSearchArg: TComboBox;
    dbOrderDate: TDBDateTimePicker;
    dbgItems: TDBGrid;
    dbgProductsFound: TDBGrid;
    dsItems: TDataSource;
    dbcApplied: TDBCheckBox;
    dbcCanceled: TDBCheckBox;
    dbgOrders: TDBGrid;
    dblDoc: TDBLookupComboBox;
    dblSupplierStorage: TDBLookupComboBox;
    dblUserStorage: TDBLookupComboBox;
    dbMeasure: TDBEdit;
    dbmNotes: TDBMemo;
    dbProduct: TDBEdit;
    dbQuantity: TDBEdit;
    dsFindProduct: TDataSource;
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
    qItemsmis_artikal: TLongintField;
    qItemsmis_id: TLongintField;
    qItemsmis_kolicina: TBCDField;
    qItemsmis_veza: TLongintField;
    sbtnFindProduct: TSpeedButton;
    tsItems: TTabSheet;
    tsOrders: TTabSheet;
    procedure acFProductByCodeExecute(Sender: TObject);
    procedure acFProductByNameExecute(Sender: TObject);
    procedure bitBtnItemsClick(Sender: TObject);
    procedure bitBtnOrdersClick(Sender: TObject);
    procedure btnNotThisProductClick(Sender: TObject);
    procedure btnThisProductClick(Sender: TObject);
    procedure cmbSearchArgChange(Sender: TObject);
    procedure dbcAppliedChange(Sender: TObject);
    procedure dbcCanceledChange(Sender: TObject);
    procedure dbgItemsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgItemsTitleClick(Column: TColumn);
    procedure dbgOrdersMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgOrdersTitleClick(Column: TColumn);
    procedure dbgProductsFoundKeyPress(Sender: TObject; var Key: char);
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
    // evidencija
    procedure applyRecord;
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
  frmStorageOut: TfrmStorageOut;
const
  DEFAULT_TITLE : String = 'Interno izdavanje robe iz magacina'; //dodavati title stranice

implementation
uses
  udbm, uexdatis, uopendatasets;
{$R *.lfm}

{ TfrmStorageOut }

procedure TfrmStorageOut.dbgOrdersMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  dbgOrders.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.dbgItemsMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  dbgItems.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.cmbSearchArgChange(Sender: TObject);
begin
  //obrisi tekst i dodeli fokus polju za pretragu
  edtSearchProduct.Clear;
  edtSearchProduct.SetFocus;
end;

procedure TfrmStorageOut.dbcAppliedChange(Sender: TObject);
const
  Applied_error : String = 'Kliknite storno za brisanje evidencije.';
begin
  if (dbm.qStorageOut.FieldByName('mi_evident').AsString = 'Ne') then
    begin
      ShowMessage(Applied_error);
      btnCancel.Click;
    end
  else
    applyRecord;
end;

procedure TfrmStorageOut.dbcCanceledChange(Sender: TObject);
var
  sql : String;
  currOrder : Integer = -1;
  appliedMsg : String;
begin
  if (dbm.qStorageOut.IsEmpty) then
    begin
      btnCancel.Click;
      Exit;
    end;
  if (dbm.qStorageOut.FieldByName('mi_storno').AsString = 'Ne') then
    Exit;

  if(dbm.qStorageOut.FieldByName('mi_evident').AsString = 'Ne') then
    if (dbm.qStorageOut.FieldByName('mi_storno').AsString = 'Da') then
      begin
        btnCancel.Click;
        Exit;
      end;

  Screen.Cursor:= crSQLWait;
  // pripremi qGeneral
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  currOrder:= dbm.qStorageOut.FieldByName('mi_id').AsInteger;
  // napravi proceduru jer ovde treba select upit
  sql:= 'SELECT * FROM drop_storage_out(' + IntToStr(currOrder) + ')';
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      dbm.qStorageOut.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  end;
  //success msg
  appliedMsg:= 'Nalog je storniran.';
  dbm.qStorageOut.FieldByName('mi_evident').AsString := 'Ne';
  //commit
  dbm.qStorageOut.ApplyUpdates;
  dbm.qGeneral.ApplyUpdates;
  dbm.dbt.CommitRetaining;
  Screen.Cursor:= crDefault;
  ShowMessage(appliedMsg);
end;

procedure TfrmStorageOut.acFProductByNameExecute(Sender: TObject);
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
          qItems.FieldByName('mis_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
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

procedure TfrmStorageOut.bitBtnItemsClick(Sender: TObject);
begin
  onPageItems;
end;

procedure TfrmStorageOut.bitBtnOrdersClick(Sender: TObject);
begin
  //set active page
  enbForms.ActivePageIndex:= 0;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.btnNotThisProductClick(Sender: TObject);
begin
  panelProductDlg.Visible:= False;
  dbProduct.SetFocus;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.btnThisProductClick(Sender: TObject);
begin
  qItems.FieldByName('mis_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
  qItems.FieldByName('art_naziv').AsString:= qFindProduct.FieldByName('art_naziv').AsString;
  qItems.FieldByName('jm_naziv').AsString:= qFindProduct.FieldByName('jm_naziv').AsString;
  panelProductDlg.Visible:= False;
  dbQuantity.SetFocus;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.acFProductByCodeExecute(Sender: TObject);
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
          qItems.FieldByName('mis_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
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

procedure TfrmStorageOut.dbgItemsTitleClick(Column: TColumn);
begin
  if not qItems.IsEmpty then
    qItems.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.dbgOrdersTitleClick(Column: TColumn);
begin
  if not dbm.qStorageOut.IsEmpty then
    dbm.qStorageOut.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.dbgProductsFoundKeyPress(Sender: TObject; var Key: char
  );
begin
  if Key = #32 then
    btnThisProduct.Click; //space
end;

procedure TfrmStorageOut.dbProductKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    acFProductByName.Execute;
end;

procedure TfrmStorageOut.edtSearchProductKeyUp(Sender: TObject; var Key: Word;
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

procedure TfrmStorageOut.enbFormsChange(Sender: TObject);
var
  newTitle : String;
begin
  case enbForms.ActivePageIndex of
    0: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi predaje robe]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
    1: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Stavke - predata roba]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
  else
    begin
      newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi predaje robe]';
      lblFormCaption.Caption:= newTitle;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TfrmStorageOut.FormCreate(Sender: TObject);
begin
  sql_find_product:= 'SELECT art_id, art_sifra, art_naziv, jm_naziv, ag_naziv ' +
                      'FROM  vproduct ';
end;

procedure TfrmStorageOut.FormShow(Sender: TObject);
var
  newTitle : String;
begin
  enbForms.ActivePageIndex:= 0;
  // set title
  newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi predaje robe]';
  lblFormCaption.Caption:= newTitle;
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.qItemsAfterDelete(DataSet: TDataSet);
begin
  dbm.postChanges(TSQLQuery(DataSet));
end;

procedure TfrmStorageOut.qItemsAfterPost(DataSet: TDataSet);
begin
  dbm.postChanges(TSQLQuery(DataSet));
end;

procedure TfrmStorageOut.qItemsBeforeDelete(DataSet: TDataSet);
begin
  if (LowerCase(dbm.qStorageOut.FieldByName('mi_storno').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
  if (LowerCase(dbm.qStorageOut.FieldByName('mi_evident').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
end;

procedure TfrmStorageOut.qItemsBeforeEdit(DataSet: TDataSet);
begin
  if (LowerCase(dbm.qStorageOut.FieldByName('mi_storno').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  if (LowerCase(dbm.qStorageOut.FieldByName('mi_evident').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
end;

procedure TfrmStorageOut.qItemsBeforeOpen(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).Params[0].AsInteger:= dbm.qStorageOut.FieldByName('mi_id').AsInteger;
end;

procedure TfrmStorageOut.qItemsBeforePost(DataSet: TDataSet);
const
  ID_KEY : String = 'mis_id';
  SEQUENCE_NAME : String = 'mi_stavke_mis_id_seq';
  FK_ORDER_FIELD : String = 'mis_veza';
var
  currHost, currPort : String;
  new_id : Integer = -1;
  currOrder : Integer = -1;
begin
  { check server before}
  currHost:= getCurrentHost;
  currPort:= getCurrentPort;
  if (LowerCase(dbm.qStorageOut.FieldByName('mi_storno').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;

  if (LowerCase(dbm.qStorageOut.FieldByName('mi_evident').AsString) = LowerCase('Da')) then
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
        currOrder:= dbm.qStorageOut.FieldByName('mi_id').AsInteger;
        TSQLQuery(DataSet).FieldByName(FK_ORDER_FIELD).AsInteger:= currOrder;
      end;
end;

procedure TfrmStorageOut.qItemsNewRecord(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).FieldByName('mis_kolicina').AsFloat:= 1;
end;

procedure TfrmStorageOut.sbtnFindProductClick(Sender: TObject);
begin
  popFindProduct.PopUp(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

function TfrmStorageOut.doFindProduct(const sql_clause: String): Boolean;
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

procedure TfrmStorageOut.reopenItems;
begin
  qItems.DisableControls;
  try
    qItems.Close;
    qItems.Open;
  finally
    qItems.EnableControls;
  end;
end;

procedure TfrmStorageOut.onPageItems;
begin
  // check order state
  if(dbm.qStorageOut.State in [dsEdit, dsInsert]) then
    begin
      raise ESaveOrderException(SAVE_ORDER_ERROR);
      Exit;
    end;
  // check order(for id)
  if dbm.qStorageOut.IsEmpty then
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
  Application.ProcessMessages;
end;

procedure TfrmStorageOut.applyRecord;
var
  sql : String;
  currOrder : Integer = -1;
  appliedMsg : String;
begin
  if (dbm.qStorageOut.IsEmpty) then
    Exit;
  reopenItems;
  Screen.Cursor:= crSQLWait;
  // pripremi qGeneral
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  currOrder:= dbm.qStorageOut.FieldByName('mi_id').AsInteger;
  sql:= 'SELECT * FROM aplly_storage_out(' + IntToStr(currOrder)  + ')';
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      dbm.qStorageOut.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  end;
  //success msg
  appliedMsg:= 'Evidentirano slogova: ' + IntToStr(dbm.qGeneral.Fields[0].AsInteger);
  // set storno val
  dbm.qStorageOut.FieldByName('mi_storno').AsString:= 'Ne';
  //commit
  dbm.qStorageOut.ApplyUpdates;
  dbm.qGeneral.ApplyUpdates;
  dbm.dbt.CommitRetaining;
  Screen.Cursor:= crDefault;
  ShowMessage(appliedMsg);
end;

procedure TfrmStorageOut.doNewRec;
begin
  inherited doNewRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onNewRec(dbm.qStorageOut);
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

procedure TfrmStorageOut.doRemoveRec;
begin
  inherited doRemoveRec;
  case enbForms.ActivePageIndex of
    0: onRemoveRec(dbm.qStorageOut);
    1:begin
         if (LowerCase(dbm.qStorageOut.FieldByName('mi_storno').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         if (LowerCase(dbm.qStorageOut.FieldByName('mi_evident').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         onRemoveRec(qItems);
       end;
  end;
end;

procedure TfrmStorageOut.doSaveRec;
begin
  inherited doSaveRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onSaveRec(dbm.qStorageOut);
         Screen.Cursor:= crDefault;
       end;
    1: begin
         if (LowerCase(dbm.qStorageOut.FieldByName('mi_storno').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         if (LowerCase(dbm.qStorageOut.FieldByName('mi_evident').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         onSaveRec(qItems);
       end;
  end;
end;

procedure TfrmStorageOut.doCancelRec;
begin
  inherited doCancelRec;
  case enbForms.ActivePageIndex of
    0: onCancelRec(dbm.qStorageOut);
    1: onCancelRec(qItems);
  end;
end;

procedure TfrmStorageOut.doEditRec;
begin
  inherited doEditRec;
  case enbForms.ActivePageIndex of
    0: begin
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         onEditRec(dbm.qStorageOut);
       end;
    1: begin
         if (LowerCase(dbm.qStorageOut.FieldByName('mi_storno').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         if (LowerCase(dbm.qStorageOut.FieldByName('mi_evident').AsString) = LowerCase('Da')) then
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

procedure TfrmStorageOut.doFirstRec;
begin
  inherited doFirstRec;
  case enbForms.ActivePageIndex of
    0: onFirstRec(dbm.qStorageOut);
    1: onFirstRec(qItems);
  end;
end;

procedure TfrmStorageOut.doPriorRec;
begin
  inherited doPriorRec;
  case enbForms.ActivePageIndex of
    0: onPriorRec(dbm.qStorageOut);
    1: onPriorRec(qItems);
  end;
end;

procedure TfrmStorageOut.doNextRec;
begin
  inherited doNextRec;
  case enbForms.ActivePageIndex of
    0: onNextRec(dbm.qStorageOut);
    1: onNextRec(qItems);
  end;
end;

procedure TfrmStorageOut.doLastRec;
begin
  inherited doLastRec;
  case enbForms.ActivePageIndex of
    0: onLastRec(dbm.qStorageOut);
    1: onLastRec(qItems);
  end;
end;

procedure TfrmStorageOut.doCloseForm;
begin
  inherited doCloseForm;
  onCheckDataSets(dbm.qStorageIn);
  onCheckDataSets(qItems);
  self.Close;
  enableStorageSettings;
end;

end.

