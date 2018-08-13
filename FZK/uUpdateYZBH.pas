unit uUpdateYZBH;

interface

uses
  FireDAC.Comp.Client, uLogger, System.Generics.Collections, SysUtils, Classes,
  uSQLHelper;

type

  TUpdateYZBH = Class
  private
    class var FConn: TSQLHelper;
    class var FDicYzbh: TDictionary<string, TDictionary<string, string>>;
    class function LoadDicmail()
      : TDictionary<string, TDictionary<string, string>>;
    class function GetYzbh(jc, dz: string): string;
  public
    class procedure Run(conn: TSQLHelper);
  end;

implementation

class procedure TUpdateYZBH.Run(conn: TSQLHelper);
var
  yzbh, sql: String;
  ts: TStrings;
begin
  logger.logging('Start UpdateYZBH', 1);
  FConn := conn;
  FDicYzbh := LoadDicmail();
  ts := TStringList.Create;

  sql := 'select XH, left(HPHM, 1) as sf, ZSXXDZ from [dbo].[T_VIO_Surveil] with(nolock) '
    + ' where GXSJ > dateadd(dd, -15, getdate()) and HPHM > '''' and ZSXXDZ > '''' and ZSXXDZ <> ''Пе'' '
    + ' and (YZBH is null or YZBH='''') order by GXSJ desc ';
  with FConn.Query(sql) do
  begin
    while not Eof do
    begin
      yzbh := GetYzbh(FieldByName('sf').AsString, FieldByName('ZSXXDZ').AsString);
      if yzbh <> '' then
        ts.Add(' update T_VIO_Surveil set YZBH = ' + yzbh.QuotedString + ' where XH = ''' + FieldByName('XH').AsString+'''');

      if ts.Count > 500 then
      begin
        FConn.ExecuteSql(ts.Text);
        ts.Clear;
      end;

      Next;
    end;
    Free;
  end;
  if ts.Count > 0 then
    FConn.ExecuteSql(ts.Text);

  FDicYzbh.Free;
  ts.Free;
  logger.logging('finished UpdateYZBH', 1);
end;

class function TUpdateYZBH.LoadDicmail(): TDictionary<string, TDictionary<string, string>>;
var
  key, CSMC, yzbm: string;
begin
  Result := TDictionary < string, TDictionary < string, string >>.Create();
  with FConn.Query('select * from S_MAIL ') do
  begin
    while not Eof do
    begin
      key := UpperCase(Trim(FieldByName('jc').AsString));
      CSMC := UpperCase(FieldByName('CSMC').AsString);
      yzbm := UpperCase(FieldByName('YZBM').AsString);
      if not Result.ContainsKey(key) then
        Result.Add(key, TDictionary<string, string>.Create);
      if not Result[key].ContainsKey(CSMC) then
        Result[key].Add(CSMC, yzbm);
      Next;
    end;
    Free;
  end;
end;

class function TUpdateYZBH.GetYzbh(jc, dz: string): string;
var
  s: string;
  dicSf: TDictionary<string, string>;
begin
  Result := '';
  if not FDicYzbh.ContainsKey(jc) then
    exit;

  dicSf := FDicYzbh[jc];
  for s in dicSf.Keys do
  begin
    if Pos(s, dz) > 0 then
    begin
      if Result < dicSf[s] then
        Result := dicSf[s];
    end;
  end;
end;

end.
