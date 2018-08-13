unit uLogUploadThread;

interface

uses
  System.Classes, SysUtils, Generics.Collections, DateUtils, ActiveX, IniFiles,
  IdHttp, uGlobal, NetEncoding;

type
  TLogUploadThread = class(TThread)
  private
    function SendData(url, token: string; data: TStream): boolean;
    function GetToken(url, user, pwd: string): string;
    function HttpPost(url, token: string; data: TStream): string;
    function GetLogData: TStringStream;
    function GetMaxGXSJ: double;
    procedure SetMaxGXSJ(gxsj: double);
    function GetFormatParam(s: string): string;
  protected
    procedure Execute; override;
  end;

implementation
const size = 1024000;
{ TLogUploadThread }

procedure TLogUploadThread.Execute;
var
  data: TStringStream;
  token: string;
  b: boolean;
begin
  ActiveX.CoInitialize(nil);
  self.FreeOnTerminate := true;
  gLogger.Info('LogUploadThread Start');
  token := GetToken(gLogUploadConfig.LoginUrl, gLogUploadConfig.Username, gLogUploadConfig.Password);
  if token <> '' then
  begin
    b := true;
    while b do
    begin
      data := GetLogData;
      b := data <> nil;
      if b then
      begin
        SendData(gLogUploadConfig.UploadUrl, token, data);
        data.Free;
      end;
    end;
  end;
  gLogger.Info('LogUploadThread End');
end;

function TLogUploadThread.GetMaxGXSJ: double;
begin
  with TIniFile.Create(ExtractFilePath(Paramstr(0)) + 'Config.ini') do
  begin
    result := ReadFloat('LogUpload', 'MaxGXSJ', Now-0.01);
    Free;
  end;
end;

procedure TLogUploadThread.SetMaxGXSJ(gxsj: double);
begin
  with TIniFile.Create(ExtractFilePath(Paramstr(0)) + 'Config.ini') do
  begin
    WriteFloat('LogUpload', 'MaxGXSJ', gxsj);
    Free;
  end;
end;

function TLogUploadThread.GetLogData: TStringStream;
var
  gxsj: double;
  sql, s: string;
  data: TStringStream;
  i: integer;
