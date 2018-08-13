unit uWNJVioThread;

interface

uses
  System.Classes, SysUtils, ActiveX, uGlobal;

type
  TWNJVioThread = class(TThread)
  private
    function GetSecondPic(hphm, hpzl, picUrl: String; wfsj: TDateTime): String;
    function Getpic(sql, picUrl: String): String;
    function SaveVio(cjjg, hphm, hpzl, wfsj, wfdd, tp1, tp2: String): Boolean;
  protected
    procedure Execute; override;
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TWNJVioThread.UpdateCaption;
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

{ TWNJVioThread }

procedure TWNJVioThread.Execute;
var
  s, cjjg, hphm, hpzl, wfdd, tp1, tp2: String;
  wfsj: TDateTime;
  vioList: TStrings;
begin
  ActiveX.CoInitialize(nil);
  vioList:= TStringList.Create;
  gLogger.Info('WNJVioThread Start');
  s := ' select c.CJJG, a.HPHM, a.HPZL, a.GCSJ, a.KDBH, a.VIOURL '
    +' from T_KK_ALARMRESULT a '
    +' inner join S_DEVICE c '
    +' on a.KDBH = c.SBBH and c.WNJVio = 1 '
    +' left join T_VIO_TEMP b '
    +' on a.HPHM=b.HPHM and a.HPZL=b.HPZL and a.GCSJ=b.WFSJ '
    +' where a.bkzl=''×Ô¶¯²¼¿Ø'' and a.BKLX=''06'' and a.GCSJ>''' +
    FormatDateTime('yyyy-mm-dd hh:nn:ss', now - 3 / 24) +
    ''' and b.wfxw = ''1340'' and b.HPHM is null ';

  with gSQLHelper.Query(s) do
  begin
    while not Eof do
    begin
      cjjg:= FieldByName('CJJG').AsString;
      hphm:= FieldByName('hphm').AsString;
      hpzl:= FieldByName('hpzl').AsString;
      wfdd:= FieldByName('kdbh').AsString;
      wfsj:= FieldByName('GCSJ').AsDateTime;
      tp1:= FieldByName('VIOURL').AsString;
      if vioList.IndexOf(hphm+hpzl) >= 0 then
        continue;
      tp2:= GetSecondPic(hphm, hpzl, tp1, wfsj);
      if tp2 <> '' then
      begin
        if SaveVio(cjjg, hphm, hpzl, FormatDateTime('yyyy-mm-dd hh:nn:ss', wfsj), wfdd, tp1, tp2) then
          vioList.Add(hphm+hpzl);
      end;
      Next;
    end;
    Free;
  end;

  gLogger.Info('WNJVioThread Start');
  ActiveX.CoUninitialize;
end;

function TWNJVioThread.Getpic(sql, picUrl: String): String;
var
  fwqdz, tp1, tp2: String;
begin
  Result:= '';
  fwqdz:= '';
  tp1:= '';
  tp2:= '';
  with gSQLHelper.Query(sql) do
  begin
    while not Eof do
    begin
      fwqdz:= Trim(Fields[0].AsString);
      tp1:= Trim(Fields[1].AsString);
      tp2:= Trim(Fields[2].AsString);
      if (fwqdz = '') or (tp1 = '') then
        continue;
      tp1:=  fwqdz + tp1;
      if tp1 <> picUrl then
      begin
        Result:= tp1;
        break;
      end;

      if tp2 <> '' then
      begin
        tp2:=  fwqdz + tp2;
        if tp2 <> picUrl then
        begin
          Result:= tp2;
          break;
        end;
      end;
      Next;
    end;
    Free;
  end;
end;

function TWNJVioThread.GetSecondPic(hphm, hpzl, picUrl: String; wfsj: TDateTime): String;
var
  tbName, s: String;
begin
  Result:= '';
  tbName:= gConfig.DBNamePass + '.dbo.T_KK_VEH_PASSREC_' + FormatDatetime('yyyymmdd', wfsj);
  s:= 'select FWQDZ, TP1, TP2 from ' + tbName + ' where  hphm=' +
      hphm.QuotedString + ' and hpzl=' + hpzl.QuotedString + ' and gcsj = ' +
      FormatDatetime('yyyy-mm-dd hh:nn:ss', wfsj).QuotedString;
  Result:= Getpic(s, picUrl);

  if Result = '' then
  begin
    s:= ' select FWQDZ, TP1, TP2 from ' + tbName + ' where  hphm=' +
      hphm.QuotedString + ' and hpzl=' + hpzl.QuotedString + ' and gcsj <> ' +
      FormatDatetime('yyyy-mm-dd hh:nn:ss', wfsj).QuotedString+' order by gcsj desc';
    Result:= Getpic(s, picUrl);
  end;
end;

function TWNJVioThread.SaveVio(cjjg, hphm, hpzl, wfsj, wfdd, tp1, tp2: String): Boolean;
var
  s: String;
begin
  s:= 'insert into T_VIO_TEMP(cjjg, hphm, hpzl, wfsj, wfdd, PHOTOFILE1, PHOTOFILE2, wfxw) values '
    +'('+cjjg.QuotedString +','+hphm.QuotedString+','+hpzl.QuotedString+','
    +wfsj.QuotedString+','+wfdd.QuotedString+','+tp1.QuotedString+','+tp2.QuotedString+',''1340'')';
  Result:= gSQLHelper.ExecuteSql(s);
  if Result then
    gLogger.Info('[WNJVioThread] Save Vio Succ: ' + hphm + ',' + hpzl)
  else
    gLogger.Error('[WNJVioThread] Save Vio error: ' + s);
end;

end.
