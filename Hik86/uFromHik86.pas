unit uFromHik86;

interface

uses
  Classes, SysUtils, Generics.Collections, Variants, IniFiles, DateUtils, IdHttp,
  FireDAC.Comp.Client, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Pool,
  FireDAC.Stan.Def,  FireDAC.DApt, FireDAC.Stan.Async, FireDAC.Stan.Expr, IdUri,
  uTypes, uBaseThread, IOUtils, uGlobal, uQTZHelper, Types;

type
  TFromHik86 = class(TBaseThread)
  private
    FConfig: TConfig;
    FConn: TFDConnection;
    FQuery: TFDQuery;
    function GetConn: TFDConnection;
    function QueryPassFromOracle: boolean;
    function GetMaxXH: string;
    procedure SetMaxXH(const Value: string);
    function SendData(stream: TStream): boolean;
    function GetPassList: TList<TPass>;
    function GetStream(list: TList<TPass>): TStringStream;
    procedure GetAlarm(list: TList<TPass>);
  protected
    procedure Prepare; override;
    procedure Perform; override;
    procedure AfterTerminate; override;
  public
    constructor Create(config: TConfig); overload;
    destructor Destroy; override;
  end;

implementation

{ TFromHik86 }

procedure TFromHik86.AfterTerminate;
begin
  inherited;
  logger.Info(FConfig.Name + ' Stoped');
end;

procedure TFromHik86.Prepare;
begin
  inherited;
  logger.Info(FConfig.Name + ' Start');
end;

constructor TFromHik86.Create(config: TConfig);
begin
  FConfig := config;
  FConn := GetConn;
  inherited Create(false);
  self.FSleep := 1000;
  if FConfig.IsVio then
    self.FSleep := 60000;
end;

destructor TFromHik86.Destroy;
begin
  FQuery.Free;
  FConn.Free;
  inherited;
end;

procedure TFromHik86.Perform;
var
  stream: TStream;
  list: TList<TPass>;
begin
  inherited;
  if QueryPassFromOracle then
  begin
    logger.Info('RecordCount: ' + FQuery.RecordCount.ToString());
    if FQuery.RecordCount > 0 then
    begin
      list := GetPassList;
      stream := GetStream(list);
      SendData(stream);
      stream.Free;
      if FConfig.AlarmUrl <> '' then
      begin
        GetAlarm(list);
      end;
      list.Free;
    end;
  end;
end;

function TFromHik86.GetConn: TFDConnection;
begin
  result := TFDConnection.Create(nil);
  result.Params.Add('DriverID=Ora');
  result.Params.Add
    (Format('Database=(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = %s)(PORT = %s)))'
    + '(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = %s)))',
    [FConfig.Host, FConfig.Port, FConfig.SID]));
  result.Params.Add(Format('User_Name=%s', [FConfig.Usr]));
  result.Params.Add(Format('Password=%s', [FConfig.Pwd]));
  result.Params.Add('CharacterSet=UTF8'); // ·ñÔòÖÐÎÄÂÒÂë
  result.LoginPrompt := false;
  result.FetchOptions.Mode := FireDAC.Stan.Option.fmAll;
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := result;
  FQuery.SQL.Add('SELECT * FROM (');
  if FConfig.IsVio then
  begin
    FQuery.SQL.Add(' SELECT CLXXBH,KKBH,JGSK,CDBH,HPHM,HPZL,HPYS,CSYS,CLSD,QJTP,QJTP1,QJTP2,WFXW ');
    FQuery.SQL.Add(' FROM V_WFXX ');
    FQuery.SQL.Add(' WHERE CLXXBH>:MaxXH and JGSK>SYSDATE-15 ');
  end
  else begin
    FQuery.SQL.Add(' SELECT CLXXBH,KKBH,JGSK,CDBH,HPHM,HPZL,HPYS,CSYS,CLSD,QJTP,QJTP1,QJTP2,''0'' as WFXW ');
    FQuery.SQL.Add(' FROM V_GCXX ');
    FQuery.SQL.Add(' WHERE CLXXBH>:MaxXH and JGSK>SYSDATE-0.1 ');
  end;
  FQuery.SQL.Add(' ORDER BY CLXXBH ) ');
  FQuery.SQL.Add(' WHERE ROWNUM<=2000 ');
  FQuery.SQL.Add(' ORDER BY CLXXBH DESC');
end;

function TFromHik86.GetMaxXH: string;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  result := ini.ReadString(FConfig.Name, 'MaxXH', '0');
  ini.Free;
end;