begin
  result := nil;
  gxsj := GetMaxGXSJ;
  sql := 'select top 10 a.*,b.SFZHM from QTZ3TEST.DBO.S_QTZ_Log a left join YJITSDB.dbo.S_USER b on a.YHBH=b.YHBH where a.gxsj>'''
    + FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', gxsj)
    + ''' order by gxsj';
  with gSQLHelper.Query(sql) do
  begin
    if (not EOF) and (RecordCount = 10) then
    begin
      data := TStringStream.Create('', TEncoding.UTF8);
      data.WriteString('[');
      while not EOF do
      begin
        if not BOF then
          data.WriteString(',');
        gxsj := FieldByName('GXSJ').AsDateTime;

        data.WriteString('{"policeId":"' + FieldByName('yhbh').AsString + '"');
        data.WriteString(',"cardNo":"' + FieldByName('SFZHM').AsString + '"');
        data.WriteString(',"sessionId":"' + FieldByName('token').AsString + '"');
        data.WriteString(',"terminalIp":"' + gLogUploadConfig.TerminalIP + '"'); // deviceid  ' + FieldByName('ip').AsString + '
        data.WriteString(',"source":"' + gLogUploadConfig.Source + '"');
        if LowerCase(FieldByName('action').AsString) = '/login' then
          data.WriteString(',"logType":"0"')
        else if LowerCase(FieldByName('action').AsString).StartsWith('/save') then
          data.WriteString(',"logType":"2"')
        else
          data.WriteString(',"logType":"1"');
        data.WriteString(',"module":"' + FieldByName('action').AsString + '"');

        s := FieldByName('Param').AsString;
        s := GetFormatParam(s);
        data.WriteString(',"formatParam":"' + s + '"');

        data.WriteString(',"url":"http://' + FieldByName('ip').AsString
          + ':17115' + FieldByName('action').AsString + '"');

        s := FieldByName('result').AsString;
        i := s.IndexOf('body');
        if i > 200 then
        begin
          s := '{"head":{"code":"1","message":"success","totalnum":"0","currentpage":"1","pagesize":"1"}}';
        end
        else if i > 0 then
        begin
          s := s.Substring(0, i - 2);
          s := s + '}';
        end;
        s := s.Replace('"head":', '"头":');
        s := s.Replace('"code":', '"编码":');
        s := s.Replace('"message":', '"消息":');
        s := s.Replace('"totalnum":', '"总数":');
        s := s.Replace('"currentpage":', '"当前页":');
        s := s.Replace('"pagesize":', '"每页条数":');
        s := s.Replace('"', '\"');
        data.WriteString(',"response":"' + s + '"');
        data.WriteString(',"responseType":"1"');

        if FieldByName('valid').AsBoolean then
          data.WriteString(',"result":"' + '成功' + '"')
        else begin
          data.WriteString(',"result":"' + '失败' + '"');
          data.WriteString(',"errorCode":"1000"');
        end;

        data.WriteString(',"time":' + dateUtils.MilliSecondsBetween(gxsj,25569.33333333).ToString + '}');
        if data.Size > size then
        begin
          break;
        end;
        Next;
      end;
      data.WriteString(']');
      SetMaxGXSJ(gxsj);
      result := data;
    end;
    Free;
  end;
end;

function TLogUploadThread.GetFormatParam(s: string): string;
var
  key, value: string;
  ss: TStringList;
  i: integer;
  first: boolean;
begin
  first := true;
  result := '{';
  if s <> '' then
  begin
    ss := TStringList.Create;
    ss.Delimiter := '&';
    ss.DelimitedText := s;
    for i := 0 to ss.Count - 1 do
    begin
      key := ss.Names[i];
      value := ss.Values[key];
      if gActionParam.ContainsKey(key) then
      begin
        key := gActionParam[key];
        if not first then
          result := result + ',';
        result := result + '\"' + key + '\":\"' + value + '\"';
        first := false;
      end;
    end;
    ss.Free;
  end;
  result := result + '}';
end;

function TLogUploadThread.HttpPost(url, token: string; data: TStream): string;
var
  http: TIdHttp;
begin
  result := '';
  http := TIdHttp.Create(nil);
  http.HTTPOptions := [];
  if token <> '' then
    http.Request.CustomHeaders.AddValue('token', token);
  http.Request.CustomHeaders.AddValue('Content-type', 'application/json');
  try
    result := http.Post(url, data);
  except
    on e: exception do
    begin
      gLogger.Error('[TLogUploadThread.HttpPost]' + e.Message);
      if data is TStringStream then
        gLogger.Error(TStringStream(data).DataString);
    end;
  end;
  http.Free;
end;

function TLogUploadThread.SendData(url, token: string; data: TStream): boolean;
var
  resp: string;
begin
  resp := HttpPost(url, token, data);
  result := resp.Contains('"code":"1"');
  if not result then
    gLogger.Error('[TLogUploadThread.SendData]' + resp);
end;

function TLogUploadThread.GetToken(url, user, pwd: string): string;
var
  resp: string;
  data: TStringStream;
begin
  result := '';
  data := TStringStream.Create('', TEncoding.UTF8);
  data.WriteString('{"username":"' + user + '","password":"' + pwd + '"}');
  resp := HttpPost(url, '', data);
  data.Free;
  if resp.Contains('"code":"1"') then
  begin
    resp := resp.Substring(resp.IndexOf('result') + 9);
    resp := resp.SubString(0, resp.IndexOf('"'));
    result := resp;
  end
  else
    gLogger.Error('[TLogUploadThread.GetToken]' + resp);
end;

end.
