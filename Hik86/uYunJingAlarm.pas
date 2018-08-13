unit uYunJingAlarm;

interface

uses
  System.SysUtils, System.Classes, IniFiles, uLogger, SyncObjs, IOUtils,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, IdHttp, IdUri, Types, Generics.Collections,
  uHik86Sender, uGlobal, uTypes, NetEncoding;

type
  TYunJingPass = record
    HPHM, HPYS, IMEI, Longitude, Latitude: string;
  end;

  TYunJingThread = class(TThread)
  private
    FPass: TYunJingPass;
    procedure GetAlarm;
  protected
    procedure Execute; override;
  public
    constructor Create(pass: TYunJingPass); overload;
  end;

  TYunJingAlarm = class
  private
    IdHTTPServerIn: TIdHTTPServer;
    procedure IdHTTPServerInCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  YunJingAlarm: TYunJingAlarm;
  ALarmUrl: string;

implementation

constructor TYunJingAlarm.Create;
var
  ini: TIniFile;
  port: integer;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  AlarmUrl := ini.ReadString('YunJingAlarm', 'AlarmUrl', '');
  port := ini.ReadInteger('YunJingAlarm', 'PORT', 18009);
  ini.Free;

  IdHTTPServerIn := TIdHTTPServer.Create(nil);
  IdHTTPServerIn.Bindings.Clear;
  IdHTTPServerIn.DefaultPort := port;
  IdHTTPServerIn.OnCommandGet := self.IdHTTPServerInCommandGet;
  try
    IdHTTPServerIn.Active := True;
    logger.logging('YunJingAlarm start', 2);
  except
    on e: Exception do
    begin
      logger.logging(e.Message, 4);
    end;
  end;
end;

procedure TYunJingAlarm.IdHTTPServerInCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  pass: TYunJingPass;
begin
  try
    pass.HPHM := ARequestInfo.Params.Values['HPHM'];
    pass.HPHM := TNetEncoding.URL.Decode(pass.HPHM);
    pass.HPYS := ARequestInfo.Params.Values['HPYS'];
    pass.IMEI := ARequestInfo.Params.Values['IMEI'];
    pass.Longitude := ARequestInfo.Params.Values['Longitude'];
    pass.Latitude := ARequestInfo.Params.Values['Latitude'];
    if pass.HPHM <> '' then
      TYunJingThread.Create(pass);
    AResponseInfo.ContentText := 'OK';
  except
    on e: Exception do
    begin
      logger.Error(e.Message);
    end;
  end;
end;

destructor TYunJingAlarm.Destroy;
begin
  idHttpServerIn.Active := false;
  idHttpServerIn.Free;
  logger.Info('YunJingAlarm stoped');
end;

{ TYunJingThread }

constructor TYunJingThread.Create(pass: TYunJingPass);
begin
  self.FreeOnTerminate := true;
  FPass := pass;
  inherited Create(false);
end;

procedure TYunJingThread.Execute;
begin
  inherited;
  GetAlarm;
end;

procedure TYunJingThread.GetAlarm;
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
  procedure HttpPost(pass: TYunJingPass; bklx: string);
  var
    data: TStringList;
    http: TIdHttp;
    first: boolean;
    s: string;
  begin
    http := TIdHttp.Create(nil);
    data := TStringList.Create;
    first := true;
    s := ALarmUrl +  '?data=[{"jybh":"' + pass.IMEI
      + '","hphm":"' + pass.hphm
      + '","hpzl":"' + '02'
      + '","csys":"' + pass.hpys
      + '","yjlx":"' + bklx + '"}]';
    s := IdUri.TIdURI.URLEncode(s);
    try
      s := http.Post(s, data);
      logger.Debug('[TYunJingThread.GetAlarm.HttpPost]' + s);
    except
      on e: exception do
      begin
        logger.Error('[TYunJingThread.GetAlarm.HttpPost]' + e.Message);
      end;
    end;
    data.Free;
    http.Free;
  end;
var
  alarm: TAlarm;
begin
  if IsYunJing(FPass.IMEI) and AlarmDic.ContainsKey(FPass.HPHM) then
  begin
    alarm := AlarmDic[FPass.HPHM];
    if alarm.ZT and IsValid(FPass.HPHM, '02') then
    begin
      HttpPost(FPass, alarm.BKLX);
      logger.Info('[YunJingAlarm]:' + FPass.HPHM);
    end
    else if alarm.ZT then
    begin
      alarm.ZT := false;
      AlarmDic[FPass.HPHM] := alarm;
    end;
  end;
end;

end.
