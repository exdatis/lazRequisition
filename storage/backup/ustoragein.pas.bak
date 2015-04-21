unit ustoragein;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ExtendedNotebook, DBZVDateTimePicker, Forms,
  Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ActnList, Buttons, ComCtrls,
  DbCtrls, DBGrids, Menus, utemplate, sqldb, db;

type

  { TfrmStorageIn }

  TfrmStorageIn = class(TfrmTemplate)
    acFProductByName: TAction;
    acFProductByCode: TAction;
    bitBtnItems: TBitBtn;
    bitBtnOrders: TBitBtn;
    btnGenAll: TButton;
    btnGetItems: TButton;
    btnNotThisProduct: TButton;
    btnThisProduct: TButton;
    cmbSearchArg: TComboBox;
    dbgItems: TDBGrid;
    dbgProductsFound: TDBGrid;
    dbMeasure: TDBEdit;
    dbProduct: TDBEdit;
    dbQuantity: TDBEdit;
    dsFindProduct: TDataSource;
    dsItems: TDataSource;
    dbcApplied: TDBCheckBox;
    dbcCanceled: TDBCheckBox;
    dbgOrder: TDBGrid;
    dblDoc: TDBLookupComboBox;
    dblSupplierStorage: TDBLookupComboBox;
    dblUserStorage: TDBLookupComboBox;
    dbmNotes: TDBMemo;
    dbOrderDate: TDBZVDateTimePicker;
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
    qItemsmus_artikal: TLongintField;
    qItemsmus_id: TLongintField;
    qItemsmus_kolicina: TBCDField;
    qItemsmus_veza: TLongintField;
    sbtnFindProduct: TSpeedButton;
    tsItems: TTabSheet;
    tsOrder: TTabSheet;
    procedure acFProductByCodeExecute(Sender: TObject);
    procedure acFProductByNameExecute(Sender: TObject);
    procedure bitBtnItemsClick(Sender: TObject);
    procedure bitBtnOrdersClick(Sender: TObject);
    procedure btnGenAllClick(Sender: TObject);
    procedure btnNotThisProductClick(Sender: TObject);
    procedure btnThisProductClick(Sender: TObject);
    procedure cmbSearchArgChange(Sender: TObject);
    procedure dbcAppliedChange(Sender: TObject);
    procedure dbcCanceledChange(Sender: TObject);
    procedure dbgItemsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgItemsTitleClick(Column: TColumn);
    procedure dbgOrderMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgOrderTitleClick(Column: TColumn);
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
    procedure genInput;
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

procedure TfrmStorageIn.btnNotThisProductClick(Sender: TObject);
begin
  panelProductDlg.Visible:= False;
  dbProduct.SetFocus;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.btnThisProductClick(Sender: TObject);
begin
  qItems.FieldByName('mus_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
  qItems.FieldByName('art_naziv').AsString:= qFindProduct.FieldByName('art_naziv').AsString;
  qItems.FieldByName('jm_naziv').AsString:= qFindProduct.FieldByName('jm_naziv').AsString;
  panelProductDlg.Visible:= False;
  dbQuantity.SetFocus;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.cmbSearchArgChange(Sender: TObject);
begin
  //obrisi tekst i dodeli fokus polju za pretragu
  edtSearchProduct.Clear;
  edtSearchProduct.SetFocus;
end;

procedure TfrmStorageIn.dbcAppliedChange(Sender: TObject);
const
  Applied_error : String = 'Kliknite storno za brisanje evidencije.';
begin
  if (dbm.qStorageIn.FieldByName('mu_evident').AsString = 'Ne') then
    begin
      ShowMessage(Applied_error);
      btnCancel.Click;
    end
  else
    applyRecord;
end;

procedure TfrmStorageIn.dbcCanceledChange(Sender: TObject);
var
  sql : String;
  currOrder : Integer = -1;
  appliedMsg : String;
begin
  if (dbm.qStorageIn.IsEmpty) then
    begin
      btnCancel.Click;
      Exit;
    end;
  if (dbm.qStorageIn.FieldByName('mu_storno').AsString = 'Ne') then
    Exit;

  if(dbm.qStorageIn.FieldByName('mu_evident').AsString = 'Ne') then
    if (dbm.qStorageIn.FieldByName('mu_storno').AsString = 'Da') then
      begin
        btnCancel.Click;
        Exit;
      end;

  Screen.Cursor:= crSQLWait;
  // pripremi qGeneral
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  currOrder:= dbm.qStorageIn.FieldByName('mu_id').AsInteger;
  // napravi proceduru jer ovde treba select upit
  sql:= 'SELECT * FROM drop_storage_in(' + IntToStr(currOrder) + ')';
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      dbm.qStorageIn.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  end;
  //success msg
  appliedMsg:= 'Nalog je storniran.';
  dbm.qStorageIn.FieldByName('mu_evident').AsString := 'Ne';
  //commit
  dbm.qStorageIn.ApplyUpdates;
  dbm.qGeneral.ApplyUpdates;
  dbm.dbt.CommitRetaining;
  Screen.Cursor:= crDefault;
  ShowMessage(appliedMsg);
end;

procedure TfrmStorageIn.dbgItemsMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  dbgItems.Cursor:= crHandPoint;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.dbgItemsTitleClick(Column: TColumn);
begin
  if not qItems.IsEmpty then
    qItems.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.acFProductByNameExecute(Sender: TObject);
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
          qItems.FieldByName('mus_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
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

procedure TfrmStorageIn.bitBtnItemsClick(Sender: TObject);
begin
  onPageItems;
end;

procedure TfrmStorageIn.bitBtnOrdersClick(Sender: TObject);
begin
  //set active page
  enbForms.ActivePageIndex:= 0;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.acFProductByCodeExecute(Sender: TObject);
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
          qItems.FieldByName('mus_artikal').AsInteger:= qFindProduct.Fields[0].AsInteger;
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

procedure TfrmStorageIn.dbgOrderTitleClick(Column: TColumn);
begin
  if not dbm.qStorageIn.IsEmpty then
    dbm.qStorageIn.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.dbgProductsFoundKeyPress(Sender: TObject; var Key: char
  );
begin
  if Key = #32 then
    btnThisProduct.Click; //space
end;

procedure TfrmStorageIn.dbProductKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
    acFProductByName.Execute;
end;

procedure TfrmStorageIn.edtSearchProductKeyUp(Sender: TObject; var Key: Word;
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

procedure TfrmStorageIn.enbFormsChange(Sender: TObject);
var
  newTitle : String;
begin
  case enbForms.ActivePageIndex of
    0: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi prijema]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
    1: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Stavke prijema]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
  else
    begin
      newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi prijema]';
      lblFormCaption.Caption:= newTitle;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TfrmStorageIn.FormCreate(Sender: TObject);
