program JJCSYIN;

uses
  Vcl.SvcMgr,
  uSvcMain in 'uSvcMain.pas' {itsJJCSYSvc: TService},
  uBaseThread in 'Task\uBaseThread.pas',
  uInThread in 'Task\uInThread.pas',
  uCommon in 'Common\uCommon.pas',
  uGlobal in 'Common\uGlobal.pas',
  uLogger in 'Common\uLogger.pas',
  uSQLHelper in 'Common\uSQLHelper.pas';

{$R *.RES}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TitsJJCSYSvc, itsJJCSYSvc);
  Application.Run;
end.
