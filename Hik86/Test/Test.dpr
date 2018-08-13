program Test;

uses
  Vcl.Forms,
  uGlobal in 'D:\its\JZF\Common\uGlobal.pas',
  uLogger in 'D:\its\JZF\Common\uLogger.pas',
  uSQLHelper in 'D:\its\JZF\Common\uSQLHelper.pas',
  uPassRec in 'D:\its\JZF\jzf\uPassRec.pas',
  uCommon in 'D:\its\JZF\Common\uCommon.pas',
  uEntity in 'D:\its\JZF\Common\uEntity.pas',
  uDFS in 'D:\its\JZF\Common\uDFS.pas',
  uJsonUtils in 'D:\its\JZF\Common\uJsonUtils.pas',
  uRequestItf in 'D:\its\JZF\Common\uRequestItf.pas',
  uLogUploadThread in 'D:\its\JZF\uLogUploadThread.pas',
  Unit1 in 'Unit1.pas' {ItsHik86Service};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TItsHik86Service, ItsHik86Service);
  Application.Run;
end.
