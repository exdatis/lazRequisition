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
    btnGetDb: TButton;
    btnConnect: TButton;
    btnSaveDbIni: TButton;
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
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    ledConnection: TuELED;
    procedure btnGetDbClick(Sender: TObject);
    procedure btnSaveDbIniClick(Sender: TObject);
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
    function checkAppUser : Boolean;

  public
    { public declarations }
    {Morar: ID korisnika}
    userId : Integer;
    {Morar: const isConnected True/False}
    isConnected : Boolean;
  end;

var
  frmMain: TfrmMain;
const
  xorMagic : String = 'exdatis013';
  DEFAULT_DB : String = 'postgres';
implementation
uses
  udbm;
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

end;

function TfrmMain.checkAppUser: Boolean;
begin

end;

procedure TfrmMain.doQuitAppExecute(Sender: TObject);
begin
  self.Close;
  Application.Terminate;
end;

procedure TfrmMain.btnGetDbClick(Sender: TObject);
const
  DB_PORT : String = '5432';
var
  currHost : String;
begin
  {pinguj trenutno izabrani host}
  currHost:= edtHost.Text;
  if not dbm.checkServer(currHost,DB_PORT) then
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

procedure TfrmMain.btnSaveDbIniClick(Sender: TObject);
begin
  writeDbIni;
  btnSaveDbIni.Enabled:= False;
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

