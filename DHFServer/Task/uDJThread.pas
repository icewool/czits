unit uDJThread;

interface

uses
  Windows, Classes, Types, SysUtils, IOUtils, DateUtils, Generics.Collections,
  Variants, IdHTTP, uBaseThread, uTypes, uGlobal, uImageOps, uCommon,
  UInterface, uPassList, uHikJcbk;

type
  TDJThread = class(TBaseThread)
  private
    FConfig: TDJThreadConfig;
    FVioList: TList<TPass>;
    FTotal: integer;
    FTime: double;
    FRecentFiles: TDictionary<string, TDateTime>;
    function DealOnePass(pass: TPass): boolean;
    procedure SaveVIO(pass: TPass);
    function HttpGet: TList<TPass>;
  protected
    procedure Prepare; override;
    procedure Perform; override;
    procedure AfterTerminate; override;
  public
    constructor Create(config: TDJThreadConfig); overload;
  end;

implementation

{ TDJThread }

constructor TDJThread.Create(config: TDJThreadConfig);
begin
  FConfig := config;
  inherited Create;
end;

procedure TDJThread.Prepare;
begin
  inherited;
  logger.Info(FConfig.KeyName + ' Start');
  FVioList := TList<TPass>.Create;
  FRecentFiles := TDictionary<string, TDateTime>.Create;
  FTotal := 0;
  FTime := Now;
end;

procedure TDJThread.AfterTerminate;
begin
  inherited;
  if FVioList.Count > 0 then
    Tmypint.SaveVIO(FVioList);
  FVioList.Free;
  FRecentFiles.Free;
  logger.Info(FConfig.KeyName + ' Stoped');
end;

function TDJThread.HttpGet: TList<TPass>;
  function GetStream: TMemoryStream;
  var
    http: TIdHTTP;
  begin
    result := TMemoryStream.Create;
    http := TIdHTTP.Create(nil);
    try
      http.Get(FConfig.DBHost, result);
    except
      on e: exception do
      begin
        logger.Error('[HttpGet]' + e.Message);
      end;

    end;
    http.Free;
  end;

var
  stream: TMemoryStream;
  ss: TStrings;
  line: string;
  arr: TArray<string>;
  pass: TPass;
begin
  result := TList<TPass>.Create;
  stream := GetStream;
  if stream.Size > 0 then
  begin
    ss := TStringList.Create;
    stream.Seek(0, TSeekOrigin.soBeginning);
    ss.LoadFromStream(stream, TEncoding.UTF8);
    for line in ss do
    begin
      arr := line.Split([#9]);
      pass.CJJG := arr[0];
      pass.GCXH := arr[1];
      pass.KKSOURCE := arr[2];
      pass.kdbh := arr[3];
      pass.FXBH := arr[4];
      pass.cdbh := arr[5];
      pass.HPZL := arr[6];
      pass.gcsj := arr[7];
      pass.WFXW := arr[8];
      pass.clsd := arr[9];
      pass.hpys := arr[10];
      pass.HPHM := arr[11];
      pass.CSYS := arr[12];
      pass.CLPP := arr[13];
      pass.FWQDZ := arr[14];
      pass.tp1 := arr[15];
      pass.tp2 := arr[16];
      pass.tp3 := arr[17];
      result.Add(pass);
    end;
    ss.Free;
  end;
  stream.Free;
end;

procedure TDJThread.Perform;
var
  pass: TPass;
  list: TList<TPass>;
begin
  list := HttpGet;
  logger.Info('[HttpGet]Count: ' + list.Count.ToString);
  if list.Count > 0 then
  begin
    for pass in list do
    begin
      DealOnePass(pass);
      while self.FPaused do // 实现暂停
      begin
        self.FReallyPaused := true;
        Sleep(FSleep);
      end;
    end;
  end
  else
    Sleep(11000);
  list.Free;
end;

function TDJThread.DealOnePass(pass: TPass): boolean;
var
  device: TDevice;
  wfsj: double;
begin
  result := true;
  if pass.kdbh = '' then
    exit;

  if not gDicDevice.ContainsKey(pass.kdbh) then
  begin
    if not gUnknowDevice.ContainsKey(pass.kdbh) then
    begin
      gUnknowDevice.Add(pass.kdbh, true);
      logger.Warn('设备号未备案: [' + pass.kdbh + ']');
    end;
    exit;
  end;

  try
    Tmypint.DoAlarm(pass);
    // Tmypint.CheckFalseHPHM(pass);
    device := gDicDevice[pass.kdbh];
    if device.SCJCPT and (device.BABH <> '') then
      Tmypint.WriteVehicleInfo(pass, device);

    if (pass.WFXW <> '0') and
      ((device.lhy_cjfs = '3') or (device.lhy_cjfs = '7')) then
      pass.WFXW := Tmypint.getSpeedtoWFXW(pass.HPZL, strtointdef(pass.clsd, 0),
        device.XZSD);

    if pass.WFXW = '13441' then // 黄标车
    begin
      wfsj := VarToDateTime(pass.gcsj);
      if not gDicHBC.ContainsKey(pass.HPHM + pass.HPZL) then
      begin
        pass.WFXW := '0';
      end;
    end;

    if pass.WFXW.Length >= 4 then
    begin
      SaveVIO(pass);
    end;

    if holeSBBH.ContainsKey(pass.kdbh) then
    begin
      Tmypint.WriteHoleService(pass);
    end;

    PassList.Add(pass);

    THikJcbk.DealOnePass(pass);

    if Now - device.gxsj > 10 * OneMinute then // 每10分钟更新设备最新过车时间
      UpdateDeviceGXSJ(pass.kdbh, Now);
  except
    on e: exception do
    begin
      logger.Error('[DealOnePass]' + e.Message);
      result := false;
    end;
  end;
end;

procedure TDJThread.SaveVIO(pass: TPass);
begin
  FVioList.Add(pass);
  if (FVioList.Count >= 999) or (Now - FTime > OneMinute) then
  begin
    Tmypint.SaveVIO(FVioList);
    FVioList.Clear;
    FTime := Now;
  end;
end;

end.
