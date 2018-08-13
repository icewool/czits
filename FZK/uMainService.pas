unit uMainService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, QBAes,
  System.Generics.Collections, uVariants, IniFiles, uLogger,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.OracleDef, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, Vcl.ExtCtrls, FireDAC.Phys.Oracle,
  FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL,
  uDDThread, uExportThread, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP;

type
  TItsFZKService = class(TService)
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    fdphysrcldrvrlnk1: TFDPhysOracleDriverLink;
    Timer1: TTimer;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    IdHTTP1: TIdHTTP;
    Timer2: TTimer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    gHeartbeatUrl: String;
    gHeartbeatInterval: Integer;
    procedure ReadConfig;
    function GetData: TList<TData>;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ItsFZKService: TItsFZKService;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ItsFZKService.Controller(CtrlCode);
end;

function TItsFZKService.GetData: TList<TData>;
var
  ini: TInifile;
  sections: TStrings;
  tbname: string;
  item: TData;
begin
  result := TList<TData>.Create;
  ini := TInifile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');

  oraHost := ini.ReadString('ora', 'host', '');
  oraPort := ini.ReadString('ora', 'port', '');
  oraSID := ini.ReadString('ora', 'sid', '');
  oraUser := ini.ReadString('ora', 'user', '');
  oraPwd := ini.ReadString('ora', 'pwd', '');
  if oraPwd.Length > 30 then
  begin
    oraPwd := QBAes.AesDecrypt(oraPwd, 'lgm1224,./');
    oraPwd := oraPwd.Trim;
  end;

  sqlServer := ini.ReadString('mssql', 'server', '');
  sqlDBName := ini.ReadString('mssql', 'dbname', '');
  sqlUser := ini.ReadString('mssql', 'user', '');
  sqlPwd := ini.ReadString('mssql', 'pwd', '');
  if sqlPwd.Length > 30 then
  begin
    sqlPwd := QBAes.AesDecrypt(sqlPwd, 'lgm1224,./');
    sqlPwd := sqlPwd.Trim;
  end;

  sections := TStringList.Create;
  ini.ReadSections(sections);
  for tbname in sections do
  begin
    if LowerCase(tbname).StartsWith('table') then
    begin
      item.TableName := ini.ReadString(tbname, 'tablename', tbname);
      item.SQL := ini.ReadString(tbname, 'sql', '');
      item.KeyField := ini.ReadString(tbname, 'keyfield', 'xh');
      result.Add(item);
    end;
  end;
  sections.Free;
  ini.Free;
end;

function TItsFZKService.GetServiceController: TServiceController;
begin
  result := ServiceController;
end;

procedure TItsFZKService.ReadConfig;
var
  ini: TInifile;
begin
  ini := TInifile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  FRunTime := ini.ReadString('sys', 'time', '04:00,18:00');
  ExportTime := ini.ReadString('sys', 'ExportTime', '08:00');
  gHeartbeatUrl := ini.ReadString('Heartbeat', 'Url',
    'http://127.0.0.1:20090/');
  gHeartbeatInterval := ini.ReadInteger('Heartbeat', 'Interval', 3);

  if Copy(gHeartbeatUrl, Length(gHeartbeatUrl), 1) <> '/' then
    gHeartbeatUrl := gHeartbeatUrl + '/';
  ini.Free;
end;

procedure TItsFZKService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  logger := TLogger.Create(ExtractFilePath(ParamStr(0)) + 'log\FZK.log');
  ReadConfig;
  Timer2.Interval := gHeartbeatInterval * 60000;
  Timer2.Enabled := True;
  Timer2Timer(nil);
  logger.Info('Service Started');
end;

procedure TItsFZKService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Timer2.Enabled := False;
  logger.Info('Service Stoped');
  logger.Free;
end;

procedure TItsFZKService.Timer1Timer(Sender: TObject);
var
  list: TList<TData>;
  item: TData;
  hhmm: string;
begin
  ReadConfig;
  hhmm := formatdatetime('hh:mm', now);
  if FRunTime.Contains(hhmm) then
  begin
    logger.Info('ISTIMENOW');
    list := GetData;
    for item in list do
    begin
      TDDThread.Create(item);
    end;
    list.Free;
  end
  else if ExportTime.Contains(hhmm) then
  begin
    list := GetData;
    TExportThread.Create;
  end;
end;

procedure TItsFZKService.Timer2Timer(Sender: TObject);
var
  response: TStringStream;
  requestStream: TStringStream;
begin
  response := TStringStream.Create('');
  requestStream := TStringStream.Create('');
  requestStream.WriteString('ServiceName=ItsFZKService');
  try
    IdHTTP1.Post(gHeartbeatUrl + 'ServiceHeartbeat', requestStream, response);
  except
  end;
  requestStream.Free;
  response.Free;
end;

end.
