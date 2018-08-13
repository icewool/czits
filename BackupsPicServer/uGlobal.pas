unit uGlobal;

interface

uses
   SysUtils, IniFiles, uSQLHelper, uLogger;

const
  cDBUser = 'vioadmin';
  cDBPwd = 'lgm1224,./';
  cDB = 'YjItsDB';

var
  gServer: String;
  gUrlRoot: String;
  gBakPath: String;
  gUpdateTime: String;
  gLogger: TLogger;
  gSQLHelper: TSQLHelper;

implementation

procedure ProgramInit;
begin
  with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
    gServer:= ReadString('Config', 'Server', '.');
    gUrlRoot:= ReadString('Config', 'UrlRoot', '');
    gBakPath:= ReadString('Config', 'BakPath', '');
    gUpdateTime:= ReadString('Config', 'UpdateTime', '');
    Free;
  end;

  if copy(gBakPath, Length(gBakPath), 1) <> '\' then
    gBakPath:= gBakPath + '\';

  if copy(gUrlRoot, Length(gUrlRoot), 1) <> '/'then
    gUrlRoot:= gUrlRoot + '/';

  gLogger:= TLogger.Create(ExtractFilePath(ParamStr(0)) + 'LOG\BackupsPic.log');
  gSQLHelper:= TSQLHelper.Create;
  gSQLHelper.DBServer:= gServer;
  gSQLHelper.DBName:= cDB;
  gSQLHelper.DBUser:= cDBUser;
  gSQLHelper.DBPWD:= cDBPwd;
end;

procedure ProgramDestroy;
begin
  gSQLHelper.Free;
  gLogger.Free;
end;

initialization
  ProgramInit;
finalization
  ProgramDestroy;
end.
