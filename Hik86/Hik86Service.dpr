program Hik86Service;

uses
  Vcl.SvcMgr,
  uMain in 'uMain.pas' {ItsHik86Service: TService},
  uLogger in '..\XMF\Common\uLogger.pas',
  uGlobal in 'uGlobal.pas',
  uHik86Sender in '..\XMF\Hik86\uHik86Sender.pas',
  uHik86 in '..\XMF\Hik86\uHik86.pas',
  uTypes in '..\XMF\Common\uTypes.pas',
  uToHik86 in 'uToHik86.pas',
  uFromHik86 in 'uFromHik86.pas',
  uBaseThread in '..\DHFServer\Task\uBaseThread.pas',
  uTaskManager in 'uTaskManager.pas',
  uQTZHelper in 'uQTZHelper.pas',
  uJsonUtils in '..\ItsClient\Common\uJsonUtils.pas',
  uYunJingAlarm in 'uYunJingAlarm.pas';

{$R *.RES}

begin
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TItsHik86Service, ItsHik86Service);
  Application.Run;
end.
