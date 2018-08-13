unit uQTZHelper;

interface

uses
  SysUtils, Classes, IdHttp, IdURI, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent, uGlobal;

type
  TQTZHelper = class
  private
  public
    class function HttpGet(url: string): string;
    class function HttpPost(url: string; stream: TStream): string; static;
    class function GetVehInfo(hphm, hpzl: string): string; static;
    class function Surscreen(sbbh,zqmj,clfl,hpzl,hphm,xzqh,wfdd,lddm,ddms,wfdz,
                        wfsj,wfsj1,wfxw,scz,bzz: string; zpsl: integer;
                        zpwjm,zpstr1,zpstr2,zpstr3,wfspdz: string): string; static;
    class function QVehbus(hphm, hpzl: string): boolean; static;
    class function WriteVehicleInfo(const kkbh: string; const fxlx: string; const cdh: Int64; const hphm: string; const hpzl: string; const gcsj: string;
                               const clsd: Int64; const clxs: Int64; const wfdm: string; const cwkc: Int64; const hpys: string;
                               const cllx: string; const fzhpzl: string; const fzhphm: string; const fzhpys: string; const clpp: string;
                               const clwx: string; const csys: string; const tplj: string; const tp1: string; const tp2: string;
                               const tp3: string; const tztp: string): integer; static;
    class var QTZUrl: string;
  end;
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
      logger.Error('[QTZHelper][HttpGet]' + e.Message + url.Substring(0, 50));
    end;
  end;
  http.Free;
end;

class function TQTZHelper.HttpPost(url: string; stream: TStream): string;
var
  http: TIdHttp;
begin
  result := '';
  http := TIdHttp.Create(nil);
  try
    result := http.Post(url, stream);
  except
    on e: exception do
    begin
      logger.Error('[QTZHelper][HttpGet]' + e.Message + url.Substring(0, 50));
    end;
  end;
  http.Free;
end;

class function TQTZHelper.GetVehInfo(hphm, hpzl: string): string;
begin
  result := '';
  if QTZUrl = '' then exit;
  result := HttpGet(QTZUrl + 'GetVehInfo?hphm=' + hphm + '&hpzl=' + hpzl);
end;

class function TQTZHelper.QVehbus(hphm, hpzl: string): boolean;
var
  response, s: string;
  i: integer;
begin
  result := false;
  if QTZUrl = '' then exit;
  s := HttpGet(QTZUrl + 'QVehbus?hphm=' + hphm + '&hpzl=' + hpzl);
  i := response.IndexOf('<kycllx>') + 8;
  if i > 0 then
  begin
    s := response.Substring(i, 1);
    result := (s = '1') or (s = '2');
  end;
  if not result then
  begin
    i := response.IndexOf('<sfjbc>') + 7;
    if i > 0 then
    begin
      s := response.Substring(i, 1);
      result := s = '1';
    end;
  end;
end;

class function TQTZHelper.Surscreen(sbbh,zqmj,clfl,hpzl,hphm,xzqh,wfdd,lddm,ddms,wfdz,
                        wfsj,wfsj1,wfxw,scz,bzz: string; zpsl: integer;
                        zpwjm,zpstr1,zpstr2,zpstr3, wfspdz: string): string;
var
  s: string;
  stream: TStringStream;
begin
  result := '';
  if QTZUrl = '' then exit;
  s := QTZUrl + 'Surscreen?sbbh=' + sbbh;
  if zqmj <> '' then s := s + '&zqmj=' + zqmj;
  if clfl <> '' then s := s + '&clfl=' + clfl;
  if hpzl <> '' then s := s + '&hpzl=' + hpzl;
  if hphm <> '' then s := s + '&hphm=' + hphm;
  if xzqh <> '' then s := s + '&xzqh=' + xzqh;
  if wfdd <> '' then s := s + '&wfdd=' + wfdd;
  if lddm <> '' then s := s + '&lddm=' + lddm;
  if ddms <> '' then s := s + '&ddms=' + ddms;
  if wfdz <> '' then s := s + '&wfdz=' + wfdz;
  if wfsj <> '' then s := s + '&wfsj=' + wfsj;
  if wfsj1 <> '' then s := s + '&wfsj1=' + wfsj1;
  if wfxw <> '' then s := s + '&wfxw=' + wfxw;
  if scz <> '' then s := s + '&scz=' + scz;
  if bzz <> '' then s := s + '&bzz=' + bzz;
  s := s + '&zpsl=' + zpsl.ToString;
  if zpwjm <> '' then s := s + '&zpwjm=' + zpwjm;
  {s := s + '&zpstr1=' + zpstr1;
  if zpstr2 <> '' then s := s + '&zpstr2=' + zpstr2;
  if zpstr3 <> '' then s := s + '&zpstr3=' + zpstr3; }
  if wfspdz <> '' then s := s + '&wfspdz=' + wfspdz;

  stream := TStringStream.Create;
  stream.WriteString('zpstr1=' + zpstr1);
  if zpstr2 <> '' then stream.WriteString('&zpstr2=' + zpstr2);
  if zpstr3 <> '' then stream.WriteString('&zpstr3=' + zpstr3);

  result := HttpPost(s, stream);
  stream.Free;
end;

class function TQTZHelper.WriteVehicleInfo(const kkbh, fxlx: string;
  const cdh: Int64; const hphm, hpzl, gcsj: string; const clsd, clxs: Int64;
  const wfdm: string; const cwkc: Int64; const hpys, cllx, fzhpzl, fzhphm,
  fzhpys, clpp, clwx, csys, tplj, tp1, tp2, tp3, tztp: string): integer;
var
  s: string;
begin
  result := 0;
  if QTZUrl = '' then exit;
  s := QTZUrl + 'WriteVehicleInfo?kkbh=' + kkbh
    + '&fxlx=' +  fxlx
    + '&cdh=' +  cdh.ToString
    + '&hphm=' +  hphm
    + '&hpzl=' +  hpzl
    + '&gcsj=' +  gcsj
    + '&clsd=' +  clsd.ToString
    + '&clxs=' +  clxs.ToString
    + '&wfdm=' +  wfdm
    + '&cwkc=' +  cwkc.ToString
    + '&hpys=' +  hpys
    + '&cllx=' +  cllx
    + '&fzhpzl=' +fzhpzl
    + '&fzhphm=' +fzhphm
    + '&fzhpys=' +fzhpys
    + '&clpp=' +  clpp
    + '&clwx=' +  clwx
    + '&csys=' +  csys
    + '&tplj=' +  tplj
    + '&tp1=' +  tp1
    + '&tp2=' +  tp2
    + '&tp3=' +  tp3
    + '&tztp=' +  tztp;
  s := HttpGet(TIdUri.URLEncode(s));
  result := StrToIntDef(s, 0);
end;

end.

