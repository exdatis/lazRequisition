unit ustock;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, EditBtn, Buttons, DBGrids, Grids;

type

  { TfrmStock }

  TfrmStock = class(TForm)
    btnRunQuery: TButton;
    btnClose: TButton;
    dbgReport: TDBGrid;
    dsReport: TDataSource;
    dateMax: TDateEdit;
    Label1: TLabel;
    lblFormCaption: TLabel;
    Panel1: TPanel;
    qReportag_naziv: TStringField;
    qReportart_id: TLongintField;
    qReportart_naziv: TStringField;
    qReportart_sifra: TStringField;
    qReportjm_naziv: TStringField;
    qReportnegative: TBooleanField;
    qReportsum: TBCDField;
    sBtnPrint: TSpeedButton;
    qReport: TSQLQuery;
    procedure btnCloseClick(Sender: TObject);
    procedure btnRunQueryClick(Sender: TObject);
    procedure dbgReportMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure dbgReportTitleClick(Column: TColumn);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure qReportCalcFields(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
    procedure runReportQuery;
  end;

var
  frmStock: TfrmStock;

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TfrmStock }

procedure TfrmStock.btnCloseClick(Sender: TObject);
begin
  self.Close;
end;

procedure TfrmStock.btnRunQueryClick(Sender: TObject);
begin
  runReportQuery;
end;

procedure TfrmStock.dbgReportMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  dbgReport.Cursor:= crHandPoint;
end;

procedure TfrmStock.dbgReportTitleClick(Column: TColumn);
begin
  if not qReport.IsEmpty then
    qReport.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmStock.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
  self:= nil
end;

procedure TfrmStock.FormShow(Sender: TObject);
begin
  //set date
  dateMax.Date:= Now;
end;

procedure TfrmStock.qReportCalcFields(DataSet: TDataSet);
begin
  if(qReport.FieldByName('sum').AsFloat < 0) then
    qReport.FieldByName('negative').AsBoolean:= True
  else
    qReport.FieldByName('negative').AsBoolean:= False;
end;

procedure TfrmStock.runReportQuery;
var
  currStorage : Integer = 0;
begin
  Screen.Cursor:= crSQLWait;
  //find storage
  currStorage:= getUserStorageId;
  qReport.DisableControls;
  qReport.Close;
  //set params
  qReport.Params[0].AsDate:= dateMax.Date;
  qReport.Params[1].AsInteger:= currStorage;
  //open query
  try
    qReport.Open;
  except
    on e : Exception do
    begin
      Screen.Cursor:= crDefault;
      ShowMessage(e.Message);
      qReport.EnableControls;
      Exit;
    end;
  end;
  //set cursor, focus
  qReport.EnableControls;
  Screen.Cursor:= crDefault;
  dbgReport.SetFocus;
  Application.ProcessMessages;
end;

end.

