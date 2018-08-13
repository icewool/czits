unit uTaskManager;

interface

uses
  SysUtils, IOUtils, Generics.Collections, Classes, IniFiles,
  uBaseThread, uGlobal, uTypes, uFromHik86;

type
  TTaskManager = class
  private
    FThreadList: TList<TBaseThread>;
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

procedure TTaskManager.CreateThreads;
var
  ini: TIniFile;
  sec: string;
  sections: TStrings;
  config: TConfig;
  thd: TFromHik86;
begin
  FThreadList := TList<TBaseThread>.Create;
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  sections := TStringList.Create;
  ini.ReadSections(sections);
  for sec in sections do
  begin
    config.Name := sec;
    config.Host := ini.ReadString(sec, 'Host', '');
    config.Port := ini.ReadString(sec, 'Port', '');
    config.SID := ini.ReadString(sec, 'SID', '');
    config.Usr := ini.ReadString(sec, 'Usr', '');
    config.Pwd := ini.ReadString(sec, 'Pwd', '');
    config.BdrUrl := ini.ReadString(sec, 'BdrUrl', '');
    config.IsVio := ini.ReadInteger(sec, 'IsVio', 0) = 1;
    config.AlarmUrl := ini.ReadString(sec, 'AlarmUrl', '');
    if config.Host <> '' then
    begin
      thd := TFromHik86.Create(config);
      FThreadList.Add(thd);
    end;
  end;
  sections.Free;
  ini.Free;
end;

procedure TTaskManager.ClearThreads;
var
  item: TBaseThread;
  allFinished: boolean;
begin
  for item in FThreadList do
  begin
    item.Terminate;
  end;

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
