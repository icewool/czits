unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, SyncObjs, IniFiles, Generics.Collections,
  uLogger, uGlobal, uBaseThread, uToHik86, uTaskManager, FireDAC.Phys.OracleDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf, IOUtils,
  FireDAC.Phys, FireDAC.Phys.Oracle, idhttp, Vcl.ExtCtrls, uQTZHelper, Types,
  uYunJingAlarm;

type
  TItsHik86Service = class(TService)
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Timer1: TTimer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure GetAlarmDic;
    procedure LoadIMEI;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ItsHik86Service: TItsHik86Service;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ItsHik86Service.Controller(CtrlCode);
end;

function TItsHik86Service.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TItsHik86Service.ServiceStart(Sender: TService; var Started: Boolean);
var
  path: string;
  ini: TIniFile;
begin
  path := ExtractFilePath(ParamStr(0));
  if not DirectoryExists(path + 'log') then
    CreateDir(path + 'log');
  logger := TLogger.Create(path + 'log\Hik86.log');
  AlarmDic := TDictionary<string, TAlarm>.Create;
  ini := TIniFile.Create(path + 'config.ini');
  logger.Level :=  ini.ReadInteger('sys', 'LogLevel', 2);
  if ini.ReadInteger('sys', 'ToHik86', 1) = 1 then
    ToHik86 := TToHik86.Create;
  if ini.ReadInteger('sys', 'YunJingAlarm', 1) = 1 then
    YunJingAlarm := TYunJingAlarm.Create;
  if ini.ReadInteger('sys', 'FromHik86', 0) = 1 then
  begin
    TaskManager := TTaskManager.Create;
    TaskManager.CreateThreads;
  end;
  TQTZHelper.QTZUrl := ini.ReadString('sys', 'QTZUrl', '');
  ini.Free;
  logger.Info('Start');
  LoadIMEI;
  GetAlarmDic;
end;

procedure TItsHik86Service.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  if Assigned(ToHik86) then
    ToHik86.Free;
  if Assigned(YunJingAlarm) then
    YunJingAlarm.Free;
  if Assigned(TaskManager) then
    TaskManager.Free;
  logger.Info('Stop');
  logger.Free;
end;

procedure TItsHik86Service.Timer1Timer(Sender: TObject);
begin
  if FormatDateTime('hhnn', now) = '0000' then
  begin
    LoadIMEI;
    GetAlarmDic;
  end;
end;

procedure TItsHik86Service.GetAlarmDic;
var
  key: string;
  alarm: TAlarm;
  i: integer;
  tmpList: TList<TAlarm>;
  pageIndex, pageSize: integer;
  isOver: boolean;
begin
  pageIndex := 0;
  pageSize := 10000;
  isOver := false;
  while not isOver do
  begin
    tmpList := TQTZHelper.GetAlarmList(pageIndex, pageSize);
    logger.Info('[TItsHik86Service.GetAlarmDic]: ' + tmpList.Count.ToString);
    for i := 0 to tmpList.Count - 1 do
    begin
      alarm := tmpList[i];
      key := alarm.HPHM;// + alarm.HPZL;
      if not AlarmDic.ContainsKey(key) then
      begin
        alarm.ZT := true;
        AlarmDic.Add(key, alarm);
      end;
    end;
    isOver := tmpList.Count < pageSize;
    tmpList.Free;
    Inc(pageIndex);
  end;
end;

procedure TItsHik86Service.LoadIMEI;
var
  ss: TStringDynArray;
  s, key, value: string;
  i: integer;
begin
  // TODO: 配置IMEI
  IMEIDic := TDictionary<string, string>.Create;
  s := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'IMEI.ini');
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
        if not IMEIDic.ContainsKey(key) then
        begin
          IMEIDic.Add(key, value);
          logger.Debug('[TItsHik86Service.LoadIMEI]' + s);
        end;
      end;
    end;
  end;
end;

end.
