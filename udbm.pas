unit udbm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqldblib, db, pqconnection, FileUtil, blcksock,
  Dialogs;

type

  { Tdbm }

  Tdbm = class(TDataModule)
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
    procedure dbhAfterConnect(Sender: TObject);
    procedure dbhAfterDisconnect(Sender: TObject);
    procedure qTemplateBeforeOpen(DataSet: TDataSet);
  private
    { private declarations }
    procedure queryBeforePost(var dataSet : TSQLQuery; const idField, sequenceName : String);
  public
    { public declarations }
    function checkServer(const currHost, currPort : String) : Boolean;
    procedure closeCurrConnection;
    function selectDatabases : Boolean;
    function getNewKey(const sequenceName : String) : Integer;
    procedure cancelAll(var dataSet : TSQLQuery);
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

procedure Tdbm.qTemplateBeforeOpen(DataSet: TDataSet);
begin
  TSQLQuery(DataSet).Params[0].AsInteger:= getUserStorageId;
end;

procedure Tdbm.queryBeforePost(var dataSet: TSQLQuery; const idField,
  sequenceName: String);
const
  idKey : String = 'c_id';
  sequenceName : String = 'seq_customer';
var
  newId : Integer = 0; {error as default}
begin
  {if it's a new record}
  if(dataSet.FieldByName(idField).IsNull) then
    begin
      newid:= getNewKey(sequenceName); {find new key}
      {if result > 0}
      if(newId > 0) then
        dataSet.FieldByName(idField).AsInteger:= newId; {set value of id}
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

end.

