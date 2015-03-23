program lazRequisition;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, umain, udbm, uexdatis, uapppwd, uopendatasets, utemplate
  { you can add units after this };

{$R *.res}

begin
  Application.Title:='ExDatis';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(Tdbm, dbm);
  Application.CreateForm(TdlgAppPwd, dlgAppPwd);
  Application.CreateForm(TdlgOpenDataSets, dlgOpenDataSets);
  Application.CreateForm(TfrmTemplate, frmTemplate);
  Application.Run;
end.

