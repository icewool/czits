unit uCommon;

interface

uses
  SysUtils, Classes, IniFiles, uGlobal, Rtti, uSQLHelper, uLogger, ADODB,
  System.JSON, DateUtils, syncobjs, System.IOUtils, idFtp, idHttp, idFtpCommon,
  Data.DB, System.Generics.Collections, IdGlobal;

type

  TCommon = Class
  private
    class function ReadConfig(): Boolean;
    class function FtpGetFile(AHost, AUser, APwd, ASourceFile,
      ADestFile: string; APort: Integer; RetrieveTime: Integer = 3): Boolean;
    class function FtpPutFile(AHost, AUser, Apw, ASourceFile, ADestFile: string;
      APort: Integer): Boolean; static;
  public
    class procedure ProgramInit;
    class procedure ProgramDestroy;
    class function DownloadPic(url, fileName: String): Boolean;
    class function UploadPic(SourceFile, DestFile: String): Boolean;
  end;

procedure SQLError(const SQL, Description: string);

implementation

class function TCommon.ReadConfig(): Boolean;
begin
  Result := True;
  with TIniFile.Create(ExtractFilePath(Paramstr(0)) + 'Config.ini') do
  begin
    gDBConfig.DBServer := ReadString('DB', 'Server', '.');
    gDBConfig.DBPort := ReadInteger('DB', 'Port', 1043);
    gDBConfig.DBUser := ReadString('DB', 'User', 'vioadmin');
    gDBConfig.DBPwd := ReadString('DB', 'Pwd', 'lgm1224,./');
    gDBConfig.DBName := ReadString('DB', 'Name', 'YjItsDB');

    gFtpConfig.Host := ReadString('FTP', 'Host', '.');
    gFtpConfig.Port := ReadInteger('FTP', 'Port', 1043);
    gFtpConfig.User := ReadString('FTP', 'User', 'vioadmin');
    gFtpConfig.Password := ReadString('FTP', 'Password', 'lgm1224,./');
    gFtpConfig.Passived := ReadString('FTP', 'Passived', '0') = '1';
    gFtpConfig.Path := ReadString('FTP', 'Path', '');

    gRootUrl := ReadString('Http', 'Url', '');

    gHeartbeatUrl := ReadString('Heartbeat', 'Url', 'http://127.0.0.1:20090/');
    gHeartbeatInterval := ReadInteger('Heartbeat', 'Interval', 3);

    Free;
  end;

  if gRootUrl <> '' then
    if copy(gRootUrl, Length(gRootUrl), 1) = '/' then
      gRootUrl := copy(gRootUrl, 1, Length(gRootUrl) - 1);

  if gFtpConfig.Path <> '' then
    if copy(gFtpConfig.Path, Length(gFtpConfig.Path), 1) = '/' then
      gFtpConfig.Path := copy(gFtpConfig.Path, 1, Length(gFtpConfig.Path) - 1);

  if copy(gHeartbeatUrl, Length(gHeartbeatUrl), 1) <> '/' then
    gHeartbeatUrl := gHeartbeatUrl + '/';
end;

class function TCommon.UploadPic(SourceFile, DestFile: String): Boolean;
begin
  Result := FtpPutFile(gFtpConfig.Host, gFtpConfig.User, gFtpConfig.Password,
    SourceFile, gFtpConfig.Path + DestFile, gFtpConfig.Port);
end;

