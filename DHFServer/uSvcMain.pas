unit uSvcMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, uCommon, uTaskManager, uGlobal,
  FireDAC.Phys.OracleDef, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.Oracle, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, Vcl.ExtCtrls, UInterface,
  uFromHik86Task, uPGThread, IniFiles;

type
  TITSDHFSvc = class(TService)
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    Timer1: TTimer;
    IdHTTP1: TIdHTTP;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure DoHeartbeat;
    procedure StartPGThread;
    //procedure CheckDeviceStatus;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ITSDHFSvc: TITSDHFSvc;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ITSDHFSvc.Controller(CtrlCode);
end;

function TITSDHFSvc.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TITSDHFSvc.ServiceStart(Sender: TService; var Started: Boolean);
begin
  uCommon.Initialize;
  TaskManager := TTaskManager.Create;
  TaskManager.CreateThreads;
  FromHik86Task := TFromHik86Task.Create;
  StartPGThread;
  Timer1.Interval := 60000;
  Timer1.Enabled := True;
end;

procedure TITSDHFSvc.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  FromHik86Task.Free;
  TaskManager.Free;
  uCommon.Finalizat;
end;

procedure TITSDHFSvc.Timer1Timer(Sender: TObject);
begin
  if gHeartbeatUrl<> '' then
    DoHeartbeat;
  if FormatDateTime('nn', now) = '00' then  // 每小时更新
  begin
    logger.Info('reload data');
    if reload then
    begin
      TaskManager.SuspendThreads;
      LoadDevice;
      TaskManager.ResumeThreads;
    end;
    LoadAlarm;
    loadHBC;
    //LoadVeh;
    logger.Info('reload OK');
  end;
end;

procedure TITSDHFSvc.DoHeartbeat;
var
  requestStream: TStringStream;
begin
  requestStream := TStringStream.Create('');
  requestStream.WriteString('ServiceName=ITSDHFSvc');
  try
    IdHTTP1.Post(gHeartbeatUrl + 'ServiceHeartbeat', requestStream);
  except
  end;
  requestStream.Free;
end;

procedure TITSDHFSvc.StartPGThread;
var
  ini: TIniFile;
  sourcePath, targetPath, targetUrl: string;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  sourcePath := ini.ReadString('PGThread', 'SourcePath', '');
  targetPath := ini.ReadString('PGThread', 'TargetPath', '');
  targetUrl := ini.ReadString('PGThread', 'TargetUrl', '');
  ini.Free;
  if sourcePath <> '' then
    pgThread := TPGThread.Create(sourcePath, targetPath, targetUrl);
end;

end.
