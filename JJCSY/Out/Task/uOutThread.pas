unit uOutThread;

interface

uses
  Classes, SysUtils, FireDAC.Comp.Client, FireDAC.Stan.Option, FireDAC.Stan.Def,
  FireDAC.DApt, FireDAC.Stan.Async, FireDAC.Stan.Expr, FireDAC.Stan.Pool,
  IOUtils, Generics.Collections, Variants, DateUtils, uBaseThread, IniFiles,
  uTypes, uGlobal;

type
  TOutThread = class(TBaseThread)
  private
    FConfig: TOraConfig;
    FConn: TFDConnection;
    FQuery: TFDQuery;
    FMaxValue: string;
    FLastTime: Double;
    function GetConn: TFDConnection;
    function QueryDataFromOracle: boolean;
    function GetRecord: string;
    procedure SaveMaxNO;
  protected
    procedure Prepare; override;
    procedure Perform; override;
    procedure AfterTerminate; override;
  public
    constructor Create(config: TOraConfig); overload;
    destructor Destroy; override;
  end;

implementation

{ TOutThread }

constructor TOutThread.Create(config: TOraConfig);
begin
  FConfig := config;
  FConn := GetConn;
  inherited Create;
end;

destructor TOutThread.Destroy;
begin
  FQuery.Free;
  FConn.Free;
  inherited;
end;

procedure TOutThread.Prepare;
begin
  inherited;
  logger.Info(FConfig.Host + ' start' + FConfig.IntervalSecond.ToString);
  FMaxValue := FConfig.MaxOrderFieldValue;
  FLastTime := 0;
end;

procedure TOutThread.AfterTerminate;
begin
  inherited;
  logger.Info(FConfig.Host + ' stoped');
end;

procedure TOutThread.Perform;
var
  lines: TStrings;
  filename: string;
  firstLine: boolean;
begin
  inherited;
  if now - FLastTime < FConfig.IntervalSecond * OneSecond then exit;

  FLastTime := now;
  if QueryDataFromOracle then
  begin
    logger.Info('FQuery.RecordCount = ' + FQuery.RecordCount.ToString);
    if FQuery.RecordCount > 0 then
    begin
      lines := TStringList.Create;
      if FConfig.OrderField = '' then
        lines.Add('Delete ' + FConfig.TableName);
      lines.Add(FConfig.InsertSQL);
      firstLine := true;
      while not FQuery.Eof do
      begin
        if firstLine then
        begin
          lines.Add(GetRecord);
          firstLine := false;
        end
        else
          lines.Add(',' + GetRecord);
        if lines.Count >= 1000 then
        begin
          filename := FConfig.TargetFilePath + 'JJCSY_' + FConfig.TableName + FormatDateTime('yyyymmddhhmmsszzz', now);
          lines.SaveToFile(filename);
          logger.Info('SaveToFile: ' + filename);
          lines.Clear;
          lines.Add(FConfig.InsertSQL);
          firstLine := true;
          sleep(1);
        end;
        if FConfig.OrderField <> '' then
          FMaxValue := FQuery.FieldByName(FConfig.OrderField).AsString;
        FQuery.Next;
      end;

      if lines.Count > 1 then
      begin
        filename := FConfig.TargetFilePath + 'JJCSY_' + FormatDateTime('yyyymmddhhmmsszzz', now);
        lines.SaveToFile(filename);
        logger.Info('SaveToFile: ' + filename);
      end;
      lines.Free;
      if FConfig.OrderField <> '' then
        SaveMaxNo;
    end;
    FQuery.Close;
  end;
end;

function TOutThread.GetConn: TFDConnection;
begin
  result := TFDConnection.Create(nil);
  result.FetchOptions.Mode := fmAll;
  result.Params.Add('DriverID=Ora');
  result.Params.Add
    (Format('Database=(DESCRIPTION = (ADDRESS_LIST = (ADDRESS = (PROTOCOL = TCP)(HOST = %s)(PORT = %s)))'
    + '(CONNECT_DATA = (SERVER = DEDICATED)(SERVICE_NAME = %s)))',
    [FConfig.Host, FConfig.Port, FConfig.Sid]));
  result.Params.Add(Format('User_Name=%s', [FConfig.UserName]));
  result.Params.Add(Format('Password=%s', [FConfig.Password]));
  result.Params.Add('CharacterSet=UTF8'); // ∑Ò‘Ú÷–Œƒ¬“¬Î
  result.LoginPrompt := false;

  FQuery := TFDQuery.Create(nil);
  FQuery.DisableControls;
  FQuery.Connection := result;
end;

function TOutThread.QueryDataFromOracle: boolean;
begin
  result := True;
  FQuery.Close;
  if FConfig.OrderField <> '' then
    FQuery.SQL.Text := Format(FConfig.SelectSQL, [FMaxValue])
  else
    FQuery.SQL.Text := FConfig.SelectSQL;
  try
    FConn.Open;
    FQuery.Open;
  except
    on e: exception do
    begin
      result := false;
      logger.Error('QueryDataFromOracle:' + e.Message + FQuery.SQL.Text);
    end;
  end;
end;

procedure TOutThread.SaveMaxNO;
var
  ini: TIniFile;
begin
  ini:= TIniFile.Create(TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'Config.ini'));
  ini.WriteString(FConfig.TableName, 'MaxOrderFieldValue', FMaxValue);
  ini.Free;
end;

function TOutThread.GetRecord: string;
var
  I: Integer;
begin
  result := FQuery.Fields[0].AsString.QuotedString;
  for I := 1 to FQuery.FieldCount - 1 do
  begin
    result := result + ',' + FQuery.Fields[I].AsString.QuotedString;
  end;
  result := '(' + result + ')';
end;

end.