procedure SQLError(const SQL, Description: string);
begin
  gLogger.Error(Description + #13#10 + SQL);
end;

class procedure TCommon.ProgramInit;
begin
  TCommon.ReadConfig();
  gSQLHelper := TSQLHelper.Create;
  gSQLHelper.DBServer := gDBConfig.DBServer;
  gSQLHelper.DBName := gDBConfig.DBName;
  gSQLHelper.DBUser := gDBConfig.DBUser;
  gSQLHelper.DBPwd := gDBConfig.DBPwd;
  gSQLHelper.OnError := SQLError;
  if not DirectoryExists(ExtractFilePath(Paramstr(0)) + 'log') then
    ForceDirectories(ExtractFilePath(Paramstr(0)) + 'log');
  gLogger := TLogger.Create(ExtractFilePath(Paramstr(0)) + 'log\PicReSave.log');

  gTempPath := ExtractFilePath(Paramstr(0)) + 'temppic\';
  if not DirectoryExists(gTempPath) then
    ForceDirectories(gTempPath);
end;

class function TCommon.DownloadPic(url, fileName: String): Boolean;
var
  ms: TMemoryStream;
  Host, Port, User, pw, Path, urlcn: string;
  idHttp: TIdHTTP;
  idftp1: TIdFTP;
begin
  Result := false;
  if FileExists(fileName) then
    deletefile(PWideChar(fileName));

  if UpperCase(copy(url, 1, 3)) = 'FTP' then
  begin
    try
      Path := copy(url, pos('@', url) + 1, Length(url) - pos('@', url) + 1);
      Path := copy(Path, pos('/', Path), Length(Path));
      Host := copy(url, pos('@', url) + 1, Length(url) - pos('@', url) + 1);
      Host := copy(Host, 1, pos('/', Host) - 1);
      if pos(':', Host) > 0 then
      begin
        Port := copy(Host, pos(':', Host) + 1, 100);
        Host := copy(Host, 1, pos(':', Host) - 1);
      end
      else
        Port := '21';
      User := copy(url, 7, Length(url) - 6);
      User := copy(User, 1, pos(':', User) - 1);
      pw := copy(url, 7, Length(url) - 6);
      pw := copy(pw, pos(':', pw) + 1, Length(pw) - pos(':', pw) + 1);
      pw := copy(pw, 1, pos('@', pw) - 1);
      Result := FtpGetFile(Host, User, pw, Path, fileName,
        StrToIntDef(Port, 21));
    except
      FreeAndNil(idftp1);
      FreeAndNil(ms);

    end;
  end
  else if UpperCase(copy(url, 1, 4)) = 'HTTP' then
  begin
    try
      try
        ms := TMemoryStream.Create;
        ms.Position := 0;
        idHttp := TIdHTTP.Create(nil);
        idHttp.HandleRedirects := True; // 必须支持重定向否则可能出错
        idHttp.ConnectTimeout := 3000; // 超过这个时间则不再访问
        idHttp.ReadTimeout := 3000; //
        urlcn := idHttp.url.URLEncode(url);
        idHttp.Get(urlcn, ms);
        if ms.Size > 0 then
        begin
          ms.SaveToFile(fileName);
          Result := True;
        end;
      finally
        FreeAndNil(idHttp);
        FreeAndNil(ms);
      end;
    except
    end;
  end;
  TThread.Sleep(50);
end;

class function TCommon.FtpGetFile(AHost, AUser, APwd, ASourceFile,
  ADestFile: string; APort, RetrieveTime: Integer): Boolean;
var
  BytesToTransfer, BytesTransfered: Int64;
  stream: TStream;
  i: Integer;
  ftp: TIdFTP;
begin
  Result := false;
  ftp := TIdFTP.Create(nil);
  ftp.ConnectTimeout := 3000;
  ftp.ReadTimeout := 3000;

  ftp.Host := AHost;
  ftp.Username := AUser;
  ftp.Password := APwd;
  ftp.Port := APort;

  ftp.TransferType := ftBinary;

  i := 0;

  if FileExists(ADestFile) then
  begin
    Sleep(3000);
    stream := TFileStream.Create(ADestFile, fmOpenWrite)
  end
  else
    stream := TFileStream.Create(ADestFile, fmCreate);

  while i < RetrieveTime do
  begin
    if not ftp.Connected then
    begin
      try
        ftp.Connect;
        ftp.Get(ASourceFile, stream);
        Result := True;
        break;
      except
        on e: exception do
        begin
          Inc(i);
          stream.Position := 0;
          Sleep(5000);
          continue;
        end;
      end;
    end;
  end;
  stream.Free;
  ftp.Free;
  Result := FileExists(ADestFile);
end;

class function TCommon.FtpPutFile(AHost, AUser, Apw, ASourceFile,
  ADestFile: string; APort: Integer): Boolean;
  function ChangeDir(ftp: TIdFTP; ADir: string): Boolean;
  begin
    Result := false;
    try
      ftp.ChangeDir(ADir);
      Result := True;
    except
      on e: exception do
      begin
        // if e.message.contains('No such file or directory') then // DONE: 待确认
        begin
          ftp.MakeDir(ADir);
          ftp.ChangeDir(ADir);
          Result := True;
        end;
      end;
    end;
  end;

var
  ftp: TIdFTP;
  ss: TArray<string>;
  i, n: Integer;
begin
  // 创建Ftp
  try
    ftp := TIdFTP.Create(nil);
    ftp.ConnectTimeout := 3000;
    ftp.ReadTimeout := 3000;
    ftp.Host := AHost;
    ftp.Port := APort;
    ftp.Username := AUser;
    ftp.Password := Apw;
    ftp.Connect;
    // ShowMessage(ftplist.port);
    ftp.TransferType := ftBinary;
    ftp.IOHandler.DefStringEncoding := IndyTextEncoding(tencoding.Default);

    ss := ADestFile.Split(['/']);
    n := Length(ss);
    for i := 0 to n - 2 do
    begin
      ChangeDir(ftp, ss[i]);
    end;
    ftp.Passive := True; // 这里分为主动和被动
    ftp.Noop;
    ftp.Put(ASourceFile, ss[n - 1], True);
    ftp.Free;
    Result := True;
  except
    Result := false;
  end;

end;

class procedure TCommon.ProgramDestroy;
begin
  gSQLHelper.Free;
  gLogger.Free;
  if DirectoryExists(gTempPath) then
    TDirectory.Delete(gTempPath, True);
end;

end.
