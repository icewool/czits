program Project3;

uses
  Vcl.Forms,
  Unit3 in 'Unit3.pas' {Form3},
  uRmService in '..\rm\uRmService.pas',
  uJKDefine in '..\rm\impl\uJKDefine.pas',
  uRmInf in '..\rm\impl\uRmInf.pas',
  uRmWeb in '..\rm\impl\uRmWeb.pas',
  uTmri in '..\rm\impl\uTmri.pas',
  uTrans in '..\rm\impl\uTrans.pas',
  uXmlAndJSON in '..\rm\impl\uXmlAndJSON.pas',
  RmOutAccessInf in '..\rm\intf\RmOutAccessInf.pas',
  RmOutAccessWeb in '..\rm\intf\RmOutAccessWeb.pas',
  TmriOutAccess in '..\rm\intf\TmriOutAccess.pas',
  TmriOutNewAccess in '..\rm\intf\TmriOutNewAccess.pas',
  Trans1 in '..\rm\intf\Trans1.pas',
  MessageDigest_5 in '..\MessageDigest_5.pas',
  qjson in '..\qjson.pas',
  qrbtree in '..\qrbtree.pas',
  QString in '..\QString.pas',
  uCommon in '..\uCommon.pas',
  uDBO in '..\uDBO.pas',
  uDBService in '..\uDBService.pas',
  uDecodeHikResult in '..\uDecodeHikResult.pas',
  uEntity in '..\uEntity.pas',
  uGlobal in '..\uGlobal.pas',
  uHik in '..\uHik.pas',
  uHikLY in '..\uHikLY.pas',
  uLogger in '..\uLogger.pas',
  uSMS in '..\uSMS.pas',
  uSolr in '..\uSolr.pas',
  uSpecialItf in '..\uSpecialItf.pas',
  uSQLHelper in '..\uSQLHelper.pas',
  uTokenManager in '..\uTokenManager.pas',
  uUploadVio in '..\uUploadVio.pas',
  uWSManager in '..\uWSManager.pas',
  uAnalysisExtra in '..\hik\uAnalysisExtra.pas',
  uDataAnalysis in '..\hik\uDataAnalysis.pas',
  uDataStatistics in '..\hik\uDataStatistics.pas',
  uHikHBase in '..\hik\uHikHBase.pas',
  uMoreLikeThisHBase in '..\hik\uMoreLikeThisHBase.pas',
  uPolice in '..\hik\uPolice.pas',
  uProfile in '..\hik\uProfile.pas',
  uTrafficForecast in '..\hik\uTrafficForecast.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
