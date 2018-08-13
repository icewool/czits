unit uHikJcbk;

interface

uses
  System.Threading, SysUtils, Classes, IdHttp, uTypes, uHikDaoFeng, uGlobal,
  Generics.Collections, uQTZHelper, System.NetEncoding;

type
  THikJcbk = Class
  private
    class procedure AnaylzePass(pass: TPass);
    class procedure SaveAlarm(pass: TPass; veh: TDFVehInfo; wfxw: String);
  public
    class procedure DealOnePass(pass: TPass);
  End;

implementation

{ THikJcbk }

class procedure THikJcbk.AnaylzePass(pass: TPass);
var
  wfxw: String;
  hik: THik;
  veh: TDFVehInfo;
  vehList: TList<TDFVehInfo>;
begin
  hik := THik.Create;
  hik.Config := gHikConfig;
  logger.Debug('Anaylze pic ' + pass.FWQDZ + pass.tp1);
  vehList := hik.DFAnalysisOnePic(pass.FWQDZ + pass.tp1);
  logger.Debug('Anaylze pic OK');
  if vehList <> nil then
  begin
    logger.Debug('Anaylze veh count:' + IntToStr(vehList.Count));
    for veh in vehList do
    begin
      if Length(veh.PlateNum) < 7 then
        continue;
      if (veh.nType = '1') or (veh.nType = '10') then  // 大型客车 or 中型客车
      begin
        if not TQTZHelper.qvehbus(veh.PlateNum, '01') then
        begin
          wfxw := '8026';  //非运营车
          SaveAlarm(pass, veh, wfxw);
        end;
      end;
      if veh.nPilotSB = '1' then
        wfxw := '6011'   //主驾驶未系安全带
      else if veh.nCopilotSB = '1' then
        wfxw := '7012'   //副驾驶未系安全带
      else if veh.nUPhone = '1' then
        wfxw := '1223'   //驾驶时拨打接听手持电话
      else
        continue;
      SaveAlarm(pass, veh, wfxw);
    end;
    vehList.Free;
  end
  else
    logger.Debug('Anaylze No Data');
  hik.Free;
end;

class procedure THikJcbk.DealOnePass(pass: TPass);
begin
  if gHikConfig.DFUrl = '' then exit;
  if not gDicDevice[pass.kdbh].hikJcbk then
    exit;
  if (pass.HPZL <> '01') and (pass.HPZL <> '02') then
    exit;

  TTask.Create(
    procedure
    begin
      AnaylzePass(pass);
    end, hikJcbkdPool.Current).Start;
end;

class procedure THikJcbk.SaveAlarm(pass: TPass; veh: TDFVehInfo; wfxw: String);
  function GetPicData(url: string): string;
  var
    http: TIdHttp;
    stream: TMemoryStream;
    ss: TStringStream;
  begin
    result := '';
    http := TIdHttp.Create(nil);
    stream := TMemoryStream.Create;
    ss := TStringStream.Create();
    try
      http.Get(url, stream);
      stream.Position := 0;
      TNetEncoding.Base64.Encode(stream, ss);
      result := ss.DataString;
    except
      on e: exception do
      begin
        logger.Error('[GetPicData]' + e.Message + url);
      end;
    end;
    ss.Free;
    stream.Free;
    http.Free;
  end;
var
  s, HPZL, picData1, picData2, picData3: string;
  vehType: Integer;
  dev: TDevice;
begin
  if not gDicDevice.ContainsKey(pass.kdbh) then exit;
  dev := gDicDevice[pass.kdbh];

  vehType := StrToInt(veh.nType);
  case vehType of
    1, 2, 10:
      HPZL := '01';
    3, 4, 5, 9:
      HPZL := '02';
  else
    HPZL := '02';
  end;

  picData1 := GetPicData(pass.FWQDZ + pass.tp1);
  if pass.tp2 <> '' then
    picData2 := GetPicData(pass.FWQDZ + pass.tp2);
  if pass.tp3 <> '' then
    picData3 := GetPicData(pass.FWQDZ + pass.tp3);
  s := TQTZHelper.Surscreen(dev.LHY_SBBH,'','3',HPZL, veh.PlateNum, dev.LHY_XZQH,
    dev.LHY_WFDD,dev.LHY_LDDM,dev.LHY_DDMS,dev.SBDDMC,pass.gcsj,'',wfxw,'','',1,
    '', picData1,picData2,picData3,'');
  logger.Info('[Surscreen][' + veh.PlateNum + '][' + wfxw + ']' + s);
end;

end.
