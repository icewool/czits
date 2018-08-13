unit uBuKongDaHuoCheThread;

interface

uses
  System.Classes, SysUtils, Generics.Collections, DateUtils, ActiveX,
  uGlobal, uPassRec, uDFS;

type
  TBuKongDaHuoCheThread = class(TThread)
  private
    function GetPass(devIDs: string): TList<TPassRec>;
    function GetDevices(cjjg: string): string;
    procedure Save(passList: TList<TPassRec>; existsHphm: TDictionary<string, boolean>);
    function GetExistsHphm: TDictionary<string, boolean>;
  protected
    procedure Execute; override;
  end;

implementation

{ TBuKongDaHuoCheThread }

procedure TBuKongDaHuoCheThread.Execute;
var
  devices: string;
  passList: TList<TPassRec>;
  existsHphm: TDictionary<string, boolean>;
  pass: TPassRec;
begin
  ActiveX.CoInitialize(nil);
  self.FreeOnTerminate := true;
  gLogger.Info('BuKongDaHuoCheThread Start');
  devices := GetDevices('445122');
  passList := GetPass(devices);
  if passList.Count > 0 then
  begin
    existsHphm := GetExistsHPHM;
    Save(passList, existsHphm);
    existsHphm.Free;
  end;
  passList.Free;
  gLogger.Info('BuKongDaHuoCheThread End');
end;

function TBuKongDaHuoCheThread.GetExistsHphm: TDictionary<string, boolean>;
begin
  result := TDictionary<string, boolean>.Create;
  with gSQLHelper.Query('select distinct HPHM from T_KK_ALARM where HPZL=''01''') do
  begin
    while not EOF do
    begin
      result.Add(Fields[0].AsString, true);
      Next;
    end;
    Free;
  end;
end;

procedure TBuKongDaHuoCheThread.Save(passList: TList<TPassRec>; existsHphm: TDictionary<string, boolean>);
var
  pass: TPassRec;
  sql, bkxh: string;
begin
  bkxh := FormatDateTime('yyyymmddhhmmsszzz', Now);
  sql := '';
  for pass in passList do
  begin
    if not existsHPHM.ContainsKey(pass.HPHM) then
    begin
      sql := sql + ',(''' + pass.HPHM + ''',''01'',''99'',''无'',''Z'',''X99'',''' + bkxh + ''',''' + pass.TP1 + ''',0,0,''1'',''饶平重点关注货车'')';
      existsHPHM.Add(pass.HPHM, true);
    end;
  end;
  if sql <> '' then
  begin
    sql := sql.Substring(1);
    sql := 'insert into T_KK_ALARM(HPHM,HPZL,BKLX,CLPP,CSYS,CLLX,BKXH,viourl,ZT,UploadStatus,BKZL,BZ)values' + sql;
    gSQLHelper.ExecuteSql(sql);
  end;
end;

function TBuKongDaHuoCheThread.GetPass(devIDs: string): TList<TPassRec>;
var
  params: string;
begin
  params := 'passtime=' + FormatDateTime('yyyy-mm-dd hh:mm:ss', now - OneHour)
    + ',' + FormatDateTime('yyyy-mm-dd hh:mm:ss', now)
    + '&currentPage=1&pageSize=10000&crossingid=' + devIDs
    + '&vehicletype=2';
  result := TDFS.GetPassRecListFromK08(params);
end;

function TBuKongDaHuoCheThread.GetDevices(cjjg: string): string;
begin
  result := '';
  with gSQLHelper.Query('select HikID from s_device where cjjg like ''' + cjjg + '%''') do
  begin
    while not EOF do
    begin
      result := result + ' ' + Fields[0].AsString;
      Next;
    end;
    Free;
  end;
end;

end.
