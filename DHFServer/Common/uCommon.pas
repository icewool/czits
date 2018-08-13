unit uCommon;

interface

uses
  SysUtils, IOUtils, Generics.Collections, IniFiles, DB, Classes, uQTZHelper,
  uGlobal, uLogger, uTypes, uSQLHelper, uPassList, uDaoFengSender;

procedure LoadDevice;
procedure LoadAlarm;
procedure LoadHBC;
procedure LoadMainDic;
procedure LoadVeh;
procedure LoadOpenedDevice;
procedure UpdateDeviceGXSJ(sbbh: string; gxsj: double);
procedure AddSMS(sn, sj, msg: string);
procedure SQLError(const SQL, Description: string);

procedure Initialize;
procedure Finalizat;

implementation

procedure UpdateDeviceGXSJ(sbbh: string; gxsj: double);
var
  SQL: string;
begin
  SQL := 'update s_device set gxsj=''' + datetimetostr(gxsj) +
    ''' where sbbh=''' + sbbh + '''';
  SQLHelper.ExecuteSql(SQL);

  gDicDevice[sbbh].gxsj := gxsj;
end;

procedure LoadHBC;
var
  tmp: TDictionary<string, boolean>;
begin
  tmp := TDictionary<string, boolean>.Create;
  with SQLHelper.Query('select distinct hphm+hpzl from t_hbc where bj=1') do
  begin
    while not EOF do
    begin
      tmp.Add(Fields[0].AsString, true);
      Next;
    end;
    Free;
  end;
  if gOldHBC <> nil then
    gOldHBC.Free;
  gOldHBC := gDicHBC;
  gDicHBC := tmp;
end;

procedure LoadAlarm;
var
  tmp: TDictionary<string, boolean>;
begin
  tmp := TDictionary<string, boolean>.Create;
  with SQLHelper.Query
    ('select distinct hphm+hpzl as dickey from T_KK_ALARM where zt=1') do
  begin
    while not EOF do
    begin
      tmp.Add(Fields[0].AsString, true);
      Next;
    end;
    Free;
  end;
  if gOldAlarm <> nil then
    gOldAlarm.Free;
  gOldAlarm := gDicAlarm;
  gDicAlarm := tmp;
end;

procedure LoadOpenedDevice;
var
  tmp: TDictionary<string, boolean>;
  s, sbbh: string;
  local: boolean;
begin
  tmp := TDictionary<string, boolean>.Create;
  with SQLHelper.Query
    ('select distinct sbbh,local from s_jcbk_device where closeTime is null ')
    do
  begin
    while not EOF do
    begin
      s := Fields[0].AsString;
      local := Fields[1].AsInteger = 1;
      for sbbh in s.Split([',']) do
      begin
        if tmp.ContainsKey(sbbh) then
        begin
          if local and (not tmp[sbbh]) then
            tmp[sbbh] := local;
        end
        else
          tmp.Add(sbbh, local);
      end;
      Next;
    end;
    Free;
  end;
  if gOldOpenedDevice <> nil then
    gOldOpenedDevice.Free;
  gOldOpenedDevice := gOpenedDevice;
  gOpenedDevice := tmp;
end;

procedure ClearDevice(dic: TDictionary<string, TDevice>);
var
  dev: TDevice;
begin
  for dev in dic.Values do
    dev.Free;
  dic.Clear;
end;

procedure LoadDevice;
var
  SQL: string;
  dev: TDevice;
  tmpDic: TDictionary<string, TDevice>;
begin
  tmpDic := TDictionary<string, TDevice>.Create;
  SQL := 'select * from s_device where qyzt=1';
  with SQLHelper.Query(SQL) do
  begin
    while not EOF do
    begin
      dev := TDevice.Create;
      dev.sbbh := FieldByName('SBBH').AsString;
      dev.FXBH := FieldByName('FXBH').AsString;
      dev.BABH := FieldByName('JCPTBABH').AsString;
      dev.BAFX := FieldByName('JCPTBAFX').AsString;
      dev.LKBH := FieldByName('LKBH').AsString;
      dev.LKMC := FieldByName('LKMC').AsString;
      dev.FXMC := FieldByName('FXMC').AsString;
      dev.cjjg := FieldByName('CJJG').AsString;
      dev.SBDDMC := FieldByName('SBDDMC').AsString;
      dev.SBJD := FieldByName('SBJD').AsString;
      dev.SBWD := FieldByName('SBWD').AsString;
      dev.SBIP := FieldByName('SBIP').AsString;
      dev.SBCJ := FieldByName('SBCJ').AsString;
      dev.CSLXR := FieldByName('CSLXR').AsString;
      dev.LXFS := FieldByName('LXFS').AsString;
      dev.QYSJ := FieldByName('QYSJ').AsString;
      dev.JDJG := FieldByName('JDJG').AsString;
      dev.JDBH := FieldByName('JDBH').AsString;
      dev.JDYXQ := FieldByName('JDYXQ').AsDateTime;
      dev.QYRQ := FieldByName('QYRQ').AsDateTime;
      dev.XZSD := FieldByName('XZSD').AsInteger;
      dev.DCXZSD := FieldByName('DCXZSD').AsInteger;
      dev.QSSBBH := FieldByName('QSSBBH').AsString;
      dev.SBLX := FieldByName('SBLX').AsString;
      dev.LDBH := FieldByName('LDBH').AsString;
      dev.LHY_XZQH := FieldByName('LHY_XZQH').AsString;
      dev.LHY_WFDD := FieldByName('LHY_WFDD').AsString;
      dev.LHY_SBBH := FieldByName('LHY_SBBH').AsString;
      dev.LHY_LDDM := FieldByName('LHY_LDDM').AsString;
      dev.LHY_DDMS := FieldByName('LHY_DDMS').AsString;
      dev.LHY_CJFS := FieldByName('LHY_CJFS').AsString;
      dev.LHY_JPGH := FieldByName('LHY_JPGH').AsInteger;
      dev.LHY_JPGW := FieldByName('LHY_JPGW').AsInteger;
      dev.LHY_JPGQ := FieldByName('LHY_JPGQ').AsString;
      dev.QYZT := FieldByName('QYZT').AsBoolean;
      dev.ZJZT := FieldByName('ZJZT').AsBoolean;
      dev.SCJCPT := FieldByName('SCJCPT').AsBoolean;
      dev.TPGS := FieldByName('TPGS').AsString;
      dev.WFXW := FieldByName('WFXW').AsString;
      dev.BZ := FieldByName('BZ').AsString;
      dev.gxsj := FieldByName('GXSJ').AsDateTime;
      dev.TPXZ := FieldByName('TPXZ').AsBoolean;
      dev.XYSB := FieldByName('XYSB').AsBoolean;
      dev.AQDSB := FieldByName('AQDSB').AsBoolean;
      dev.XYSB := FieldByName('XYSB').AsBoolean;
      dev.HBCZB := FieldByName('HBCZB').AsString = '1';
      dev.XXZB := FieldByName('XXZB').AsBoolean;
      dev.DCXXZB := FieldByName('DCXXZB').AsBoolean;
      dev.YSXZB := FieldByName('YSXZB').AsBoolean;
      dev.XSZB := FieldByName('XSZB').AsBoolean;
      dev.ID := FieldByName('ID').AsString;
      dev.hikJcbk := FieldByName('hikJcbk').AsBoolean;
      dev.Changed := false;
      tmpDic.Add(dev.sbbh, dev);
      Next;
    end;
    Free;
  end;
  if tmpDic.Count > 1 then
  begin
    if gOldDevice <> nil then
    begin
      ClearDevice(gOldDevice);
      gOldDevice.Free;
    end;
    gOldDevice := gDicDevice;
    gDicDevice := tmpDic;
  end;
end;

procedure LoadVeh;
var
  SQL: string;
begin
  gVehDic.Clear;
  SQL := 'select distinct hpzl,hphm from T_VIO_VEHICLE where fzjg=''' +
    FZJG + '''';
  with SQLHelper.Query(SQL) do
  begin
    while not EOF do
    begin
      gVehDic.Add(Fields[0].AsString + Fields[1].AsString, true);
      Next;
    end;
    Free;
  end;
end;

procedure LoadMainDic;
begin
  gDicHPZL.Add('01', '大型汽车');
  gDicHPZL.Add('02', '小型汽车');
  gDicHPZL.Add('03', '使馆汽车');
  gDicHPZL.Add('04', '领馆汽车');
  gDicHPZL.Add('05', '境外汽车');
  gDicHPZL.Add('06', '外籍汽车');
  gDicHPZL.Add('07', '普通摩托车');
  gDicHPZL.Add('08', '轻便摩托车');
  gDicHPZL.Add('09', '使馆摩托车');
  gDicHPZL.Add('10', '领馆摩托车');
  gDicHPZL.Add('11', '境外摩托车');
  gDicHPZL.Add('12', '外籍摩托车');
  gDicHPZL.Add('13', '低速车');
  gDicHPZL.Add('14', '拖拉机');
  gDicHPZL.Add('15', '挂车');
  gDicHPZL.Add('16', '教练汽车');
  gDicHPZL.Add('17', '教练摩托车');
  gDicHPZL.Add('18', '试验汽车');
  gDicHPZL.Add('19', '试验摩托车');
  gDicHPZL.Add('20', '临时入境汽车');
  gDicHPZL.Add('21', '临时入境摩托车');
  gDicHPZL.Add('22', '临时行驶车');
  gDicHPZL.Add('23', '警用汽车');
  gDicHPZL.Add('24', '警用摩托');
  gDicHPZL.Add('25', '原农机号牌');
  gDicHPZL.Add('26', '香港出入境车');
  gDicHPZL.Add('27', '澳门出入境车');
  gDicHPZL.Add('44', '无号牌');
  gDicHPZL.Add('99', '其它');
end;

procedure SQLError(const SQL, Description: string);
begin
  logger.Error(Description + #13#10 + SQL);
end;

procedure AddSMS(sn, sj, msg: string);
begin
  if borderDBHelper <> nil then
  begin
    logger.Info('SMS' + sj + msg);
    borderDBHelper.ExecuteSql
      ('insert into [borderdb].[dbo].[T_OUT] (sn,body,msg) values (' +
      sn.QuotedString + ',' + sj.QuotedString + ',' + msg.QuotedString + ')');
  end;
end;

procedure Initialize;
  procedure InitHoleKK(kk: string);
  var
    s: string;
    r: TArray<String>;
  begin
    holeSBBH := TDictionary<string, string>.Create;
    for s in kk.Split([';']) do
    begin
      r := s.Split([':']);
      holeSBBH.Add(r[0], r[1]);
    end;
  end;

var
  appPath, logPath: string;
  ini: TIniFile;
  host, DB, user, pwd, holeKK: string;
begin
  appPath := TPath.GetDirectoryName(ParamStr(0));
  logPath := TPath.Combine(appPath, 'log');
  if not TDirectory.Exists(logPath) then
    TDirectory.CreateDirectory(logPath);
  logPath := TPath.Combine(logPath, 'dhf.log');
  logger := TLogger.Create(logPath);
  logger.MaxBackupIndex := 99;
  logger.Info('Application Initialize');

  ini := TIniFile.Create(TPath.Combine(appPath, 'Config.ini'));
  host := ini.ReadString('DB', 'server', '');
  DB := ini.ReadString('DB', 'dbname', 'yjitsdb');
  user := ini.ReadString('DB', 'user', 'vioadmin');
  pwd := ini.ReadString('DB', 'pwd', 'lgm1224,./');
  SQLHelper := TSQLHelper.Create(host, DB, user, pwd);
  SQLHelper.OnError := SQLError;

  host := ini.ReadString('BorderDB', 'server', ''); // 10.43.235.222,1133
  if host <> '' then
  begin
    DB := ini.ReadString('BorderDB', 'dbname', 'borderdb');
    user := ini.ReadString('BorderDB', 'user', 'zasms');
    pwd := ini.ReadString('BorderDB', 'pwd', 'zasms');
    borderDBHelper := TSQLHelper.Create(host, DB, user, pwd);
    borderDBHelper.OnError := SQLError;
  end;

  solrFtp.host := ini.ReadString('solr', 'host', '');
  solrFtp.port := ini.ReadString('solr', 'port', '21');
  solrFtp.user := ini.ReadString('solr', 'user', 'solr');
  solrFtp.pwd := ini.ReadString('solr', 'pwd', 'solr');
  solrFtp.path := ini.ReadString('solr', 'path', '');

  hdpFtp.host := ini.ReadString('hdp', 'host', '');
  hdpFtp.port := ini.ReadString('hdp', 'port', '21');
  hdpFtp.user := ini.ReadString('hdp', 'user', 'root');
  hdpFtp.pwd := ini.ReadString('hdp', 'pwd', 'lgm1224,./!@#');
  hdpFtp.path := ini.ReadString('hdp', 'path', 'data');

  TQTZHelper.QTZUrl := ini.ReadString('sys', 'QTZ', '');

  DFSHost := ini.ReadString('sys', 'DFSHost', ''); // 仓库 localhost:8089
  FZJG := ini.ReadString('sys', 'fzjg', '无'); // 发证机关，用于识别假套牌
  SMSUrl := ini.ReadString('sys', 'SMSUrl', '');
  // 'http://10.46.137.83:8081/SMS/Send?token=%s&mobiles=%s&content=%s'
  kk := ini.ReadInteger('sys', 'kk', 0) = 1;
  dj := ini.ReadInteger('sys', 'dj', 0) = 1;
  idchina := ini.ReadInteger('sys', 'idchina', 0) = 1;
  logger.Level := ini.ReadInteger('sys', 'LogLevel', 0);
  gBdrUrl := ini.ReadString('sys', 'BdrUrl', ''); // http://10.43.255.8:18088/Hik86?appName=Hik86

  reload := ini.ReadInteger('sys', 'reload', 0) = 1;
  gHeartbeatUrl := ini.ReadString('sys', 'Heartbeat', '');
  if not gHeartbeatUrl.EndsWith('/') then
    gHeartbeatUrl := gHeartbeatUrl + '/';
  DCXXZP := ini.ReadString('sys', 'DCXXZP', ''); // 大车限行抓拍设备编号
  holeUrl := ini.ReadString('sys', 'holeUrl',
    'http://10.43.244.44:9080/jcbktrans/services/hole');
  holeKK := ini.ReadString('sys', 'holeKK',
    'E12073-01:445191000152500500445191B0AE;E12073-02:445191000152500500445191B0AE;E12073-03:445191000152500500445191B0AE;'
    + 'E12067-01:445191000152494800445191B0BF;E12067-02:445191000152494800445191B0BF;E12067-03:445191000152494800445191B0BF;'
    + 'E12117-01:445191000152494800445191B0BE;E12117-02:445191000152494800445191B0BE;E12117-03:445191000152494800445191B0BE');

  gHikConfig.K08SaveUrl := ini.ReadString('DaoFeng', 'SaveUrl', '');
  gHikConfig.DFUrl := ini.ReadString('DaoFeng', 'Url', '');
  gHikConfig.DFUser := ini.ReadString('DaoFeng', 'User', '');
  gHikConfig.DFPwd := ini.ReadString('DaoFeng', 'PWD', '');

  ini.Free;

  gOldDevice := nil;
  gOldHBC := nil;
  gOldAlarm := nil;
  gOldOpenedDevice := nil;

  gUnknowDevice := TDictionary<string, boolean>.Create;
  gVehDic := TDictionary<string, boolean>.Create;
  gDicHPZL := TDictionary<string, string>.Create;
  PassList := TPassList.Create;
  DaoFengSender := TDaoFengSender.Create;
  LoadDevice;
  LoadMainDic;
  LoadAlarm;
  LoadHBC;
  LoadOpenedDevice;
  // LoadVeh;
  InitHoleKK(holeKK);

  hikJcbkdPool.Current.SetMinWorkerThreads(500);
  LoadOpenedDevice;
end;

procedure Finalizat;
begin
  {PassList.Free;
  DaoFengSender.Free;
  gDicAlarm.Free;
  gDicHBC.Free;
  gOpenedDevice.Free;
  ClearDevice(gDicDevice);
  gDicDevice.Free;

  if gOldAlarm <> nil then
    gOldAlarm.Free;
  if gOldHBC <> nil then
    gOldHBC.Free;
  if gOpenedDevice <> nil then
    gOpenedDevice.Free;
  if gOldDevice <> nil then
  begin
    ClearDevice(gOldDevice);
    gOldDevice.Free;
  end;

  gDicHPZL.Free;
  SQLHelper.Free;
  gUnknowDevice.Free;
  if borderDBHelper <> nil then
    borderDBHelper.Free;   }
  logger.Info('Application Finalizat');
  logger.Free;
end;

end.
