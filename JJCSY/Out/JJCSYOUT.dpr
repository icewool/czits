program JJCSYOUT;

uses
  Vcl.SvcMgr,
  uSvcMain in 'uSvcMain.pas' {JJCSYSvc: TService},
  uBaseThread in 'Task\uBaseThread.pas',
  uOutThread in 'Task\uOutThread.pas',
  uTaskManager in 'Task\uTaskManager.pas',
  uCommon in 'Common\uCommon.pas',
  uGlobal in 'Common\uGlobal.pas',
  uLogger in 'Common\uLogger.pas',
  uTypes in 'Common\uTypes.pas';

{$R *.RES}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TJJCSYSvc, JJCSYSvc);
  Application.Run;
end.
