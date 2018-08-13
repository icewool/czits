unit uGlobal;

interface

uses
  uLogger, uSQLHelper, System.Generics.Collections, Classes;

type
  TDBConfig = Record
    DBServer: String;
    DBPort: Integer;
    DBUser: String;
    DBPwd: String;
    DBName: String;
  end;

  TFtpConfig = Record
    Host: String;
    Port: Integer;
    User: String;
    Password: String;
    Passived: Boolean;
    Path: String;
  end;

var
  gSQLHelper: TSQLHelper;
  gLogger: TLogger;
  gDBConfig: TDBConfig;
  gFtpConfig: TFtpConfig;
  gHeartbeatUrl: String;
  gHeartbeatInterval: Integer;
  gTempPath: String;
  gRootUrl: String;

implementation

end.
