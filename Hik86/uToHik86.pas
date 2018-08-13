unit uToHik86;

interface

uses
  System.SysUtils, System.Classes, IniFiles, uLogger, SyncObjs, IOUtils,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, IdContext, Types, uHik86Sender, Generics.Collections, uGlobal,
  uTypes;

type
  TToHik86 = class
  private
    IdHTTPServerIn: TIdHTTPServer;
    ipList: string;
    procedure IdHTTPServerInCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function CheckIP(ip: string): boolean;
    procedure LoadHikKKMY;
    procedure LoadIPMap;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  toHik86: TToHik86;

implementation

constructor TToHik86.Create;
var
  ini: TIniFile;
  port: integer;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  ipList := ini.ReadString('sys', 'ip', '');
  Hik86Url := ini.ReadString('sys', 'Hik86Url', '');
  port := ini.ReadInteger('sys', 'PORT', 18008);
  ini.Free;

  LoadHikKKMY;
  LoadIPMap;
  IdHTTPServerIn := TIdHTTPServer.Create(nil);
  IdHTTPServerIn.Bindings.Clear;
  IdHTTPServerIn.DefaultPort := port;
  IdHTTPServerIn.OnCommandGet := self.IdHTTPServerInCommandGet;
  try
    IdHTTPServerIn.Active := True;
    logger.logging('Hik86 start', 2);
  except
    on e: Exception do
    begin
      logger.logging(e.Message, 4);
    end;
  end;
end;

procedure TToHik86.IdHTTPServerInCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  action, ip, s: string;
  b, b1: boolean;
  ss: TStringList;
  pass: TPass;
  arr: TArray<string>;
begin
  action := ARequestInfo.Document.Substring(1);
  ip := AContext.Connection.Socket.Binding.PeerIP;
  logger.logging('[' + ip + ']' + action, 2);
  b := CheckIP(ip);
  if b then
  begin
    try
      ss := TStringList.Create;
      ss.LoadFromStream(ARequestInfo.PostStream);
      logger.Info('RecordCount:' + ss.Count.ToString);
      for s in ss do
      begin
        arr := s.Split([#9]);
        if Length(arr) > 8 then
        begin
          pass.kdbh := arr[0];
          pass.gcsj := arr[1];
          pass.cdbh := arr[2];
          pass.HPHM := arr[3];
          pass.HPZL := arr[4];
          pass.hpys := arr[5];
          pass.clsd := arr[6];
          pass.FWQDZ := arr[7];
          pass.tp1 := arr[8];
          if Length(arr) > 9 then
            pass.tp2 := arr[9];
          if Length(arr) > 10 then
            pass.tp3 := arr[10];
          if Length(arr) > 11 then
            pass.WFXW := arr[11];
          b1 := false;
          for ip in IpMapDic.Keys do
          begin
            if pass.FWQDZ.Contains(ip) then
            begin
              b1 := true;
              pass.FWQDZ := pass.FWQDZ.Replace(ip, IpMapDic[ip]);
              THik86Sender.SendPass(pass);
              if pass.WFXW.Length >= 4 then
                THik86Sender.SendAlarmPass(pass);
              break;
            end;
          end;
          if not b1 then
            logger.Debug('Invalid FWQDZ: ' + pass.FWQDZ);
        end;
      end;
      ss.Free;
      logger.Info('Send OK');
      AResponseInfo.ContentText := 'OK';
    except
      on e: Exception do
      begin
        logger.Error(e.Message);
      end;
    end;
  end
  else begin
	  logger.Warn('Invalid IP Or Action!');
  end;
end;

procedure TToHik86.LoadHikKKMY;
var
  ss: TStringDynArray;
  s, key, value: string;
  i: integer;
begin
  HikKKMYDic := TDictionary<string, string>.Create;
  s := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'KKMY.ini');
  if TFile.Exists(s) then
  begin
    ss := TFile.ReadAllLines(s);
    for s in ss do
    begin
      i := s.IndexOf(#9);
      if i>0 then
      begin
        key := s.Substring(0, i);
        value := s.Substring(i + 1, 100);
        if not HikKKMYDic.ContainsKey(key) then
          HikKKMYDic.Add(key, value);
      end;
    end;
  end;
end;

procedure TToHik86.LoadIPMap;
var
  ss: TStringDynArray;
  s, key, value: string;
  i: integer;
begin
  IpMapDic := TDictionary<string, string>.Create;
  s := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'IpMap.ini');
  if TFile.Exists(s) then
  begin
    ss := TFile.ReadAllLines(s);
    for s in ss do
    begin
      i := s.IndexOf(#9);
      if i>0 then
      begin
        key := s.Substring(0, i);
        value := s.Substring(i + 1, 100);
        if not IpMapDic.ContainsKey(key) then
          IpMapDic.Add(key, value);
      end;
    end;
  end;
end;

function TToHik86.CheckIP(ip: string): boolean;
begin
  result := (ipList = '') or ipList.Contains(ip);
end;

destructor TToHik86.Destroy;
begin
  idHttpServerIn.Active := false;
  idHttpServerIn.Free;
  HikKKMYDic.Free;
  logger.Info('Hik86 stoped');
end;

end.
