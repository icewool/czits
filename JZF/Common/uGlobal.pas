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
  gUploadVio: Boolean; // �Զ��ϴ�Υ��
  gUploadVioTime: String;
  gJZF: Boolean; // ��ս��
  gKKALARM: Boolean; // ���Ƴ�����ʶ��
  gZBDX: Boolean; // ֵ�����
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
  gHikAlarmVehicleUrl: string; // Hik���պ�������URL
  gLogUploadConfig: TLogUploadConfig; // ��־�ϱ�URL
  gAppIP: String;
  gToken: String;
  // gDeviceMonitorSJHM: string;
  gDeviceMonitorSJHM: TDictionary<String, String>;

implementation

end.
