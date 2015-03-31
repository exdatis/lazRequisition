unit urequisition;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ExtendedNotebook, DBZVDateTimePicker, Forms,
  Controls, Graphics, Dialogs, ExtCtrls, ActnList, Buttons, ComCtrls, StdCtrls,
  DbCtrls, DBGrids, utemplate, db;

type

  { TfrmRequisition }

  TfrmRequisition = class(TfrmTemplate)
    bitBtnItems: TBitBtn;
    bitBtnOrders: TBitBtn;
    dbcApplied: TDBCheckBox;
    dbcFinished: TDBCheckBox;
    dbcCanceled: TDBCheckBox;
    DBGrid1: TDBGrid;
    dblDoc: TDBLookupComboBox;
    dblSupplierStorage: TDBLookupComboBox;
    dblUserStorage: TDBLookupComboBox;
    dbmNotes: TDBMemo;
    dbOrderDate: TDBZVDateTimePicker;
    enbForms: TExtendedNotebook;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    tsItems: TTabSheet;
    tsOrders: TTabSheet;
    procedure dbcFinishedClick(Sender: TObject);
    procedure DBGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure enbFormsChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  frmRequisition: TfrmRequisition;
const
  DEFAULT_TITLE : String = 'Trebovanje robe'; //dodavati title stranice

implementation
uses
  udbm, uexdatis;
{$R *.lfm}

{ TfrmRequisition }

procedure TfrmRequisition.enbFormsChange(Sender: TObject);
var
  newTitle : String;
begin
  case enbForms.ActivePageIndex of
    0: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi trebovanja]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
    1: begin
         newTitle:= DEFAULT_TITLE + ' [' + 'Stavke trebovanja]';
         lblFormCaption.Caption:= newTitle;
         Application.ProcessMessages;
       end;
  else
    begin
      newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi trebovanja]';
      lblFormCaption.Caption:= newTitle;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TfrmRequisition.dbcFinishedClick(Sender: TObject);
begin
   ShowMessage(READ_ONLY_ERROR);
   btnCancel.SetFocus;
end;

procedure TfrmRequisition.DBGrid1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  DBGrid1.Cursor:= crHandPoint;
end;

procedure TfrmRequisition.DBGrid1TitleClick(Column: TColumn);
begin
  if not dbm.qRequisition.IsEmpty then
    dbm.qRequisition.IndexFieldNames:= Column.FieldName;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.FormShow(Sender: TObject);
var
  newTitle : String;
begin
  enbForms.ActivePageIndex:= 0;
  // set title
  newTitle:= DEFAULT_TITLE + ' [' + 'Nalozi trebovanja]';
  lblFormCaption.Caption:= newTitle;
  Application.ProcessMessages;
end;

procedure TfrmRequisition.doNewRec;
begin
  inherited doNewRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         //set focus
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         onNewRec(dbm.qRequisition);
         Screen.Cursor:= crDefault;
       end;
    1: ;
  end;
  //set focus
  dbOrderDate.SetFocus;
  dbOrderDate.SelectDate;
  onNewRec(dbm.qRequisition);
end;

procedure TfrmRequisition.doRemoveRec;
begin
  inherited doRemoveRec;
  case enbForms.ActivePageIndex of
    0: onRemoveRec(dbm.qRequisition);
    1: ;
  end;
end;

procedure TfrmRequisition.doSaveRec;
begin
  inherited doSaveRec;
  case enbForms.ActivePageIndex of
    0: begin
         Screen.Cursor:= crSQLWait;
         onSaveRec(dbm.qRequisition);
         Screen.Cursor:= crDefault;
       end;
    1: ;
  end;
end;

procedure TfrmRequisition.doCancelRec;
begin
  inherited doCancelRec;
  case enbForms.ActivePageIndex of
    0: onCancelRec(dbm.qRequisition);
    1: ;
  end;
end;

procedure TfrmRequisition.doEditRec;
begin
  inherited doEditRec;
  case enbForms.ActivePageIndex of
    0: begin
         dbOrderDate.SetFocus;
         dbOrderDate.SelectDate;
         onEditRec(dbm.qRequisition);
       end;
    1: Exit;
  end;
end;

procedure TfrmRequisition.doFirstRec;
begin
  inherited doFirstRec;
  case enbForms.ActivePageIndex of
    0: onFirstRec(dbm.qRequisition);
    1: ;
  end;
end;

procedure TfrmRequisition.doPriorRec;
begin
  inherited doPriorRec;
  case enbForms.ActivePageIndex of
    0: onPriorRec(dbm.qRequisition);
    1: ;
  end;
end;

procedure TfrmRequisition.doNextRec;
begin
  inherited doNextRec;
  case enbForms.ActivePageIndex of
    0: onNextRec(dbm.qRequisition);
    1: ;
  end;
end;

procedure TfrmRequisition.doLastRec;
begin
  inherited doLastRec;
  case enbForms.ActivePageIndex of
    0: onLastRec(dbm.qRequisition);
    1: ;
  end;
end;

procedure TfrmRequisition.doCloseForm;
begin
  inherited doCloseForm;
  onCheckDataSets(dbm.qRequisition);
  self.Close;
  enableStorageSettings;
end;

end.

