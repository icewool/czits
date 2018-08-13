unit uFromHik86Task;

interface

uses
  System.SysUtils, System.Classes, IniFiles, SyncObjs, IOUtils, Generics.Collections,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer, IdHttp, IdUri,
  IdHTTPServer, IdContext, Types, uLogger, uGlobal, uTypes, UInterface, uPassList;

type
  TFromHik86Task = class
  private
    IdHTTPServerIn: TIdHTTPServer;
    ipList: string;
    oldHost, newHost, FVioPicUrl, FVioPicPath: string;
    procedure IdHTTPServerInCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function CheckIP(ip: string): boolean;
    function DownloadPic(vioList: TList<TPass>): boolean;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  FromHik86Task: TFromHik86Task;

implementation

constructor TFromHik86Task.Create;
var
  ini: TIniFile;
  port: integer;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  ipList := ini.ReadString('FromHik86', 'ip', '');
  port := ini.ReadInteger('FromHik86', 'PORT', 18009);
  oldHost := ini.ReadString('FromHik86', 'OldHost', '172.16.45.18:8088');
  newHost := ini.ReadString('FromHik86', 'NewHost', '10.43.255.8:18008');
  FVioPicUrl := ini.ReadString('FromHik86', 'VioPicUrl', '');
  FVioPicPath := ini.ReadString('FromHik86', 'VioPicPath', '');

  ini.Free;

  IdHTTPServerIn := TIdHTTPServer.Create(nil);
  IdHTTPServerIn.Bindings.Clear;
  IdHTTPServerIn.DefaultPort := port;
  IdHTTPServerIn.OnCommandGet := self.IdHTTPServerInCommandGet;
  try
    IdHTTPServerIn.Active := True;
    logger.logging('FromHik86Task start', 2);
  except
    on e: Exception do
    begin
      logger.logging(e.Message, 4);
    end;
  end;
end;

procedure TFromHik86Task.IdHTTPServerInCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  action, ip, s: string;
  ss: TStringList;
  pass: TPass;
  device: TDevice;
  arr: TArray<string>;
  vioList: TList<TPass>;
