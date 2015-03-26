unit udefrequisition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, utemplate;

type

  { TfrmDefRequisition }

  TfrmDefRequisition = class(TfrmTemplate)
  private
    { private declarations }
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
  frmDefRequisition: TfrmDefRequisition;

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TfrmDefRequisition }

procedure TfrmDefRequisition.doNewRec;
begin
  inherited doNewRec;
end;

procedure TfrmDefRequisition.doRemoveRec;
begin
  inherited doRemoveRec;
end;

procedure TfrmDefRequisition.doSaveRec;
begin
  inherited doSaveRec;
end;

procedure TfrmDefRequisition.doCancelRec;
begin
  inherited doCancelRec;
end;

procedure TfrmDefRequisition.doEditRec;
begin
  inherited doEditRec;
end;

procedure TfrmDefRequisition.doFirstRec;
begin
  inherited doFirstRec;
end;

procedure TfrmDefRequisition.doPriorRec;
begin
  inherited doPriorRec;
end;

procedure TfrmDefRequisition.doNextRec;
begin
  inherited doNextRec;
end;

procedure TfrmDefRequisition.doLastRec;
begin
  inherited doLastRec;
end;

procedure TfrmDefRequisition.doCloseForm;
begin
  inherited doCloseForm;
end;

end.

