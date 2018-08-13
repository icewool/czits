unit uCommon;

interface

uses
  SysUtils, IOUtils, Generics.Collections, IniFiles, DB, Classes,
  uGlobal, uLogger, uSQLHelper;

procedure Initialize;
procedure Finalizat;

implementation

procedure SQLError(const SQL, Description: string);
begin
  logger.Error(Description + #13#10 + SQL);
end;

procedure Initialize;
var
  appPath, logPath: string;
  ini: TIniFile;
  host, db, user, pwd: string;
begin
  appPath := TPath.GetDirectoryName(ParamStr(0));
  logPath := TPath.Combine(appPath, 'log');
  if not TDirectory.Exists(logPath) then
    TDirectory.CreateDirectory(logPath);
  logPath := TPath.Combine(logPath, 'JJCSYIN.log');
  logger := TLogger.Create(logPath);
  logger.MaxBackupIndex := 99;
  logger.Info('Application Initialize');

  ini:= TIniFile.Create(TPath.Combine(appPath, 'Config.ini'));
  host:= ini.ReadString('DB', 'server', '');
  db:= ini.ReadString('DB', 'dbname', 'yjitsdb');
  user:= ini.ReadString('DB', 'user', 'vioadmin');
  pwd:= ini.ReadString('DB', 'pwd', 'lgm1224,./');
  sqlhelper := TSQLHelper.Create(host, db, user, pwd);
  sqlhelper.OnError := SqlError;
  logger.Level := ini.ReadInteger('sys', 'LogLevel', 0);
  gFilePath := ini.ReadString('sys', 'FilePath', '');
  gIntervalSecond := ini.ReadInteger('sys', 'IntervalSecond', 1);
  ini.Free;
end;

procedure Finalizat;
begin
  sqlHelper.Free;
  logger.Info('Application Finalizat');
  logger.Free;
end;

end.

