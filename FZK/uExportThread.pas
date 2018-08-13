unit uExportThread;

interface

uses
  System.Classes, SysUtils, ActiveX, IniFiles, IOUtils,
  FireDAC.Stan.Option, uLogger, QBAes, Vcl.ExtCtrls, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.OracleDef, FireDAC.Phys.Oracle,
  FireDAC.Stan.Intf, FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Phys,
  FireDAC.Phys.ODBCBase, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  FireDAC.Stan.Async, FireDAC.Comp.Client, uVariants, System.zip;

type
  TExportThread = class(TThread)
  private
    FPath: string;
    veh, drv, sur, dev, hbc: boolean;
    FConnSQL: TFDConnection;
    function ConnectDbServer: boolean;
    procedure DisConnectDbServer;
    procedure ExportTable(tblName, sql: string);
    procedure Encrypt;
    procedure ReadConfig;
  protected
    procedure Execute; override;
  public
    constructor Create; overload;
  end;

implementation

{ TExportThread }

constructor TExportThread.Create;
begin
  inherited Create;
  FreeOnTerminate := true;
  ActiveX.CoInitialize(nil);
end;

procedure TExportThread.Execute;
var
  sql: string;
begin
  logger.Info('ExportThread start');
  ReadConfig;
  if ConnectDbServer then
  begin
    FPath := ExtractFilePath(ParamStr(0)) + 'its';
    TDirectory.CreateDirectory(FPath);
    if veh then
    begin
      sql := 'select HPHM,HPZL,CLPP1,CLXH,CLPP2,GCJK,ZZG,ZZCMC,CLSBDH,FDJH,CLLX,'
        + 'CSYS,SYXZ,SFZMHM,SFZMMC,SYR,SYQ,CCDJRQ,DJRQ,YXQZ,FZJG,FPRQ,FZRQ,FDJRQ,'
        + 'FHGZRQ,BXZZRQ,BPCS,BZCS,BDJCS,DJZSBH,DABH,XZQH,ZT,ZSXZQH,ZSXXDZ,YZBM1,'
        + 'LXDH,ZZXZQH,ZZXXDZ,YZBM2,SJHM,QZBFQZ,GXSJ,HBDBQK ' +
        'from T_VIO_VEHICLE';
      ExportTable('T_VIO_VEHICLE', sql);
    end;

    if drv then
    begin
      sql := 'select SFZMHM,ZJCX,FZRQ,XM,XB,CSRQ,DJZSXXDZ,LXZSXXDZ,LXZSYZBM,' +
        'LXDH,SJHM,ZZZM,YXQS,YXQZ,GXSJ,ZT from T_VIO_DRIVINGLICENSE';
      ExportTable('T_VIO_DRIVINGLICENSE', sql);
    end;

    if sur then
    begin
      sql := 'select a.XH,HPHM,HPZL,JDCSYR,WFXW,WFSJ,WFDZ,CLJGMC,JKBJ,FDJH,' +
        'CLSBDH,CSYS,CLPP,JTFS,FZJG,ZQMJ,ZSXZQH,ZSXXDZ,a.GXSJ,CLJG,WFXWMC,b.JF,b.JE as FKJE '
        + 'from T_VIO_SURVEIL a ' +
        'left join T_VIO_ILLECODE b on a.WFXW=b.WFXWDM';
      ExportTable('T_VIO_SURVEIL', sql);
    end;

    if dev then
    begin
      sql := 'select SBBH,SBDDMC,SBJD,SBWD,SBLX,CJJG from S_DEVICE where qyzt=''1'' and cjjg like ''4451%''';
      ExportTable('S_DEVICE', sql);
    end;

    if hbc then
    begin
      sql := 'select CJJG,HPHM,HPZL,CLPP,CLXH,FDJH,CLSBDH,JDCSYR,SJHM,ZSXXDZ,CCDJRQ,YXQX,BFQX,HBDBQK,BZ,GXSJ from T_HBC';
      ExportTable('T_HBC', sql);
    end;

    DisConnectDbServer;
    Encrypt;
  end;
  logger.Info('ExportThread finished');
end;

procedure TExportThread.ReadConfig;
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');
  veh := ini.ReadInteger('Export', 'veh', 1) = 1;
  drv := ini.ReadInteger('Export', 'drv', 1) = 1;
  sur := ini.ReadInteger('Export', 'sur', 1) = 1;
  dev := ini.ReadInteger('Export', 'dev', 1) = 1;
  hbc := ini.ReadInteger('Export', 'hbc', 1) = 1;
  ini.Free;
end;

procedure TExportThread.Encrypt;
var
  filename: string;
  stream: TFileStream;
  bytes: TBytes;
begin
  filename := FPath + '.dat';
  TZipFile.ZipDirectoryContents(filename, FPath);
  { stream := TFileStream.Create(filename, fmOpenReadWrite);
    SetLength(bytes, 1);
    bytes[0] := 0;
    stream.Write(bytes, 0, 1);
    stream.Seek(0, TSeekOrigin.soEnd);
    stream.Write(bytes, 0, 1);
    stream.Free; }
  try
    TDirectory.Delete(FPath, true);
  except
    on e: exception do
      logger.Error(e.Message);
  end;
end;

function TExportThread.ConnectDbServer: boolean;
begin
  result := true;

  FConnSQL := TFDConnection.Create(nil);
  FConnSQL.Params.Add('DriverID=MSSQL');
  FConnSQL.Params.Add('Server=' + sqlServer);
  FConnSQL.Params.Add('Database=' + sqlDBName);
  FConnSQL.Params.Add('User_Name=' + sqlUser);
  FConnSQL.Params.Add('Password=' + sqlPwd);
  FConnSQL.Params.Add('CharacterSet=UTF8'); // ∑Ò‘Ú÷–Œƒ¬“¬Î
  FConnSQL.LoginPrompt := false;

  try
    FConnSQL.Open();
  except
    on e: exception do
    begin
      FConnSQL.Free;
      logger.Error('ConnectSQL:' + e.Message);
      result := false;
    end;
  end;
end;

procedure TExportThread.DisConnectDbServer;
begin
  FConnSQL.Free;
end;

procedure TExportThread.ExportTable(tblName, sql: string);
var
  qy: TFDQuery;
  i: Integer;
  s: string;
  ss: TStrings;
begin
  logger.Info('ExportTable_ ' + tblName);
  qy := TFDQuery.Create(nil);
  qy.DisableControls;
  qy.Connection := FConnSQL;
  qy.sql.Add(sql);
  try
    qy.Open;
    ss := TStringList.Create;
    while not qy.Eof do
    begin
      s := '';
      for i := 0 to qy.FieldCount - 1 do
      begin
        s := s + #9 + qy.Fields[i].AsString;
      end;
      ss.Add(s.Substring(1));
      qy.Next;
    end;
    ss.SaveToFile(FPath + '\' + tblName);
    ss.Free;
  except
    on e: exception do
    begin
      logger.Error('ExportTable:' + e.Message);
    end;
  end;
end;

end.
