program BackupsPicServer;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  uLogger in 'uLogger.pas',
  uSQLHelper in 'uSQLHelper.pas',
  uGlobal in 'uGlobal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
