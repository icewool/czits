unit uTaskManager;

interface

uses
  SysUtils, IOUtils, Generics.Collections, DB, uBaseThread, uGlobal, uTypes,
  uCommon, IniFiles, Classes, uOutThread, DateUtils;

type
  TTaskManager = class
  private
    FThreadList: TList<TBaseThread>;
    function LoadConfig: TList<TOraConfig>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure CreateThreads;
    procedure ClearThreads;
    procedure SuspendThreads;
    procedure ResumeThreads;
  end;

var
  TaskManager: TTaskManager;

implementation

constructor TTaskManager.Create;
begin
  FThreadList := TList<TBaseThread>.Create;
end;

destructor TTaskManager.Destroy;
begin
  ClearThreads;
  FThreadList.Free;
  inherited;
end;

function TTaskManager.LoadConfig: TList<TOraConfig>;
var
  config: TOraConfig;
  ini: TIniFile;
  ss: TStrings;
  sec: string;
begin
  result := TList<TOraConfig>.Create;
  ini:= TIniFile.Create(TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'Config.ini'));
  ss := TStringList.Create;
  ini.ReadSections(ss);
  for sec in ss do
  begin
    config.HOST := ini.ReadString(sec, 'HOST', '172.30.110.225');
    config.Port := ini.ReadString(sec, 'Port', '1521');
    config.SID := ini.ReadString(sec, 'SID', 'orcl');
    config.UserName := ini.ReadString(sec, 'UserName', 'bracdb');
    config.Password := ini.ReadString(sec, 'Password', 'password01');
    config.TableName := sec;
    config.SelectSQL := ini.ReadString(sec, 'SelectSQL', '');
    config.InsertSQL := ini.ReadString(sec, 'InsertSQL', '');
    config.OrderField := ini.ReadString(sec, 'OrderField', '');
    config.MaxOrderFieldValue := ini.ReadString(sec, 'MaxOrderFieldValue', '');
    config.TargetFilePath := ini.ReadString(sec, 'TargetFilePath', '');
    config.IntervalSecond := ini.ReadInteger(sec, 'IntervalSecond', 1);
    result.Add(config);
  end;
  ss.Free;
  ini.Free;
end;

procedure TTaskManager.CreateThreads;
var
  list: TList<TOraConfig>;
  config: TOraConfig;
  thread: TOutThread;
begin
  list := LoadConfig;
  for config in list do
  begin
    thread := TOutThread.Create(config);
    FThreadList.Add(thread);
  end;
  list.Free;
end;

procedure TTaskManager.ClearThreads;
var
  item: TBaseThread;
  allFinished: boolean;
  dt: Double;
begin
  for item in FThreadList do
  begin
    item.Terminate;
  end;
  dt := now;
  allFinished := false;
  while not allFinished do
  begin
    Sleep(1000);
    allFinished := true;
    for item in FThreadList do
    begin
      allFinished := allFinished and item.Finished;
    end;
  end;
  for item in FThreadList do
  begin
    item.Free;
  end;
  FThreadList.Clear;
end;

procedure TTaskManager.SuspendThreads;
var
  item: TBaseThread;
  allPaused: boolean;
begin
  for item in FThreadList do
  begin
    item.Pause;
  end;

  allPaused := false;
  while not allPaused do
  begin
    Sleep(2000);
    allPaused := true;
    for item in FThreadList do
    begin
      allPaused := allPaused and ((item.Status = tsPaused)or(item.Status = tsDead));
      if not allPaused then
      begin
        logger.Info('wait for [' + item.ThreadID.ToString + ']' + item.ClassName);
      end;
    end;
  end;
end;

procedure TTaskManager.ResumeThreads;
var
  item: TBaseThread;
begin
  for item in FThreadList do
  begin
    item.GoOn;
  end;
end;

end.
