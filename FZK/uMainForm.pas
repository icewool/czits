unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, IniFiles, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Comp.Client, Vcl.StdCtrls,
  FireDAC.Stan.Option, uLogger, QBAes, Vcl.ExtCtrls, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.OracleDef, FireDAC.Phys.Oracle,
  FireDAC.Stan.Intf, FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Phys,
  FireDAC.Phys.ODBCBase, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  FireDAC.Stan.Async, uVariants, uDDThread, uExportThread;

type
  TfrmMain = class(TForm)
    Timer1: TTimer;
    Button1: TButton;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    fdphysrcldrvrlnk1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure ReadConfig;
    function GetData: TList<TData>;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

procedure TfrmMain.ReadConfig;
var
  ini: TInifile;
begin
  ini := TInifile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  FRunTime := ini.ReadString('sys', 'time', '04:00,18:00');
  ExportTime := ini.ReadString('sys', 'ExportTime', '08:00');
  ini.Free;
end;

function TfrmMain.GetData: TList<TData>;
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

procedure TfrmMain.Timer1Timer(Sender: TObject);
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

procedure TfrmMain.Button1Click(Sender: TObject);
var
  list: TList<TData>;
  item: TData;
begin
  logger.Info('ISTIMENOW');
  list := GetData;
  for item in list do
  begin
    TDDThread.Create(item);
  end;
  list.Free;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  logger.Free;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
// var
// ini: TInifile;
begin
  // ini := TInifile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  // ini.WriteString('ora', 'pwd', QBAes.AesEncrypt('hczssqg%#65', 'lgm1224,./'));
  // ini.WriteString('mssql', 'pwd', QBAes.AesEncrypt('lgm1224,./', 'lgm1224,./'));
  // ini.Free;
  logger := TLogger.Create(ParamStr(0) + '.log');
  //logger.info(QBAes.AesEncrypt('jyiw04rk', 'lgm1224,./'));

end;

end.
