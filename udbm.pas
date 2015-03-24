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
  public
    { public declarations }
    function checkServer(const currHost, currPort : String) : Boolean;
    procedure closeCurrConnection;
    function selectDatabases : Boolean;
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

end.

