unit uCommon;

interface

uses
  SysUtils, IOUtils, Generics.Collections, IniFiles, Classes,
  uGlobal, uLogger;

procedure Initialize;
procedure Finalizat;

implementation

procedure Initialize;
var
  appPath, logPath: string;
begin
  appPath := TPath.GetDirectoryName(ParamStr(0));
  logPath := TPath.Combine(appPath, 'log');
  if not TDirectory.Exists(logPath) then
    TDirectory.CreateDirectory(logPath);
  logPath := TPath.Combine(logPath, 'JJCSYOUT.log');
  logger := TLogger.Create(logPath);
  logger.MaxBackupIndex := 99;
  logger.Info('Application Initialize');
end;

procedure Finalizat;
begin
  logger.Info('Application Finalizat');
  logger.Free;
end;

end.

