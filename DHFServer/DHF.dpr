program DHF;

uses
  Vcl.Forms,
  Unit9 in 'Unit9.pas' {Form9},
  uLogger in 'Common\uLogger.pas',
  uSQLHelper in 'Common\uSQLHelper.pas',
  uGlobal in 'Common\uGlobal.pas',
  uCommon in 'Common\uCommon.pas',
  uTypes in 'Common\uTypes.pas',
  uBaseThread in 'Task\uBaseThread.pas',
  uTaskManager in 'Task\uTaskManager.pas',
  uDJThread in 'Task\uDJThread.pas',
  uImageOps in 'Common\uImageOps.pas',
  uPassCounter in 'Task\uPassCounter.pas',
  UInterface in 'Task\UInterface.pas',
  uKKThread in 'Task\uKKThread.pas',
  MessageDigest_5 in 'Common\MessageDigest_5.pas',
  uPassList in 'Common\uPassList.pas',
  uVio1344Thread in 'Task\uVio1344Thread.pas',
  uQTZHelper in 'Common\uQTZHelper.pas',
  Trans1 in 'Trans\Trans1.pas',
  uTrans in 'Trans\uTrans.pas',
  uDaoFengSender in 'Task\uDaoFengSender.pas',
  uHikDaoFeng in 'Task\uHikDaoFeng.pas',
  uHikJcbk in 'Task\uHikJcbk.pas',
  uHoleService in 'Task\uHoleService.pas',
  uIdChinaPassThread in 'Task\uIdChinaPassThread.pas',
  uIdChinaVioThread in 'Task\uIdChinaVioThread.pas',
  MyImage in 'Task\MyImage.pas',
  uHik86 in 'Task\uHik86.pas',
  uFromHik86Task in 'Task\uFromHik86Task.pas',
  uPGThread in 'Task\uPGThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm9, Form9);
  Application.Run;
end.
