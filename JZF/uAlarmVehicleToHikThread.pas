unit uAlarmVehicleToHikThread;

interface

uses
  System.Classes, SysUtils, Generics.Collections, DateUtils, ActiveX,
  IdHttp, uGlobal;

type
  TAlarmVehicleToHikThread = class(TThread)
  private
    function Foo: integer;
    function SendData(data: TStringStream): boolean;
  protected
    procedure Execute; override;
  end;

implementation

{ TAlarmVehicleToHikThread }

procedure TAlarmVehicleToHikThread.Execute;
var
  data: TStringStream;
begin
  ActiveX.CoInitialize(nil);
  self.FreeOnTerminate := true;
  gLogger.Info('AlarmVehicleToHikThread Start');
  while Foo > 0 do ;
  gLogger.Info('AlarmVehicleToHikThread End');
end;

function TAlarmVehicleToHikThread.Foo: integer;
var
  data: TStringStream;
  id: integer;
begin
  result := 0;
  with gSQLHelper.Query('select top 5000 ID,HPHM,HPZL,BKLX,ZT+1 as ZT from T_Alarm_Vehicle_ToHik where zt=0 or zt=2 order by ID') do
  begin
    if not EOF then
    begin
      result := RecordCount;
      id := 0;
      data := TStringStream.Create;
      data.WriteString('{"dataNum":' + RecordCount.ToString + ',"dataList":[');
      while not EOF do
      begin
        if not BOF then
          data.WriteString(',');
        id := Fields[0].AsInteger;
        data.WriteString('{"blackID":' + Fields[0].AsString);
        data.WriteString(',"plateNo":"' + Fields[1].AsString + '"');
        data.WriteString(',"hpzl":"' + Fields[2].AsString + '"');
        data.WriteString(',"defenceCode":"' + Fields[3].AsString + '"');
        data.WriteString(',"operateType":' + Fields[4].AsString + '}');
        Next;
      end;
      data.WriteString(']}');
      if SendData(data) then
        gSQLHelper.ExecuteSql('update T_Alarm_Vehicle_ToHik set zt=zt+1 where (zt=0 or zt=2) and ID<=' + id.ToString)
      else
        result := 0;
      data.Free;
    end;
    Free;
  end;
end;

function TAlarmVehicleToHikThread.SendData(data: TStringStream): boolean;
var
  http: TIdHttp;
  resp: string;
begin
  result := false;
  http := TIdHttp.Create(nil);
  try
    resp := http.Post(gHikAlarmVehicleUrl, data);
    gLogger.Info('[TAlarmVehicleToHikThread.SendData]' + resp);
    result := resp.Contains('"success":true');
  except
    on e: exception do
    begin
      gLogger.Error('[TAlarmVehicleToHikThread.SendData]' + e.Message);
    end;
  end;
  http.Free;
end;

end.