procedure TFromHik86.SetMaxXH(const Value: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  ini.WriteString(FConfig.Name, 'MaxXH', Value);
  ini.Free;
end;

function TFromHik86.QueryPassFromOracle: boolean;
begin
  result := True;
  FQuery.Close;
  FQuery.Params.ParamByName('MaxXH').Value := GetMaxXH;
  try
    FConn.Open;
    FQuery.Open;
  except
    on e: exception do
    begin
      result := false;
      logger.Error('QueryPassFromOracle: ' + e.Message + #13 + FQuery.SQL.Text);
    end;
  end;
  if FQuery.RecordCount > 0 then
  begin
    SetMaxXH(FQuery.FieldByName('CLXXBH').AsString);
  end;
end;

function TFromHik86.GetPassList: TList<TPass>;
var
  pass: TPass;
begin
  result := TList<TPass>.Create;
  try
    with FQuery do
    begin
      while not Eof do
      begin
        pass.GCXH := FieldByName('CLXXBH').AsString;
        pass.KDBH := FieldByName('KKBH').AsString;
        pass.GCSJ := FieldByName('JGSK').AsString;
        pass.CDBH := FieldByName('CDBH').AsString;
        pass.HPHM := FieldByName('HPHM').AsString;
        pass.HPZL := FieldByName('HPZL').AsString;
        pass.HPYS := FieldByName('HPYS').AsString;
        pass.CSYS := FieldByName('CSYS').AsString;
        pass.CLSD := FieldByName('CLSD').AsString;
        pass.TP1 := FieldByName('QJTP').AsString;
        pass.TP2 := FieldByName('QJTP1').AsString;
        pass.TP3 := FieldByName('QJTP2').AsString;
        pass.WFXW := FieldByName('WFXW').AsString;
        result.Add(pass);

        Next;
      end;
      Close;
    end;
  except
    on e: exception do
    begin
      logger.Error('TFromHik86.GetPassList' + e.Message);
    end;
  end;
end;

function TFromHik86.GetStream(list: TList<TPass>): TStringStream;
var
  pass: TPass;
begin
  result := TStringStream.Create;
  for pass in list do
  begin
    result.WriteString(pass.GCXH);
    result.WriteString(#9 + pass.kdbh);
    result.WriteString(#9 + pass.gcsj);
    result.WriteString(#9 + pass.cdbh);
    result.WriteString(#9 + pass.HPHM);
    result.WriteString(#9 + pass.HPZL);
    result.WriteString(#9 + pass.hpys);
    result.WriteString(#9 + pass.CSYS);
    result.WriteString(#9 + pass.clsd);
    result.WriteString(#9 + pass.tp1);
    result.WriteString(#9 + pass.tp2);
    result.WriteString(#9 + pass.tp3);
    result.WriteString(#9 + pass.WFXW);
    result.WriteString(#13#10);
  end;
end;

function TFromHik86.SendData(stream: TStream): boolean;
var
  http: TIdHttp;
begin
  result := true;
  http := TIdHttp.Create(nil);
  try
    stream.Position := 0;
    http.Post(FConfig.BdrUrl, stream);
  except
    on e: exception do
    begin
      logger.Error('[TFromHik86.SendData]' + e.Message + FConfig.BdrUrl);
      result := false;
    end;
  end;
  http.Free;
end;

procedure TFromHik86.GetAlarm(list: TList<TPass>);
  function IsValid(HPHM, HPZL: string): boolean;
  var
    s: string;
  begin
    s := '';//TQTZHelper.GetVehInfo(HPHM, HPZL);
    result := not s.Contains('"ZT":"A"');
  end;
  function IsYunJing(kdbh: string): boolean;
  begin
    result := IMEIDic.ContainsKey(kdbh);
  end;
  procedure HttpPost(alarmList: TList<TPass>);
  var
    data: TStringList;
    http: TIdHttp;
    pass: TPass;
    first: boolean;
    s: string;
  begin
    http := TIdHttp.Create(nil);
    data := TStringList.Create;
    first := true;
    s := FConfig.ALarmUrl +  '?data=[';
    for pass in alarmList do
    begin
      if not first then
        s := s + ',';
      s := s + '{"jybh":"' + pass.kdbh
        + '","hphm":"' + pass.hphm
        + '","hpzl":"' + pass.hpzl
        + '","csys":"' + pass.csys
        + '","yjlx":"' + pass.WFXW + '"}';
      first := false;
    end;
    s := s + ']';
    s := IdUri.TIdURI.URLEncode(s);
    try
      s := http.Post(s, data);
      logger.Info('[TFromHik86.GetAlarm.HttpPost]' + s);
    except
      on e: exception do
      begin
        logger.Error('[TFromHik86.GetAlarm.HttpPost]' + e.Message);
      end;
    end;
    data.Free;
    http.Free;
  end;
  function GetIMEI(kdbh: string): string;
  begin
    result := IMEIDic[kdbh];
  end;
var
  pass, p: TPass;
  alarmList: TList<TPass>;
  alarm: TAlarm;
begin
  alarmList := TList<TPass>.Create;
  for pass in list do
  begin
    if IsYunJing(pass.kdbh) and AlarmDic.ContainsKey(pass.HPHM) then
    begin
      alarm := AlarmDic[pass.HPHM];
      if alarm.ZT and IsValid(pass.HPHM, pass.HPZL) then
      begin
        p := pass;
        p.WFXW := alarm.BKLX;
        p.kdbh := GetIMEI(p.kdbh);
        alarmList.Add(p);
        logger.Info('[TFromHik86.GetAlarm]:' + p.HPHM);
      end
      else if alarm.ZT then
      begin
        alarm.ZT := false;
        AlarmDic[pass.HPHM] := alarm;
      end;
    end;
  end;
  if alarmList.Count > 0 then
  begin
    HttpPost(alarmList);
  end;
  alarmList.Free;
end;

end.
