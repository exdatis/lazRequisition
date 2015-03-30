unit uexdatis;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, umain, Graphics;

var
  EMPTY_SET_ERROR : String = 'Prazan skup podataka.';
  EDIT_MOD_ERROR : String = 'Izaberite akciju, novi zapis ili izmenu';
procedure mainAfterConnect;
procedure mainAfterDisconnect;
procedure enableStorageSettings;
function getUserId : Integer;
function getSupplierStorageId : Integer;
function getUserStorageId : Integer;
function getCurrentHost : String;
function getCurrentPort : String;

implementation

procedure mainAfterConnect;
begin
  {onemoguci editovanje host-a, korisnika i lozinke(db)}
  frmMain.edtHost.Enabled:= False;
  frmMain.edtUser.Enabled:= False;
  frmMain.edtPwd.Enabled:= False;
  frmMain.btnSaveDbIni.Enabled:= False;
  frmMain.btnGetDb.Enabled:= False;
  frmMain.cmbDb.Enabled:= False;
  frmMain.btnConnect.Caption:= 'Izmena parametara';
  frmMain.btnConnect.Hint:= 'Omogući izmene';
  frmMain.isConnected:= True;
  frmMain.ledConnection.Color:= clGreen;
  frmMain.lblConnectionState.Caption:= 'Konektovan';
end;

procedure mainAfterDisconnect;
begin
  {omoguci editovanje host-a, korisnika i lozinke(db)}
  frmMain.edtHost.Enabled:= True;
  frmMain.edtUser.Enabled:= True;
  frmMain.edtPwd.Enabled:= True;
  frmMain.btnSaveDbIni.Enabled:= False;
  frmMain.btnGetDb.Enabled:= True;
  frmMain.cmbDb.Enabled:= True;
  frmMain.btnConnect.Caption:= 'Konektuj se';
  frmMain.btnConnect.Hint:= 'Uloguj se';
  frmMain.isConnected:= False;
  frmMain.ledConnection.Color:= clRed;
  frmMain.lblConnectionState.Caption:= 'Diskonektovan';
end;

procedure enableStorageSettings;
begin
  frmMain.enableStorages;
end;

function getUserId: Integer;
begin
  result:= frmMain.userId;
end;

function getSupplierStorageId: Integer;
begin
  result:= frmMain.supplierStorageId;
end;

function getUserStorageId: Integer;
begin
  result:= frmMain.userStorageId;
end;

function getCurrentHost: String;
begin
  result:= frmMain.edtHost.Text;
end;

function getCurrentPort: String;
begin
  result:= '5432'; //postgresql
end;

end.

