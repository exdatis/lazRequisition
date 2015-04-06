unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, BCPanel, ueled, DividerBevel,
  Forms, Controls, Graphics, Dialogs, Menus, ComCtrls, ExtCtrls, ActnList,
  StdCtrls, IniFiles, strutils;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    aclMain: TActionList;
    acDefaultRequisition: TAction;
    acRequisition: TAction;
    acStorageIn: TAction;
    btnGetDb: TButton;
    btnConnect: TButton;
    btnSaveDbIni: TButton;
    btnSaveStorageIni: TButton;
    cmbDb: TComboBox;
    cmbUserStorage: TComboBox;
    cmbSupplierStorage: TComboBox;
    doQuitApp: TAction;
    edtPwd: TEdit;
    edtUser: TEdit;
    edtHost: TEdit;
    formPanel: TBCPanel;
    DividerBevel1: TDividerBevel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblConnectionState: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    ledConnection: TuELED;
    procedure acDefaultRequisitionExecute(Sender: TObject);
    procedure acRequisitionExecute(Sender: TObject);
    procedure acStorageInExecute(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnGetDbClick(Sender: TObject);
    procedure btnSaveDbIniClick(Sender: TObject);
    procedure btnSaveStorageIniClick(Sender: TObject);
    procedure cmbSupplierStorageChange(Sender: TObject);
    procedure cmbUserStorageChange(Sender: TObject);
    procedure doQuitAppExecute(Sender: TObject);
    procedure edtHostChange(Sender: TObject);
    procedure edtPwdChange(Sender: TObject);
    procedure edtUserChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure formPanelResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    {Morar: Omoguci cuvanje Db.ini file-a}
    procedure enableToSaveIni;
    {Morar: Onemoguci cuvanje Db.ini file-a}
    procedure disableToSaveIni;
    procedure readDbIni;
    procedure writeDbIni;
    function tryPgConnection : Boolean;
    function tryNewConnection : Boolean;
    function checkAppUser(const thisUser, thisPwd : String) : Boolean;
    procedure fillStorages;
    procedure setStorages;
    procedure clearOldForms;
    procedure disableStorages;
  public
    { public declarations }
    {Morar: ID korisnika}
    userId : Integer;
    supplierStorageId : Integer;
    userStorageId : Integer;
    {Morar: const isConnected True/False}
    isConnected : Boolean;
    procedure enableStorages;
  end;

var
  frmMain: TfrmMain;
const
  xorMagic : String = 'exdatis013';
  DEFAULT_DB : String = 'postgres';
  STORAGE_INI : String = 'storage.cfg';
  NO_CONNECTION_ERROR : String = 'Nema konekcije sa bazom podataka.';
implementation
uses
  udbm, uapppwd, uopendatasets, udefrequisition, urequisition, ustoragein;
{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.formPanelResize(Sender: TObject);
begin

  //Application.ProcessMessages;
  //formPanel.Repaint;
  {*
   * ovo je jedina potrebna funkcija za lepo uvecavanje
   * ekrana
  }
  formPanel.UpdateControl;  // to je to! radi odlicno
  Application.ProcessMessages;
  //formPanel.Refresh;
  //Application.ProcessMessages;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  {read ini file}
  readDbIni;
  userId:= 0; // nema korisnika
  supplierStorageId:= 0;
  userStorageId:= 0;
end;

procedure TfrmMain.enableToSaveIni;
begin
  {omoguci cuvanje podataka u ini file-u}
  btnSaveDbIni.Enabled:= True;
end;

procedure TfrmMain.disableToSaveIni;
begin
  {onemoguci cuvanje podataka u ini file-u}
  btnSaveDbIni.Enabled:= False;
end;

procedure TfrmMain.readDbIni;
var
  iniName : String = 'db.ini';
  iniFile : String;
  cnf : TIniFile;
  thisHost, thisUser, thisPassword : String;
  realPwd : String;
begin
  thisHost:= '';
  thisUser:= '';
  thisPassword:= '';
  realPwd:= '';
  {$ifdef LINUX}
    iniFile:= GetUserDir + 'dbBcp/' + iniName;
  {$else}
    iniFile:= 'C:\dbBcp\' + iniName;
  {$endif}
  if not FileExistsUTF8(iniFile) then Exit;
  // else read ini
  try
    cnf:= TIniFile.Create(iniFile);
    thisHost:= cnf.ReadString('db', 'host', '');
    thisUser:= cnf.ReadString('db', 'user', '');
    thisPassword:= cnf.ReadString('db', 'pwd', '');
    realPwd:= XorDecode(xorMagic, thisPassword);
  finally
    edtHost.Text:= thisHost;
    edtUser.Text:= thisUser;
    edtPwd.Text:= realPwd;
    cnf.Free;
  end;
end;

procedure TfrmMain.writeDbIni;
var
  iniName : String = 'db.ini';
  iniFile : String;
  cnf : TIniFile;
  thisHost, thisUser, thisPassword : String;
  realPwd : String;
  successMsg :String = 'Podešavanja su sačuvana.';
begin
  thisHost:= edtHost.Text;
  thisUser:= edtUser.Text;
  thisPassword:= '';
  realPwd:= edtPwd.Text;
  {$ifdef LINUX}
    iniFile:= GetUserDir + 'dbBcp/' + iniName;
  {$else}
    iniFile:= 'C:\dbBcp\' + iniName;
  {$endif}
  // write
  try
    cnf:= TIniFile.Create(iniFile);
    cnf.WriteString('db', 'host', thisHost);
    cnf.WriteString('db', 'user', thisUser);
    thisPassword:= XorEncode(xorMagic, realPwd);
    cnf.WriteString('db', 'pwd', thisPassword);
    cnf.Free;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  ShowMessage(successMsg);
end;

function TfrmMain.tryPgConnection: Boolean;
begin
  dbm.closeCurrConnection;
  //set params
  dbm.dbh.UserName:= edtUser.Text;
  dbm.dbh.Password:= edtPwd.Text;
  dbm.dbh.HostName:= edtHost.Text;
  dbm.dbh.DatabaseName:= DEFAULT_DB;
  try
    dbm.dbh.Connected:= True;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      result:= False;
      Exit;
    end;
  end;
  result:= True
end;

function TfrmMain.tryNewConnection: Boolean;
begin
  dbm.closeCurrConnection;
  //set params
  dbm.dbh.UserName:= edtUser.Text;
  dbm.dbh.Password:= edtPwd.Text;
  dbm.dbh.HostName:= edtHost.Text;
  dbm.dbh.DatabaseName:= cmbDb.Text;
  try
    dbm.dbh.Connected:= True;
    dbm.dbt.Active:= True;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      result:= False;
      Exit;
    end;
  end;
  result:= True
end;

function TfrmMain.checkAppUser(const thisUser, thisPwd : String) : Boolean;
const
  WRONG_USER : String = 'Nepoznat korisnik/lozinka.';
var
  sql : String;
  currHost : String;
begin
  {pinguj trenutno izabrani host}
  currHost:= edtHost.Text;
  if not dbm.checkServer(currHost, DB_PORT) then
    begin
      dbm.closeCurrConnection;
      result:= False;
      Exit;// izadji ako je mreza u prekidu
    end;
  sql:= 'select user_id from user_lite where user_login = ' +  QuotedStr(thisUser);
  sql:= sql + ' and user_pass = ' + QuotedStr(thisPwd);
  //run query
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      result:= False;
      Exit;
    end;
  end;
  //if empty return false
  if dbm.qGeneral.IsEmpty then
    begin
      ShowMessage(WRONG_USER);
      dbm.closeCurrConnection;
      result:= False;
      Exit;
    end;
  // if ok find new user_id
  userId:= dbm.qGeneral.Fields[0].AsInteger;
  result:= True;
end;

procedure TfrmMain.fillStorages;
const
  EMPTY_SET : String = 'Nema definisanih magacina.';
var
  sql : String;
  currHost : String;
  currStorage : String;
  storageList : TStringList;
  userStorageIndex : Integer = -1;
  supplierStorageIndex : Integer = -1;
begin
  {pinguj trenutno izabrani host}
  currHost:= edtHost.Text;
  if not dbm.checkServer(currHost, DB_PORT) then
    begin
      dbm.closeCurrConnection;
      Exit;// izadji ako je mreza u prekidu
    end;
  sql:= 'select m_naziv from magacin order by m_naziv';
  //run query
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  //ako je prazan prikazi i zatvori vezu
  if dbm.qGeneral.IsEmpty then
    begin
      ShowMessage(EMPTY_SET);
      dbm.closeCurrConnection;
      Exit;
    end;
  //fill cmb
  while not dbm.qGeneral.EOF do
    begin
      currStorage:= dbm.qGeneral.Fields[0].AsString;
      cmbSupplierStorage.Items.Append(currStorage);
      cmbUserStorage.Items.Append(currStorage);
      dbm.qGeneral.Next;
    end;
  //default storages
  if FileExistsUTF8(STORAGE_INI) then
    begin
      storageList:= TStringList.Create;
      storageList.LoadFromFile(STORAGE_INI);
      if storageList.Count < 2 then
        Exit;
      //else find storages
      supplierStorageIndex:= cmbSupplierStorage.Items.IndexOf(storageList[0]);
      userStorageIndex:= cmbUserStorage.Items.IndexOf(storageList[1]);
      cmbSupplierStorage.ItemIndex:= supplierStorageIndex;
      cmbUserStorage.ItemIndex:= userStorageIndex;
    end;
end;

procedure TfrmMain.setStorages;
var
  sql : String;
begin
  //find supplier id
  sql:= 'select m_id From magacin Where m_naziv = ' + QuotedStr(cmbSupplierStorage.Text);
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  if dbm.qGeneral.IsEmpty then Exit;
  supplierStorageId:= dbm.qGeneral.Fields[0].AsInteger;
  //find user id
  sql:= 'select m_id From magacin Where m_naziv = ' + QuotedStr(cmbUserStorage.Text);
  dbm.qGeneral.Close;
  dbm.qGeneral.SQL.Clear;
  dbm.qGeneral.SQL.Text:= sql;
  try
    dbm.qGeneral.Open;
  except
    on e : Exception do
    begin
      ShowMessage(e.Message);
      Exit;
    end;
  end;
  if dbm.qGeneral.IsEmpty then Exit;
  userStorageId:= dbm.qGeneral.Fields[0].AsInteger;
end;

procedure TfrmMain.clearOldForms;
begin
  if formPanel.ControlCount > 2 then
    begin
      TForm(formPanel.Controls[2]).Close;
      enableStorages;
    end;
end;

procedure TfrmMain.disableStorages;
begin
  if cmbSupplierStorage.Enabled then
    cmbSupplierStorage.Enabled:= False;
  if cmbUserStorage.Enabled then
    cmbUserStorage.Enabled:= False;
  if btnSaveStorageIni.Enabled then
    btnSaveStorageIni.Enabled:= False;
  if btnSaveStorageIni.Enabled then
    btnSaveStorageIni.Enabled:= False;
end;

procedure TfrmMain.enableStorages;
begin
  if not cmbSupplierStorage.Enabled then
    cmbSupplierStorage.Enabled:= True;
  if not cmbUserStorage.Enabled then
    cmbUserStorage.Enabled:= True;
  if not btnSaveStorageIni.Enabled then
    btnSaveStorageIni.Enabled:= True;
  if not btnSaveStorageIni.Enabled then
    btnSaveStorageIni.Enabled:= True;
end;

procedure TfrmMain.doQuitAppExecute(Sender: TObject);
begin
  self.Close;
  Application.Terminate;
end;

procedure TfrmMain.btnGetDbClick(Sender: TObject);
var
  currHost : String;
begin
  {pinguj trenutno izabrani host}
  currHost:= edtHost.Text;
  if not dbm.checkServer(currHost, DB_PORT) then
    begin
      dbm.closeCurrConnection;
      Exit;// izadji ako je mreza u prekidu
    end;
  {onemoguci izmene kod servera i cuvanje ini file-a}
  if btnSaveDbIni.Enabled then
    disableToSaveIni;
  // ocisti comboBox-ove
  cmbDb.Items.Clear;
  cmbSupplierStorage.Items.Clear;
  cmbUserStorage.Items.Clear;
  // pokusaj konekciju sa DEFAULT_DB
  if tryPgConnection then
    if dbm.selectDatabases then
      begin
        while not dbm.qGeneral.EOF do
          begin
            cmbDb.Items.Append(dbm.qGeneral.Fields[0].AsString);
            dbm.qGeneral.Next;
          end;
        if cmbDb.Items.Count > 0 then
          cmbDb.ItemIndex:= 0; //selektuj prvi
      end;
end;

procedure TfrmMain.btnConnectClick(Sender: TObject);
const
  SUCCESS_MSG : String = 'Uspešna prijava na sistem.';
var
  newDlg : TdlgAppPwd;
  thisUser, ThisPwd : String;
  checkThisUser : Boolean = False;
  dlgProgress :  TdlgOpenDataSets;
begin
  //najpre proveri konekciju
  if isConnected then
    begin
      clearOldForms;
      dbm.closeCurrConnection;
      cmbDb.Items.Clear;
      cmbSupplierStorage.Items.Clear;
      cmbUserStorage.Items.Clear;
      cmbSupplierStorage.Enabled:= True;
      cmbUserStorage.Enabled:= True;
      Exit;
    end;
  thisUser:= '';
  ThisPwd:= '';
  newDlg:= TdlgAppPwd.Create(nil);
  if(newDlg.ShowModal = mrOK) then
    begin
      thisUser:= newDlg.edtUser.Text;
      ThisPwd:= newDlg.edtPwd.Text;
      checkThisUser:= True;
    end;
  //free dialog
  newDlg.Free;

  if checkThisUser then
    if tryNewConnection then
      if checkAppUser(thisUser, ThisPwd) then
        begin
          fillStorages;
          setStorages;
          //success msg
          ShowMessage(SUCCESS_MSG);
          // ovde treba otvoriti dataSets
          dlgProgress:= TdlgOpenDataSets.Create(nil);
          dlgProgress.Show;
          Application.ProcessMessages;
          dlgProgress.openDataSets;
          dlgProgress.Free;
        end;
end;

procedure TfrmMain.acDefaultRequisitionExecute(Sender: TObject);
var
  newForm : TfrmDefRequisition;
begin
  {close any forms}
  clearOldForms;
  {proveri konekciju sa bazom}
  if not dbm.dbh.Connected then
    begin
      ShowMessage(NO_CONNECTION_ERROR);
      Exit;
    end;
  {show work commitment}
  Screen.Cursor:= crHourGlass;
  try
    {create new}
    newForm:= TfrmDefRequisition.Create(nil);
    {set dbGrid title images}
    //newForm.setDbGridTitleImages;
    {set parent ctrl}
    newForm.Parent:= formPanel;
    newForm.Align:= alClient;
    newForm.Show;
    // dodeli necemu fokus zbog precica
    newForm.dbgDefaultRequisition.SetFocus;
    {onemoguci izmene}
    disableStorages;
    Application.ProcessMessages;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmMain.acRequisitionExecute(Sender: TObject);
var
  newForm : TfrmRequisition;
begin
  {close any forms}
  clearOldForms;
  {proveri konekciju sa bazom}
  if not dbm.dbh.Connected then
    begin
      ShowMessage(NO_CONNECTION_ERROR);
      Exit;
    end;
  {show work commitment}
  Screen.Cursor:= crHourGlass;
  try
    {create new}
    newForm:= TfrmRequisition.Create(nil);
    {set dbGrid title images}
    //newForm.setDbGridTitleImages;
    {set parent ctrl}
    newForm.Parent:= formPanel;
    newForm.Align:= alClient;
    newForm.Show;
    // dodeli necemu fokus zbog precica
    newForm.DBGrid1.SetFocus;
    {onemoguci izmene}
    disableStorages;
    Application.ProcessMessages;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmMain.acStorageInExecute(Sender: TObject);
var
  newForm : TfrmStorageIn;
begin
  {close any forms}
  clearOldForms;
  {proveri konekciju sa bazom}
  if not dbm.dbh.Connected then
    begin
      ShowMessage(NO_CONNECTION_ERROR);
      Exit;
    end;
  {show work commitment}
  Screen.Cursor:= crHourGlass;
  try
    {create new}
    newForm:= TfrmStorageIn.Create(nil);
    {set dbGrid title images}
    //newForm.setDbGridTitleImages;
    {set parent ctrl}
    newForm.Parent:= formPanel;
    newForm.Align:= alClient;
    newForm.Show;
    // dodeli necemu fokus zbog precica
    newForm.dbgOrder.SetFocus;
    {onemoguci izmene}
    disableStorages;
    Application.ProcessMessages;
  finally
    Screen.Cursor:= crDefault;
  end;
end;

procedure TfrmMain.btnSaveDbIniClick(Sender: TObject);
begin
  writeDbIni;
  btnSaveDbIni.Enabled:= False;
end;

procedure TfrmMain.btnSaveStorageIniClick(Sender: TObject);
const
  EMPTY_SET : String = 'Nema definisnih magacina.';
  SUCCESS_MSG : String = 'Podešavanja su sačuvana.';
var
  storageList : TStringList;
begin
  if cmbSupplierStorage.Items.Count = 0 then
    begin
      ShowMessage(EMPTY_SET);
      Exit;
    end;
  storageList:= TStringList.Create;
  storageList.Append(cmbSupplierStorage.Text);
  storageList.Append(cmbUserStorage.Text);
  storageList.SaveToFile(STORAGE_INI);
  storageList.Free;
  ShowMessage(SUCCESS_MSG);
end;

procedure TfrmMain.cmbSupplierStorageChange(Sender: TObject);
begin
  // set cursor(show progress)
  Screen.Cursor:= crSQLWait;
  //set storages
  setStorages;
  //reopen datasets
  dbm.qTemplate.Close;
  dbm.qRequisition.Close;
  dbm.qStorageIn.Close;
  try
    dbm.qTemplate.Open;
    dbm.qRequisition.Open;
    dbm.qStorageIn.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      self.Close;
      Application.Terminate;
    end;
  end;
  //set cursor(default)
  Screen.Cursor:= crDefault;
end;

procedure TfrmMain.cmbUserStorageChange(Sender: TObject);
begin
  // set cursor(show progress)
  Screen.Cursor:= crSQLWait;
  //set storages
  setStorages;
  //reopen datasets
  dbm.qTemplate.Close;
  dbm.qRequisition.Close;
  dbm.qStorageIn.Close;
  try
    dbm.qTemplate.Open;
    dbm.qRequisition.Open;
    dbm.qStorageIn.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      self.Close;
      Application.Terminate;
    end;
  end;
  //set cursor(default)
  Screen.Cursor:= crDefault;
end;

procedure TfrmMain.edtHostChange(Sender: TObject);
begin
  {omoguci cuvanje podataka u ini file-u}
  if btnSaveDbIni.Enabled then
    Exit
  else
    enableToSaveIni;
end;

procedure TfrmMain.edtPwdChange(Sender: TObject);
begin
  {omoguci cuvanje podataka u ini file-u}
  if btnSaveDbIni.Enabled then
    Exit
  else
    enableToSaveIni;
end;

procedure TfrmMain.edtUserChange(Sender: TObject);
begin
  {omoguci cuvanje podataka u ini file-u}
  if btnSaveDbIni.Enabled then
    Exit
  else
    enableToSaveIni;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  isConnected:= False;
end;

end.

