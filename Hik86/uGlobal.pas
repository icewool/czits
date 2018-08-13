unit uGlobal;

interface

uses
  Generics.Collections, uLogger;

type
  TConfig = record
    Name, Host, Port, SID, Usr, Pwd, BdrUrl, AlarmUrl: string;
    IsVio: boolean;
  end;

  TAlarm = record
    HPHM, HPZL, BKLX: string;
    ZT: boolean;
  end;

var
  logger: TLogger;
  Hik86Url: string;
  HikKKMYDic: TDictionary<string, string>;
  IpMapDic: TDictionary<string, string>;
  AlarmDic: TDictionary<string, TAlarm>;  // TODO: GetAlarmDic
  IMEIDic: TDictionary<string, string>;

implementation

end.