begin
  action := ARequestInfo.Document.Substring(1);
  ip := AContext.Connection.Socket.Binding.PeerIP;
  //logger.logging('[' + ip + ']' + action, 2);
  if not CheckIP(ip) then
  begin
    logger.Warn('Invalid IP Or Action!');
    exit;
  end;
  if ARequestInfo.PostStream = nil then
  begin
    logger.Warn('ARequestInfo.PostStream is null!');
    exit;
  end;
  vioList := TList<TPass>.Create;
  ss := TStringList.Create;
  try
    ss.LoadFromStream(ARequestInfo.PostStream);
    logger.Info('RecordCount:' + ss.Count.ToString);
    for s in ss do
    begin
      arr := s.Split([#9]);
      if Length(arr) >= 10 then
      begin  //CLXXBH,KKBH,JGSK,CDBH,HPHM,HPZL,HPYS,CSYS,CLSD,QJTP,QJTP1,QJTP2,WFXW
        pass.GCXH := arr[0];
        pass.kdbh := arr[1];
        pass.gcsj := arr[2];
        pass.cdbh := arr[3];
        pass.HPHM := arr[4];
        pass.HPZL := arr[5];
        pass.hpys := arr[6];
        pass.CSYS := arr[7];
        pass.clsd := arr[8];
        pass.tp1 := arr[9];
        pass.tp2 := arr[10];
        pass.tp3 := arr[11];
        pass.WFXW := '';
        if Length(arr) >= 13 then
          pass.WFXW := arr[12];
        pass.FWQDZ := '';

        pass.tp1 := pass.tp1.Replace(oldHost, newHost);
        pass.tp2 := pass.tp2.Replace(oldHost, newHost);
        pass.tp3 := pass.tp3.Replace(oldHost, newHost);
        pass.tp1 := pass.tp1 + '&ISSTREAM=1&appName=pic';
        if pass.tp2 <> '' then
          pass.tp2 := pass.tp2 + '&ISSTREAM=1&appName=pic';
        if pass.tp3 <> '' then
          pass.tp3 := pass.tp3 + '&ISSTREAM=1&appName=pic';
        pass.KKSOURCE := 'FromHIK86';
        if gDicDevice.ContainsKey(pass.kdbh) then
        begin
          device := gDicDevice[pass.kdbh];
          if (device.TPGS = '1') then   //非治安卡口
          begin

            if (Length(Trim(device.babh)) > 0) then
            begin
              Tmypint.WriteVehicleInfo(pass, device);
            end;

            // Tmypint.DoAlarm(pass);     // 暂不预警

            PassList.Add(pass);
          end;
          if (pass.WFXW.Length >= 4) and ((device.lhy_cjfs = '3') or (device.lhy_cjfs = '7')) then
            pass.WFXW := Tmypint.getSpeedtoWFXW(pass.HPZL, strtointdef(pass.clsd, 0), device.XZSD);
        end;
          if pass.WFXW = '13441' then // 黄标车
          begin
            if not gDicHBC.ContainsKey(pass.HPHM + pass.HPZL) then
            begin
              pass.WFXW := '0';
            end;
          end;

          if pass.WFXW.Length >= 4 then
          begin
            vioList.Add(pass);
          end;

        end;
      //end;
    end;
    AResponseInfo.ContentText := 'OK';
  except
    on e: Exception do
    begin
      logger.Error(e.Message);
    end;
  end;
  ss.Free;
  if vioList.Count > 0 then
  begin
    DownloadPic(vioList);
    TMypint.SaveVio1(vioList);
  end;
  vioList.Free;
end;

function TFromHik86Task.DownloadPic(vioList: TList<TPass>): boolean;
  function Download(url, localPath, fileName: string): boolean;
  var
    http: TIdHttp;
    stream: TMemoryStream;
  begin
    result := false;
    if url = '' then exit;

    http := TIdHttp.Create(nil);
    stream := TMemoryStream.Create;
    try
      http.Get(url, stream);
      stream.SaveToFile(localPath + fileName);
      result := true;
    except
      on e: exception do
      begin
        logger.Error('[TFromHik86Task.DownloadPic]' + e.Message + url);
      end;
    end;
    stream.Free;
    http.Free;
  end;
var
  i: Integer;
  pass: TPass;
  newUrl, localPath, yyyymm, dd, kdbh, tp: string;
begin
  result := true;
  for i := 0 to vioList.Count - 1 do
  begin
    pass := vioList[i];
    yyyymm := FormatDatetime('yyyymm', Now);
    dd := FormatDatetime('dd', Now);
    kdbh := pass.kdbh;
    newUrl := Format('%s/%s/%s/%s/', [FVioPicUrl, yyyymm, dd, kdbh]);
    localPath := Format('%s\%s\%s\%s\', [FVioPicPath, yyyymm, dd, kdbh]);
    if not DirectoryExists(localPath) then
      ForceDirectories(localPath);
    tp := kdbh + pass.GCXH + '_1.jpg';
    if Download(pass.tp1, localPath, tp) then
    begin
      pass.tp1 := newUrl + tp;
    end;

    tp := kdbh + pass.GCXH + '_2.jpg';
    if Download(pass.tp2, localPath, tp) then
    begin
      pass.tp2 := newUrl + tp;
    end;

    tp := kdbh + pass.GCXH + '_3.jpg';
    if Download(pass.tp3, localPath, tp) then
    begin
      pass.tp3 := newUrl + tp;
    end;

    vioList[i] := pass;
  end;
end;

function TFromHik86Task.CheckIP(ip: string): boolean;
begin
  result := (ipList = '') or ipList.Contains(ip);
end;

destructor TFromHik86Task.Destroy;
begin
  idHttpServerIn.Active := false;
  idHttpServerIn.Free;
  logger.Info('FromHik86Task stoped');
end;

end.
