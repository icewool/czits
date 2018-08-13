unit uDDThread;

interface

uses
  System.Classes, SysUtils, ActiveX, IniFiles,
  FireDAC.Stan.Option, uLogger,  Vcl.ExtCtrls, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef, FireDAC.Phys.OracleDef, FireDAC.Phys.Oracle, DB, ADODB,
  FireDAC.Stan.Intf, FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Phys, Variants,
  FireDAC.Phys.ODBCBase, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  FireDAC.Stan.Async, FireDAC.Comp.Client, uVariants, uUpdateYZBH, uSQLHelper;

type
  TDataType = (dtVeh, dtDrv, dtVio);

  TDDThread = class(TThread)
  private
    FData: TData;
    FSQLHelper: TSQLHelper;
    FConnOra: TFDConnection;
    function DownLoadData: Boolean;
    function GetConn: boolean;
    function GetFields(tableName: string): string;
    function GetMaxGxsj: double;
    function ImportData(qyOra: TFDQuery): boolean;
    function QueryDataFromOracle: TFDQuery;
    procedure SQLError(const SQL, Description: string);
  protected
    procedure Execute; override;
  public
    constructor Create(AData: TData); overload;
  end;

implementation

{ TDDThread }

constructor TDDThread.Create(AData: TData);
begin
  inherited Create;
  FData := AData;
  FreeOnTerminate := true;
  ActiveX.CoInitialize(nil);
end;

procedure TDDThread.Execute;
begin
  if GetConn then
  begin
    DownLoadData;
    if (UpperCase(FData.TableName) = 'T_VIO_SURVEIL') then
      TUpdateYZBH.Run(FSQLHelper);
  end;
  FConnOra.Free;
end;

function TDDThread.GetConn: boolean;
begin
  result := true;

  FConnOra := TFDConnection.Create(nil);
  FConnOra.Params.Add('DriverID=Ora');
  FConnOra.Params.Add(Format('Database=(DESCRIPTION = (ADDRESS_LIST = ' +
    '(ADDRESS = (PROTOCOL = TCP)(HOST = %s)(PORT = %s)))' +
    '(CONNECT_DATA = (SERVICE_NAME = %s)))', [oraHost, oraPort, oraSID]));
  FConnOra.Params.Add('User_Name=' + oraUser);
  FConnOra.Params.Add('Password=' + oraPwd);
  FConnOra.Params.Add('CharacterSet=UTF8'); // ∑Ò‘Ú÷–Œƒ¬“¬Î
  FConnOra.LoginPrompt := false;

  FSQLHelper := TSQLHelper.Create(sqlServer, sqlDBName, sqlUser, sqlPwd);
  FSQLHelper.OnError := SQLError;
  try
    FConnOra.Open();
  except
    on e: exception do
    begin
      logger.Error('GetConn:' + e.Message);
      result := false;
    end;
  end;

end;

function TDDThread.GetMaxGxsj: double;
var
  s: string;
begin
  s := FSQLHelper.GetSinge('select Max(GXSJ) from ' + FData.TableName);
  if s <> '' then
    result := VarToDatetime(s)
  else
    result := 100;
end;

function TDDThread.QueryDataFromOracle: TFDQuery;
begin
  result := TFDQuery.Create(nil);
  result.DisableControls;
  result.Connection := FConnOra;
  result.SQL.Text := FData.SQL;
  if result.FindParam('gxsj') <> nil then
    result.Params.ParamByName('gxsj').AsDateTime := GetMaxGxsj-0.1;
  try
    logger.Info('QueryDataFromOracle ' + FData.TableName);
    result.Open;
    logger.Info('QueryDataFromOracle OK');
  except
    on e: exception do
    begin
      logger.Error('QueryDataFromOracle:' + e.Message);
    end;
  end;
end;

procedure TDDThread.SQLError(const SQL, Description: string);
begin
  logger.Error(Description + #13 + SQL);
end;

function TDDThread.DownLoadData: Boolean;
var
  qyOra: TFDQuery;
begin
  qyOra := QueryDataFromOracle;

  if not qyOra.Eof then
  begin
    try
      Result:= ImportData(qyOra);
    except
      on e: exception do
      begin
        logger.Error(e.Message);
        Result:= False;
      end;
    end;
  end;
  qyOra.Free;
end;

function TDDThread.GetFields(tableName: string): string;
var
  i: integer;
begin
  result := '';
  with FSQLHelper.Query('select * from ' + tableName + ' where 1=0') do
  begin
    if Active then
    begin
      for i := 0 to FieldCount - 1 do
      begin
        if (uppercase(Fields[i].fieldname) <> 'SYSTEMID') and (uppercase(Fields[i].fieldname) <> 'BZ') then
        begin
          result := result + ',' + Fields[i].fieldname;
        end;
      end;
      result := result.Substring(1);
    end;
    Free;
  end;
end;

function TDDThread.ImportData(qyOra: TFDQuery): boolean;
var
  ss: tstrings;
  SQL, tmpTable, fieldNames, s: string;
  i: integer;
  fieldArr: TArray<string>;
  gxsj: double;
begin
  tmpTable := 'tmp_' + FData.TableName;
  SQL := 'if exists(select 1 from sysobjects where name = ''' + tmpTable + ''')'
     +' drop table ' + tmpTable
     +' select * into ' + tmpTable + ' from ' + FData.TableName + ' where 1=0';
  FSQLHelper.ExecuteSql(SQL);

  SQL := 'if exists(select 1 from syscolumns '
    + 'where object_name(id) = ''' + tmpTable + ''' and name = ''systemid'') '
    + 'alter table ' + tmpTable + ' drop column systemid ';
  FSQLHelper.ExecuteSQL(SQL);

  fieldNames := GetFields(tmpTable);
  fieldArr := fieldNames.Split([',']);
  ss := TStringList.Create;
  while not qyOra.Eof do
  begin
    s := '';
    for i := 0 to length(fieldArr) - 1 do
    begin
      s := s + ',' + qyOra.FieldByName(fieldArr[i]).AsString.QuotedString
    end;
    ss.Add(',(' + s.Substring(1) + ')');
    if ss.Count = 999 then
    begin
      if FSQLHelper.ExecuteSql('insert into ' + tmpTable + '(' + fieldNames + ')values' + ss.Text.Substring(1)) then
        logger.Info('[InsertIntoTmp](' + ss.Count.ToString + ', 0) OK ');
      ss.Clear;
    end;
    qyOra.Next;
  end;

  if ss.Count > 0 then
  begin
    if FSQLHelper.ExecuteSql('insert into ' + tmpTable + '(' + fieldNames + ')values' + ss.Text.Substring(1)) then
      logger.Info('[InsertIntoTmp](' + ss.Count.ToString + ', 0) OK ');

    ss.Clear;
    ss.Add('delete a from ' + FData.TableName + ' a inner join ' + tmpTable + ' b ');
    fieldArr := FData.KeyField.Split([',']);
    for i := 0 to Length(fieldArr) - 1 do
    begin
      if i = 0 then
        ss.Add('on a.' + fieldArr[i] + ' = b.' + fieldArr[i])
      else
        ss.Add(' and a.' + fieldArr[i] + ' = b.' + fieldArr[i]);
    end;
    ss.Add('insert into ' + FData.TableName + '(' + fieldNames + ')');
    ss.Add('select ' + fieldNames + ' from ' + tmpTable);
    if FSQLHelper.ExecuteSql(ss.Text) then
      logger.Info('tmp to data OK ');
  end;

  //FSQLHelper.ExecuteSQL('drop table ' + tmpTable);
  ss.Free;
  result := true;
end;

end.