begin
  sql_find_product:= 'SELECT art_id, art_sifra, art_naziv, jm_naziv, ag_naziv ' +
                      'FROM  vproduct ';
end;

procedure TfrmStorageIn.FormShow(Sender: TObject);
var
  newTitle : String;
begin
  enbForms.ActivePageIndex:= 0;
  // set title
  newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi prijema]';
  lblFormCaption.Caption:= newTitle;
  Application.ProcessMessages;
end;

procedure TfrmStorageIn.qItemsAfterDelete(DataSet: TDataSet);
begin
  dbm.postChanges(TSQLQuery(DataSet));
end;

procedure TfrmStorageIn.qItemsAfterPost(DataSet: TDataSet);
begin
  dbm.postChanges(TSQLQuery(DataSet));
end;

procedure TfrmStorageIn.qItemsBeforeDelete(DataSet: TDataSet);
begin
  if (LowerCase(dbm.qStorageIn.FieldByName('mu_storno').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
  if (LowerCase(dbm.qStorageIn.FieldByName('mu_evident').AsString) = LowerCase('Da')) then
    begin
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;
end;

procedure TfrmStorageIn.qItemsBeforeEdit(DataSet: TDataSet);
begin
  if (LowerCase(dbm.qStorageIn.FieldByName('mu_storno').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  if (LowerCase(dbm.qStorageIn.FieldByName('mu_evident').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      //cancel all
      qItems.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
end;

procedure TfrmStorageIn.qItemsBeforeOpen(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).Params[0].AsInteger:= dbm.qStorageIn.FieldByName('mu_id').AsInteger;
end;

procedure TfrmStorageIn.qItemsBeforePost(DataSet: TDataSet);
const
  ID_KEY : String = 'mus_id';
  SEQUENCE_NAME : String = 'mu_stavke_mus_id_seq';
  FK_ORDER_FIELD : String = 'mus_veza';
var
  currHost, currPort : String;
  new_id : Integer = -1;
  currOrder : Integer = -1;
begin
  { check server before}
  currHost:= getCurrentHost;
  currPort:= getCurrentPort;
  if (LowerCase(dbm.qStorageIn.FieldByName('mu_storno').AsString) = LowerCase('Da')) then
    begin
      btnCancel.Click;
      ShowMessage(APPLIED_DOC_ERROR);
      Exit;
    end;

  if (LowerCase(dbm.qStorageIn.FieldByName('mu_evident').AsString) = LowerCase('Da')) then
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
        currOrder:= dbm.qStorageIn.FieldByName('mu_id').AsInteger;
        TSQLQuery(DataSet).FieldByName(FK_ORDER_FIELD).AsInteger:= currOrder;
      end;
end;

procedure TfrmStorageIn.qItemsNewRecord(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).FieldByName('mus_kolicina').AsFloat:= 1;
end;

procedure TfrmStorageIn.sbtnFindProductClick(Sender: TObject);
begin
  popFindProduct.PopUp(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

function TfrmStorageIn.doFindProduct(const sql_clause: String): Boolean;
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

procedure TfrmStorageIn.reopenItems;
begin
  qItems.DisableControls;
  try
    qItems.Close;
    qItems.Open;
  finally
    qItems.EnableControls;
  end;
end;

procedure TfrmStorageIn.onPageItems;
begin
  // check order state
  if(dbm.qStorageIn.State in [dsEdit, dsInsert]) then
    begin
      raise ESaveOrderException(SAVE_ORDER_ERROR);
      Exit;
    end;
  // check order(for id)
  if dbm.qStorageIn.IsEmpty then
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

procedure TfrmStorageIn.genInput;
const
  EXISTENT_REC : String = 'Prijemnica po ovom osnovu vec postoji.';
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
  // testiraj dali postoji kreirana prijemnica
  // na osnovu ovog broja predatnice
  // mozda moze i locate
  if dbm.qStorageIn.Locate('mu_osnov', orderAsString, []) then
    begin
      ShowMessage(EXISTENT_REC);
      Exit;
    end;

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

procedure TfrmStorageIn.applyRecord;
var
  sql : String;
  currOrder : Integer = -1;
  appliedMsg : String;
begin
  if (dbm.qStorageIn.IsEmpty) then
    Exit;
  reopenItems;
  Screen.Cursor:= crSQLWait;
  // pripremi qGeneral
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  currOrder:= dbm.qStorageIn.FieldByName('mu_id').AsInteger;
  sql:= 'SELECT * FROM aplly_storage_in(' + IntToStr(currOrder)  + ')';
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      dbm.qStorageIn.CancelUpdates;
      dbm.dbt.RollbackRetaining;
      Exit;
    end;
  end;
  //success msg
  appliedMsg:= 'Evidentirano slogova: ' + IntToStr(dbm.qGeneral.Fields[0].AsInteger);
  // set storno val
  dbm.qStorageIn.FieldByName('mu_storno').AsString:= 'Ne';
  //commit
  dbm.qStorageIn.ApplyUpdates;
  dbm.qGeneral.ApplyUpdates;
  dbm.dbt.CommitRetaining;
  Screen.Cursor:= crDefault;
  ShowMessage(appliedMsg);
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
         Screen.Cursor:= crSQLWait;
         //set focus
         dbProduct.SetFocus;
         onNewRec(qItems);
         Screen.Cursor:= crDefault;
       end;
  end;
end;

procedure TfrmStorageIn.doRemoveRec;
begin
  inherited doRemoveRec;
  case enbForms.ActivePageIndex of
    0: onRemoveRec(dbm.qStorageIn);
    1:begin
         if (LowerCase(dbm.qStorageIn.FieldByName('mu_storno').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         if (LowerCase(dbm.qStorageIn.FieldByName('mu_evident').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;
         onRemoveRec(qItems);
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
         if (LowerCase(dbm.qStorageIn.FieldByName('mu_storno').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         if (LowerCase(dbm.qStorageIn.FieldByName('mu_evident').AsString) = LowerCase('Da')) then
           begin
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         onSaveRec(qItems);
       end;
  end;
end;

procedure TfrmStorageIn.doCancelRec;
begin
  inherited doCancelRec;
  case enbForms.ActivePageIndex of
    0: onCancelRec(dbm.qStorageIn);
    1: onCancelRec(qItems);
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
         if (LowerCase(dbm.qStorageIn.FieldByName('mu_storno').AsString) = LowerCase('Da')) then
           begin
             btnCancel.Click;
             ShowMessage(APPLIED_DOC_ERROR);
             Exit;
           end;

         if (LowerCase(dbm.qStorageIn.FieldByName('mu_evident').AsString) = LowerCase('Da')) then
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

procedure TfrmStorageIn.doFirstRec;
begin
  inherited doFirstRec;
  case enbForms.ActivePageIndex of
    0: onFirstRec(dbm.qStorageIn);
    1: onFirstRec(qItems);
  end;
end;

procedure TfrmStorageIn.doPriorRec;
begin
  inherited doPriorRec;
  case enbForms.ActivePageIndex of
    0: onPriorRec(dbm.qStorageIn);
    1: onPriorRec(qItems);
  end;
end;

procedure TfrmStorageIn.doNextRec;
begin
  inherited doNextRec;
  case enbForms.ActivePageIndex of
    0: onNextRec(dbm.qStorageIn);
    1: onNextRec(qItems);
  end;
end;

procedure TfrmStorageIn.doLastRec;
begin
  inherited doLastRec;
  case enbForms.ActivePageIndex of
    0: onLastRec(dbm.qStorageIn);
    1: onLastRec(qItems);
  end;
end;

procedure TfrmStorageIn.doCloseForm;
begin
  inherited doCloseForm;
  onCheckDataSets(dbm.qStorageIn);
  onCheckDataSets(qItems);
  self.Close;
  enableStorageSettings;
end;

end.

