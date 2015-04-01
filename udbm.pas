unit udbm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqldblib, db, pqconnection, FileUtil, blcksock,
  Dialogs, Forms, Controls;

type

  { Tdbm }

  Tdbm = class(TDataModule)
    dsDocStorageIn: TDataSource;
    dsRequisition: TDataSource;
    dsTemplate: TDataSource;
    dsProducts: TDataSource;
    dsStorages: TDataSource;
    dbh: TPQConnection;
    dbLib: TSQLDBLibraryLoader;
    qDocStorageIndoc_id: TLongintField;
    qDocStorageIndoc_naziv: TStringField;
    qGeneral: TSQLQuery;
    dbt: TSQLTransaction;
    qProductsag_naziv: TStringField;
    qProductsart_id: TLongintField;
    qProductsart_naziv: TStringField;
    qProductsart_sifra: TStringField;
    qProductsjm_naziv: TStringField;
    qProductsjm_oznaka: TStringField;
    qRequisitiont_datum: TDateField;
    qRequisitiont_doc: TLongintField;
    qRequisitiont_id: TLongintField;
    qRequisitiont_magacin: TLongintField;
    qRequisitiont_notes: TMemoField;
    qRequisitiont_operater: TLongintField;
    qRequisitiont_out: TLongintField;
    qRequisitiont_potvrda: TStringField;
    qRequisitiont_storniran: TStringField;
    qRequisitiont_time: TStringField;
    qRequisitiont_uradjen: TStringField;
    qStorages: TSQLQuery;
    qStoragesm_id: TLongintField;
    qStoragesm_naziv: TStringField;
    qProducts: TSQLQuery;
    qTemplate: TSQLQuery;
    qTemplateart_naziv: TStringField;
    qTemplateart_sifra: TStringField;
    qTemplatejm_naziv: TStringField;
    qTemplatejm_oznaka: TStringField;
    qTemplatetmp_artikal: TLongintField;
    qTemplatetmp_id: TLongintField;
    qTemplatetmp_kol: TBCDField;
    qTemplatetmp_magacin: TLongintField;
    qRequisition: TSQLQuery;
    qDocStorageIn: TSQLQuery;
    docName: TStringField;
    supplierStorage: TStringField;
    userStorage: TStringField;
    procedure dbhAfterConnect(Sender: TObject);
    procedure dbhAfterDisconnect(Sender: TObject);
    procedure qRequisitionAfterDelete(DataSet: TDataSet);
    procedure qRequisitionAfterPost(DataSet: TDataSet);
    procedure qRequisitionBeforeOpen(DataSet: TDataSet);
    procedure qRequisitionBeforePost(DataSet: TDataSet);
    procedure qRequisitionNewRecord(DataSet: TDataSet);
    procedure qTemplateAfterDelete(DataSet: TDataSet);
    procedure qTemplateAfterPost(DataSet: TDataSet);
    procedure qTemplateBeforeOpen(DataSet: TDataSet);
    procedure qTemplateBeforePost(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
    function checkServer(const currHost, currPort : String) : Boolean;
    procedure closeCurrConnection;
    function selectDatabases : Boolean;
    function getNewKey(const sequenceName : String) : Integer;
    procedure cancelAll(var dataSet : TSQLQuery);
    procedure postChanges(var dataSet : TSQLQuery);
  end;

var
  dbm: Tdbm;
const
  DB_PORT : String = '5432';

implementation
uses
  uexdatis;
{$R *.lfm}

{ Tdbm }

procedure Tdbm.dbhAfterConnect(Sender: TObject);
begin
  //nevazi za posgres
  if dbh.DatabaseName = 'postgres' then Exit;

  mainAfterConnect; //exdatis common
end;

procedure Tdbm.dbhAfterDisconnect(Sender: TObject);
begin
  //nevazi za postgres
  if dbh.DatabaseName = 'postgres' then Exit;

  mainAfterDisconnect;  //exdatis common
end;

procedure Tdbm.qRequisitionAfterDelete(DataSet: TDataSet);
begin
  postChanges(TSQLQuery(DataSet));
end;

procedure Tdbm.qRequisitionAfterPost(DataSet: TDataSet);
begin
  postChanges(TSQLQuery(DataSet));
end;

procedure Tdbm.qRequisitionBeforeOpen(DataSet: TDataSet);
var
  currUserStorage : Integer = -1;
begin
  currUserStorage:= getUserStorageId; //param
  TSQLQuery(DataSet).Params[0].AsInteger:= currUserStorage;
end;

procedure Tdbm.qRequisitionBeforePost(DataSet: TDataSet);
const
  ID_KEY : String = 't_id';
  SEQUENCE_NAME : String = 'trebovanje_t_id_seq';
  TIME_FIELD : String = 't_time'; //obavezan
var
  currHost, currPort : String;
  new_id : Integer = -1;
  sqlSelectTime : String = 'select current_time';
begin
  { check server before}
  currHost:= getCurrentHost;
  currPort:= getCurrentPort;
  //ShowMessage(currHost);
  //ShowMessage(currPort);
  if not checkServer(getCurrentHost, getCurrentPort) then
      cancelAll(TSQLQuery(DataSet))
    else
      begin
        if TSQLQuery(DataSet).FieldByName(ID_KEY).IsNull then
          begin
            new_id:= getNewKey(SEQUENCE_NAME);
            TSQLQuery(DataSet).FieldByName(ID_KEY).AsInteger:= new_id;
          end;
        //vreme unosa
        qGeneral.Close;
        qGeneral.SQL.Clear;
        qGeneral.SQL.Text:= sqlSelectTime;
        try
          qGeneral.Open;
        except
          TSQLQuery(DataSet).FieldByName(TIME_FIELD).AsString:= DateTimeToStr(Now);
          Exit;
        end;
        //else time to str
        TSQLQuery(DataSet).FieldByName(TIME_FIELD).AsString:= DateTimeToStr(qGeneral.Fields[0].AsDateTime);
      end;
end;

procedure Tdbm.qRequisitionNewRecord(DataSet: TDataSet);
var
  sql_select_date : String;
  currOperater : Integer = -1;
  currUserStorage : Integer = -1;
  currSupplierStorage : Integer = -1;
begin
  qRequisition.FieldByName('t_potvrda').AsString:= 'Ne';
  qRequisition.FieldByName('t_storniran').AsString:= 'Ne';
  qRequisition.FieldByName('t_uradjen').AsString:= 'Ne';
  qRequisition.FieldByName('t_doc').AsInteger:= 1;
  //operater
  currOperater:= getUserId;
  qRequisition.FieldByName('t_operater').AsInteger:= currOperater;
  // korisnikov, dobavljacev magacin
  currUserStorage:= getUserStorageId;
  currSupplierStorage:= getSupplierStorageId;

  qRequisition.FieldByName('t_magacin').AsInteger:= currUserStorage;
  qRequisition.FieldByName('t_out').AsInteger:= currSupplierStorage;
  //select date from db server
  sql_select_date:= 'select current_date';
  qGeneral.Close;
  qGeneral.SQL.Clear;
  qGeneral.SQL.Text:= sql_select_date;
  try
    qGeneral.Open;
  except
    on e : Exception do
    begin
      qRequisition.FieldByName('t_datum').AsDateTime:= Now;
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  // inace procitaj rezultat
  qRequisition.FieldByName('t_datum').AsDateTime:= qGeneral.Fields[0].AsDateTime;
end;

procedure Tdbm.qTemplateAfterDelete(DataSet: TDataSet);
begin
  postChanges(TSQLQuery(DataSet));
end;

procedure Tdbm.qTemplateAfterPost(DataSet: TDataSet);
begin
  postChanges(TSQLQuery(DataSet));
end;

procedure Tdbm.qTemplateBeforeOpen(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).Params[0].AsInteger:= getUserStorageId;
end;

procedure Tdbm.qTemplateBeforePost(DataSet: TDataSet);
const
  ID_KEY : String = 'tmp_id';
  SEQUENCE_NAME : String = 'tmptr_tmp_id_seq';
  FK_STORAGE_FIELD : String = 'tmp_magacin';
var
  currHost, currPort : String;
  new_id : Integer = -1;
  currStorage : Integer = -1;
begin
  { check server before}
  currHost:= getCurrentHost;
  currPort:= getCurrentPort;
  //ShowMessage(currHost);
  //ShowMessage(currPort);
  if not checkServer(getCurrentHost, getCurrentPort) then
      cancelAll(TSQLQuery(DataSet))
    else
      begin
        if TSQLQuery(DataSet).FieldByName(ID_KEY).IsNull then
          begin
            new_id:= getNewKey(SEQUENCE_NAME);
            TSQLQuery(DataSet).FieldByName(ID_KEY).AsInteger:= new_id;
          end;
        //magacin kao spoljni kljuc
        currStorage:= getUserStorageId;
        TSQLQuery(DataSet).FieldByName(FK_STORAGE_FIELD).AsInteger:= currStorage;
      end;
end;

function Tdbm.checkServer(const currHost, currPort : String) : Boolean;
var
  pingOk : Boolean = False;
  errorMsg : String;
  svr : TTCPBlockSocket;
  test : Integer = -1;   //greska kao inicijalna vrednost nula(o) je ok
begin
  svr := TTCPBlockSocket.Create;
  svr.ConnectionTimeout:= 1; //jedan sekund, nemoze manje
  try
    svr.Connect(currHost,currPort);
    //svr.Listen;   //verovatno nije potrebno
    test:= svr.LastError;
  finally
    Svr.CloseSocket;
    svr.Free;
  end;
  if test <> 0 then
    begin
      errorMsg:= 'Mrežna konekcija u prekidu!' + #13#10;
      errorMsg:= errorMsg + 'Pozovite Dejana ili Bobana:' + #13#10;
      errorMsg:= errorMsg + 'Ratkov Dejan: 062-804-8441' + #13#10;
      errorMsg:= errorMsg + 'Stefanovski Boban: 062-804-8326' + #13#10;
      ShowMessage(errorMsg);
      result:= pingOk; // false
      Exit;
    end;
  //else ok
  pingOk:= True;
  result:= pingOk;
end;

procedure Tdbm.closeCurrConnection;
begin
   if dbm.dbh.Connected then
     begin
       dbm.dbh.CloseDataSets;
       dbm.dbh.CloseTransactions;
       dbm.dbh.Close(True); //force close dbh
     end;
end;

function Tdbm.selectDatabases: Boolean;
var
  sql : String;
begin
  sql:= 'SELECT datname FROM pg_database WHERE datistemplate = false AND ';
  sql:= sql + 'datname NOT IN (' + QuotedStr('postgres') + ')';
  qGeneral.Close;
  qGeneral.SQL.Clear;
  qGeneral.SQL.Text:= sql;
  try
    qGeneral.Open;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      result:= False;
      Exit;
    end;
  end;
  result:= True; // sada moze da se procita rezultat
end;

function Tdbm.getNewKey(const sequenceName: String): Integer;
var
  sql : String;
begin
  {sql text}
  sql:= 'Select nextval(' + QuotedStr(sequenceName) + ')';
  try
    qGeneral.Close;
    qGeneral.SQL.Clear;
    qGeneral.SQL.Text:= sql;
    qGeneral.Open;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      result:= 0;
      Exit;
    end;
  end;
  //else return result
  result:= qGeneral.Fields[0].AsInteger;
end;

procedure Tdbm.cancelAll(var dataSet: TSQLQuery);
begin
  dataSet.CancelUpdates;
  dbt.RollbackRetaining;
end;

procedure Tdbm.postChanges(var dataSet: TSQLQuery);
var
  currPosition : Integer = -1;
  idKey : String;
begin
  Screen.Cursor:= crSQLWait;
  {save position}
  idKey:= dataSet.Fields[0].FieldName;
  currPosition:= dataSet.FieldByName(idKey).AsInteger;
  {commit}
  try
    dataSet.ApplyUpdates;
    dbt.CommitRetaining;
  except
    on e : Exception do
    begin
      dataSet.CancelUpdates;
      dbt.RollbackRetaining;
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  //refresh
  try
    dataSet.DisableControls;
    dataSet.Refresh;
    dataSet.Locate(idKey, currPosition, []);
  finally
    dataSet.EnableControls;
    Screen.Cursor:= crDefault;
  end;
end;


end.

