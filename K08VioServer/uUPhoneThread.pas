﻿unit uUPhoneThread;

interface

uses
  System.Classes, Generics.Collections, IdHTTP, SysUtils, uGlobal, uCommon,
  uDecodeHikResult, DateUtils, ActiveX, wininet, uHik, IDURI;

type
  TUPhoneThread = class(TThread)
  private
    gVioVeh: TStrings; // 防止重复写入，主键为 hphm_yyyymmdd, 只保存5000条
    function GetVioSQLs(vehList: TList<TK08VehInfo>): TStrings;
  protected
    procedure Execute; override;
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TPilotsafebeltThread.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TUPhoneThread }

procedure TUPhoneThread.Execute;
var
  Params, SQLs, tmpSQLs: TStrings;
  param, EndTime, maxPasstime: String;
  totalPage, currentPage: Integer;
  currentTime: TDateTime;
  vehList: TList<TK08VehInfo>;
begin
  gLogger.Info('[UPhone] UPhoneThread Start');
  if gThreadConfig.PilotsafebeltDev = '' then
  begin
    gLogger.Info('[UPhone] 未配置抓拍设备');
    gLogger.Info('[UPhone] UPhoneThread Stop');
    exit;
  end;
  ActiveX.CoInitializeEx(nil, COINIT_MULTITHREADED);
  SQLs := TStringList.Create;
  gVioVeh := TStringList.Create;
  while True do
  begin
    maxPasstime := THik.GetMaxPassTime('crossingid:(' +
      gThreadConfig.PilotsafebeltDev + ')');
    if maxPasstime = '' then
    begin
      gLogger.Error('[UPhone] 访问K08失败');
      Sleep(10 * 60000);
      continue;
    end;

    while gVioVeh.Count > 5000 do
      gVioVeh.Delete(0);

    currentTime := TCommon.StringToDT(maxPasstime) - DateUtils.OneHour;
    EndTime := FormatDatetime('yyyy-mm-dd', currentTime) + 'T' +
      FormatDatetime('hh:nn:ss', currentTime) + '.999Z';

    param := 'crossingid:(' + gThreadConfig.PilotsafebeltDev +
      ') AND passtime:([' + gThreadConfig.UPhoneStartTime + ' TO ' + EndTime +
      ']) AND uphone:(1)';

    gLogger.Info('[UPhone] Param: ' + param);

    totalPage := 1;
    currentPage := 1;
    while currentPage <= totalPage do
    begin
      gLogger.Info('[UPhone] Get Vio StartTime:' + gThreadConfig.UPhoneStartTime
        + ', EndTime:' + EndTime + ', Page:' + IntToStr(currentPage) +
        ', TotalPage:' + IntToStr(totalPage));
      // k08是分页返回的，有可能查询中间某页出错，那么就无法知道哪些违法已经入库，
      // 所以只要查询某一页出错，当次查询的所有违法都不保存

      try
        Params := THik.GetK08SearchParam(param, IntToStr(currentPage), '100');
        vehList := THik.GetK08PassList(Params, totalPage, currentPage);
        Params.Free;
        if vehList <> nil then
        begin
          tmpSQLs := GetVioSQLs(vehList);
          if tmpSQLs.Count > 0 then
            SQLs.AddStrings(tmpSQLs);
          tmpSQLs.Free;
          vehList.Free;
          inc(currentPage);
        end
        else
        begin
          gLogger.Error('[UPhone] vehList is null');
          SQLs.Clear;
          break;
        end;
      except
        on e: exception do
        begin
          gLogger.Error(e.Message);
          SQLs.Clear;
          break;
        end;
      end;
    end;
    if SQLs.Count > 0 then
    begin
      if gSQLHelper.ExecuteSqlTran(SQLs) then
      begin
        currentTime := currentTime + DateUtils.OneSecond;
        gThreadConfig.UPhoneStartTime := FormatDatetime('yyyy-mm-dd',
          currentTime) + 'T' + FormatDatetime('hh:nn:ss', currentTime)
          + '.000Z';
        TCommon.SaveConfig('Task', 'UPhoneStartTime',
          gThreadConfig.UPhoneStartTime);
        gLogger.Info('[UPhone] Save UPhone Vio Count: ' + IntToStr(SQLs.Count));
      end
      else
        gLogger.Error('[UPhone] Save UPhone Vio Error');
      SQLs.Clear;
    end
    else
      gLogger.Info('[UPhone] Save UPhone Vio Count: 0');
    Sleep(10 * 60000);
  end;
  gLogger.Info('[UPhone] UPhoneThread Stop');
  SQLs.Free;
  gVioVeh.Free;
  ActiveX.CoUninitialize;
end;

function TUPhoneThread.GetVioSQLs(vehList: TList<TK08VehInfo>): TStrings;
var
  veh: TK08VehInfo;
  s, tp1, Tp2, hphm: String;
  dt: TDateTime;
begin
  Result := TStringList.Create;
  for veh in vehList do
  begin
    if gDevList.ContainsKey(veh.crossingid) and
      (gHpzlList[veh.vehicletype] <> '07') then
    begin
      dt := TCommon.StringToDT(veh.passtime);
      hphm := veh.plateinfono + '_' + FormatDatetime('yyyymmdd', dt);
      if gVioVeh.IndexOf(hphm) >= 0 then
        continue;

      tp1 := veh.picvehicle;
      tp1 := tp1.Replace('&amp;', '&');
      Tp2 := tp1.Replace('1.jpg', '2.jpg');
      if tp1 = Tp2 then
        continue;
      if not InternetCheckConnection(PChar(Tp2), 1, 0) then
      begin
        gLogger.Info('[UPhone] not found Photofile2');
        continue;
      end;

      tp1 := TIdURI.URLDecode(tp1);
      Tp2 := TIdURI.URLDecode(Tp2);

      s := ' insert into T_VIO_TEMP(CJJG, HPHM, HPZL, WFDD, WFXW, WFSJ, CD, PHOTOFILE1, PHOTOFILE2, BJ) values ('
        + gDevList[veh.crossingid].CJJG.QuotedString + ',' +
        veh.plateinfono.QuotedString + ',' + gHpzlList[veh.vehicletype]
        .QuotedString + ',' + gDevList[veh.crossingid].SBBH.QuotedString +
        ',''1223'',' + veh.passtime.QuotedString + ',' + veh.laneid.QuotedString
        + ',' + tp1.QuotedString + ',' + Tp2.QuotedString + ',''0'')';
      Result.Add(s);
      gVioVeh.Add(hphm)
    end;
  end;
end;

end.
