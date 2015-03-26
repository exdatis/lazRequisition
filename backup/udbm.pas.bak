unit udbm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqldblib, db, pqconnection, FileUtil, blcksock,
  Dialogs;

type

  { Tdbm }

  Tdbm = class(TDataModule)
    dsTemplate: TDataSource;
    dsProducts: TDataSource;
    dsStorages: TDataSource;
    dbh: TPQConnection;
    dbLib: TSQLDBLibraryLoader;
    qGeneral: TSQLQuery;
    dbt: TSQLTransaction;
    qProductsag_naziv: TStringField;
    qProductsart_id: TLongintField;
    qProductsart_naziv: TStringField;
    qProductsart_sifra: TStringField;
    qProductsjm_naziv: TStringField;
    qProductsjm_oznaka: TStringField;
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
    procedure dbhAfterConnect(Sender: TObject);
    procedure dbhAfterDisconnect(Sender: TObject);
    procedure qTemplateAfterDelete(DataSet: TDataSet);
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
    procedure queryBeforePost(var dataSet : TSQLQuery; const idField, sequenceName : String);
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

procedure Tdbm.qTemplateAfterDelete(DataSet: TDataSet);
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
begin
  { check server before}
  if not checkServer(getCurrentHost, getCurrentPort) then
    cancelAll(TSQLQuery(DataSet))
    else
      begin
        queryBeforePost(TSQLQuery(DataSet), ID_KEY, SEQUENCE_NAME );
        postChanges(TSQLQuery(DataSet));
      end;
end;

procedure Tdbm.queryBeforePost(var dataSet: TSQLQuery; const idField,
  sequenceName: String);
var
  newId : Integer = 0; {error as default}
begin
  {if it's a new record}
  if(dataSet.FieldByName(idField).IsNull) then
    begin
      newId:= getNewKey(sequenceName); {find new key}
      {if result > 0}
      if(newId > 0) then
        dataSet.FieldByName(idField).AsInteger:= newId; {set value of id}
    end
  else
    cancelAll(dataSet);
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
  currPosition : Integer;
  idKey : String;
begin
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
  end;
end;


end.

