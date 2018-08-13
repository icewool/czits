unit uQTZHelper;

interface

uses
  SysUtils, Classes, Generics.Collections, IdHttp, IdURI, uGlobal, JSON;

type
  TQTZHelper = class
  private
    class function HttpGet(url: string): string;
    class function DecodeJSON<T>(jsonStr: string): T; static;
  public
    class function GetVehInfo(hphm, hpzl: string): string; static;
    class function GetAlarmList(pageIndex, pageSize: integer): TList<TAlarm>; static;
    class var QTZUrl: string;
  end;
const
  token = '9CC0E31FD9F648519AC79239B018F1A6';
implementation

{ TQTZHelper }

class function TQTZHelper.HttpGet(url: string): string;
var
  http: TIdHttp;
begin
  result := '';
  http := TIdHttp.Create(nil);
  http.Request.UserAgent := 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
  try
    result := http.Get(url);
  except
    on e: exception do
    begin
      logger.Error('[TQTZHelper.HttpGet]' + e.Message + url.Substring(0, 50));
    end;
  end;
  http.Free;
end;

class function TQTZHelper.DecodeJSON<T>(jsonStr: string): T;
begin

end;

class function TQTZHelper.GetAlarmList(pageIndex, pageSize: integer): TList<TAlarm>;
var
  s, a: string;
  body: TJSONArray;
  json, head, code, veh: TJSONValue;
  alarm: TAlarm;
begin
  result := TList<TAlarm>.Create;
  if QTZUrl = '' then exit;

  s := QTZUrl + 'GetAlarmVehicle?token='+token+'&pagesize='+pageSize.ToString+'&currentpage=' + pageIndex.ToString;
  s := HttpGet(s);
  if s = '' then
    exit;
  try
    json := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(s), 0);
    head := json.GetValue<TJSONValue>('head');
    code := head.GetValue<TJSONValue>('code');
    if code.Value = '1' then
    begin
      body := json.GetValue<TJSONArray>('body');
      for veh in body do
      begin
        alarm.HPHM := veh.GetValue<TJSONValue>('hphm').Value;
        alarm.HPZL := veh.GetValue<TJSONValue>('hpzl').Value;
        alarm.BKLX := veh.GetValue<TJSONValue>('bklx').Value;
        result.Add(alarm);
      end;
    end;
    json.Free;
  except
    on e: exception do
    begin
      logger.Error('TQTZHelper.GetAlarmList' + e.Message);
    end;
  end;
end;

class function TQTZHelper.GetVehInfo(hphm, hpzl: string): string;
var
  s: string;
begin
  result := '';
  if QTZUrl = '' then exit;
  s := QTZUrl + 'GetVehInfo?token='+token+'&hphm=' + hphm + '&hpzl=' + hpzl;
  s := TIdURI.URLDecode(s);
  result := HttpGet(s);
end;

end.

