unit uGlobal;

interface

uses
  uLogger, uSQLHelper, System.Generics.Collections, Classes;

type
  TConfig = Record
    DBServer: String;
    DBPort: Integer;
    DBUser: String;
    DBPwd: String;
    DBName: String;
    DBNamePass: string;
    QTZDB: String;
    QTZRM: String;
  end;

  THikConfig = Record
    K08SearchURL: String;
    K08SaveUrl: String;
    DFUrl: String;
    DFUser: String;
    DFPwd: String;
  End;

  TLogUploadConfig = record
    UploadUrl: string;
    LoginUrl: string;
    Username: string;
    Password: string;
    Source: string;
    TerminalIP: string;
  end;

var
  gSQLHelper: TSQLHelper;
  gLogger: TLogger;
  gConfig, gJQOraConfig: TConfig;
  gHikConfig: THikConfig;
  gUploadVio: Boolean; // 自动上传违法
  gUploadVioTime: String;
  gJZF: Boolean; // 技战法
  gKKALARM: Boolean; // 套牌车二次识别
  gZBDX: Boolean; // 值班短信
  gZBDXTime: String;
  gHpzlList: TDictionary<string, String>;
  gHpzl: TDictionary<String, String>;
  gActionParam: TDictionary<String, String>;
  gK08Hpzl: TDictionary<String, TStrings>;
  gK08Clpp: TDictionary<String, String>;
  gK08Csys: TDictionary<String, String>;
  gDevKDBH: TDictionary<String, String>;
  gDevID: TDictionary<String, String>;
  gHeartbeatUrl: String;
  gHeartbeatInterval: Integer;
  gHikAlarmVehicleUrl: string; // Hik接收黑名单的URL
  gLogUploadConfig: TLogUploadConfig; // 日志上报URL
  gAppIP: String;
  gToken: String;
  // gDeviceMonitorSJHM: string;
  gDeviceMonitorSJHM: TDictionary<String, String>;

implementation

end.
