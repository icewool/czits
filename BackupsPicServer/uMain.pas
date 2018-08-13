unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdExplicitTLSClientServerBase, IdFTP, IdFTPCommon, IniFiles;

type
  TfrmMain = class(TForm)
    Timer1: TTimer;
    btnSwitch: TButton;
    procedure btnSwitchClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure SaveUpdateTime(ATime: String);
    procedure UpdateVioUrl(ASystemID, AUrl: String);
    function GetPic(picSer, picfn, savefn: String): Boolean;
    function FtpGetFile(AHost, AUser, APwd, ASourceFile, ADestFile: string;
      APort: integer; RetrieveTime: integer = 3): boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation
uses uGlobal;

{$R *.dfm}

procedure TfrmMain.btnSwitchClick(Sender: TObject);
begin
  if btnSwitch.Caption = '启动' then
  begin
    if (gUrlRoot = '') or (gBakPath = '') then
    begin
      ShowMessage('请配置Config文件后重启程序');
      exit;
    end;
    btnSwitch.Caption:= '停止';
    Timer1.Enabled:= True;
    Timer1Timer(nil);
  end
  else
  begin
    btnSwitch.Caption:= '启动';
    Timer1.Enabled:= False;
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  s: String;
  picSer, picfn, savefn, YYMMDD, url: String;
begin
  Timer1.Enabled:= False;
  s:= 'select SYSTEMID, FWQDZ, PHOTOFILE1, GXSJ, WFSJ from T_VIO_HIS where (ZT = ''8'' or ZT = ''12'') ';
  if gUpdateTime <> '' then
    s:= s + ' and GXSJ > ' + gUpdateTime.QuotedString;
  s:= s + ' order by GXSJ desc ';

  with gSQLHelper.Query(s) do
  begin
    if RecordCount > 0 then
      SaveUpdateTime(FieldByName('GXSJ').AsString);

    while not Eof do
    begin
      YYMMDD:= FormatDatetime('yyymm\dd', FieldByName('WFSJ').AsDateTime);
      if not DirectoryExists(gBakPath + YYMMDD) then
        ForceDirectories(gBakPath + YYMMDD);

      picSer:= FieldByName('FWQDZ').AsString;
      picfn:= FieldByName('PHOTOFILE1').AsString;
      savefn:= gBakPath + YYMMDD + '\' + FieldByName('PHOTOFILE1').AsString;
      if GetPic(picSer, picfn, savefn) then
      begin
        url:= gUrlRoot + StringReplace(YYMMDD, '\', '/', [rfReplaceAll]) + '/';
        UpdateVioUrl(FieldByName('SYSTEMID').AsString, url);
      end;
      Next;
    end;
    Free;
  end;
  Timer1.Enabled:= True;
end;

procedure TfrmMain.UpdateVioUrl(ASystemID, AUrl: String);
begin
  gSQLHelper.ExecuteSql('update T_VIO_HIS set FWQDZ = ' + AUrl.QuotedString + ' where SYSTEMID = ' + ASystemID.QuotedString);
end;

Function TfrmMain.GetPic(picSer, picfn, savefn: String): Boolean;
var
  host, port, user, pw, path:string;
  urlcn, url:String;
  ms: TMemoryStream;
  idhttp: TIdHTTP;
begin
  Result:=False;
  url:= picSer + picfn;
  if FileExists(savefn) then DeleteFile(PWideChar(savefn));
  if UpperCase(Copy(url, 1, 3)) = 'FTP' then
  begin
    try
      path:= Copy(url, Pos('@', url) + 1, Length(url) - Pos('@', url) + 1);
      path:= Copy(path, Pos('/',path), Length(path));
      host:= Copy(url, Pos('@',url) + 1, Length(url) - Pos('@',url) + 1);
      host:= copy(host, 1, Pos('/', host) - 1);
      if Pos(':', host) > 0 then
      begin
        port:= Copy(host, Pos(':', host) + 1, 100);
        host:= Copy(host, 1, Pos(':', host) - 1);
      end
      else
        port:= '21';

      user:= Copy(url, 7, Length(url) - 6);
      user:= Copy(user, 1, Pos(':',user) - 1);
      pw:= Copy(url, 7, Length(url) - 6);
      pw:= Copy(pw, Pos(':', pw) + 1, Length(pw) - Pos(':', pw) + 1);
      pw:= Copy(pw, 1, Pos('@', pw) - 1);
      Result:= FtpGetFile(host, user, pw, path, savefn, StrToInt(port));
    except
     Result:=False;
    end;
  end
  else if UpperCase(Copy(url, 1, 4)) = 'HTTP' then
  begin
    try
      ms:=TMemoryStream.Create;
      ms.Position:=0;
      idhttp:=TIdHTTP.Create(nil);
      idhttp.HandleRedirects:= True; //必须支持重定向否则可能出错
      idhttp.ConnectTimeout:= 3000; //超过这个时间则不再访问
      idhttp.ReadTimeout:= 3000;//
      urlcn :=idhttp.URL.URLEncode(url) ;
      idhttp.Get(urlcn, ms);
      ms.SaveToFile(savefn);
      FreeAndNil(idhttp);
      FreeAndNil(ms);
      Result:=true;
    except
      Result:=False;
    end;
  end;
end;

procedure TfrmMain.SaveUpdateTime(ATime: String);
begin
  with TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini') do
  begin
    WriteString('Config', 'UpdateTime', ATime);
    Free;
  end;
  gUpdateTime:= ATime;
end;

function TfrmMain.FtpGetFile(AHost, AUser, APwd, ASourceFile, ADestFile: string;
  APort, RetrieveTime: integer): boolean;
var
  BytesToTransfer, BytesTransfered: Int64;
  stream : TStream;
  i: integer;
  ftp: TIdFtp;
begin
  result := false;
  ftp:= TIdFtp.Create(nil);
  ftp.ConnectTimeout:=3000;
  ftp.ReadTimeout:=3000;

  ftp.Host := AHost;
  ftp.Username := AUser;
  ftp.Password := APwd;
  ftp.Port := APort;

  ftp.TransferType := ftBinary;

  i := 0;

  if FileExists(ADestFile) then
    stream := TFileStream.Create(ADestFile, fmOpenWrite)
  else
    stream := TFileStream.Create(ADestFile, fmCreate);

  while i < RetrieveTime do
  begin
    if not ftp.Connected then
    begin
      try
        ftp.Connect;
        ftp.Get(ASourceFile, stream);
        Result:= True;
        break;
      except
        on e: exception do
        begin
          inc(i);
          stream.Position := 0;
          Sleep(5000);
          continue;
        end;
      end;
    end;
  end;
  stream.Free;
  ftp.Free;
  result := FileExists(ADestFile);
end;

end.
