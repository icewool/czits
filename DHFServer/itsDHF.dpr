program itsDHF;

uses
  Vcl.SvcMgr,
  uSvcMain in 'uSvcMain.pas' {ITSDHFSvc: TService},
  MyImage in 'Task\MyImage.pas',
  uBaseThread in 'Task\uBaseThread.pas',
  uDJThread in 'Task\uDJThread.pas',
  UInterface in 'Task\UInterface.pas',
  uKKThread in 'Task\uKKThread.pas',
  uPassCounter in 'Task\uPassCounter.pas',
  uTaskManager in 'Task\uTaskManager.pas',
  uVio1344Thread in 'Task\uVio1344Thread.pas',
  MessageDigest_5 in 'Common\MessageDigest_5.pas',
  uCommon in 'Common\uCommon.pas',
  uGlobal in 'Common\uGlobal.pas',
  uImageOps in 'Common\uImageOps.pas',
  uLogger in 'Common\uLogger.pas',
  uPassList in 'Common\uPassList.pas',
  uSQLHelper in 'Common\uSQLHelper.pas',
  uTypes in 'Common\uTypes.pas',
  uIdChinaPassThread in 'Task\uIdChinaPassThread.pas',
  uIdChinaVioThread in 'Task\uIdChinaVioThread.pas',
  uHoleService in 'Task\uHoleService.pas',
  uDaoFengSender in 'Task\uDaoFengSender.pas',
  uHikDaoFeng in 'Task\uHikDaoFeng.pas',
  uHikJcbk in 'Task\uHikJcbk.pas',
  uQTZHelper in 'Common\uQTZHelper.pas',
  uHik86 in 'Task\uHik86.pas',
  uFromHik86Task in 'Task\uFromHik86Task.pas',
  uPGThread in 'Task\uPGThread.pas';

{$R *.RES}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TITSDHFSvc, ITSDHFSvc);
  Application.Run;
end.
