unit uSavePicThread;

interface

uses
  System.Classes, SysUtils, uGlobal, uCommon;

type
  TSavePicThread = class(TThread)
  private
    function GetPic(url: String; var fileName: String): Boolean;
    function PutPic(fileName, ftpPath: String): Boolean;
    function UpdateVioUrl(id, p1, p2, p3, path: String): Boolean;
  protected
    procedure Execute; override;
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TSavePicThread.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TSavePicThread }

procedure TSavePicThread.Execute;
var
  s, id, p1, p2, p3, fwqdz: String;
  localp1, localp2, localp3, ftpPath: String;
  wfsj: TDatetime;
begin
  gLogger.Info('Resave VioPic Thread Start');
  s := 'select Systemid, WFSJ, FWQDZ, PHOTOFILE1,PHOTOFILE2,PHOTOFILE3 ' +
    ' from T_VIO_HIS where ZT=''8'' and IsReSave=''0''';
  try
    with gSQLHelper.Query(s) do
    begin
      while not Eof do
      begin
        id := Fields[0].AsString;
        wfsj := Fields[1].AsDateTime;
        fwqdz := Trim(Fields[2].AsString);
        p1 := Trim(Fields[3].AsString);
        p2 := Trim(Fields[4].AsString);
        p3 := Trim(Fields[5].AsString);
        if p1 <> '' then
          p1 := fwqdz + p1;
        if p2 <> '' then
          p2 := fwqdz + p2;
        if p3 <> '' then
          p3 := fwqdz + p3;

        if not GetPic(p1, localp1) or not GetPic(p2, localp2) or
          not GetPic(p3, localp3) then
        begin
          Next;
          continue;
        end;

        ftpPath := '/' + FormatDateTime('yyyymmdd', wfsj) + '/';

        if not PutPic(localp1, ftpPath) or not PutPic(localp2, ftpPath) or
          not PutPic(localp3, ftpPath) then
        begin
          Next;
          continue;
        end;

        UpdateVioUrl(id, localp1, localp2, localp3, ftpPath);

        if FileExists(gTempPath + localp1) then
          DeleteFile(gTempPath + localp1);
        if FileExists(gTempPath + localp2) then
          DeleteFile(gTempPath + localp2);
        if FileExists(gTempPath + localp3) then
          DeleteFile(gTempPath + localp3);
        Next;
      end;
      Free;
    end;
  except
    on e: exception do
      gLogger.Error(e.Message);
  end;
  gLogger.Info('Resave VioPic Thread End');
end;

function TSavePicThread.GetPic(url: String; var fileName: String): Boolean;
begin
  Result := True;
  fileName := '';
  if url <> '' then
  begin
    fileName := FormatDateTime('yyyymmddhhnnsszzz', Now()) + '.jpg';
    if not TCommon.DownloadPic(url, gTempPath + fileName) then
    begin
      gLogger.Error('pic Download Error ' + url);
      Result := False;
    end;
  end;
end;

function TSavePicThread.PutPic(fileName, ftpPath: String): Boolean;
begin
  Result := True;
  if fileName <> '' then
  begin
    if not TCommon.UploadPic(gTempPath + fileName, ftpPath + fileName) then
    begin
      gLogger.Error('pic Upload Error ' + ftpPath + fileName);
      Result := False;
    end;
  end;
end;

function TSavePicThread.UpdateVioUrl(id, p1, p2, p3, path: String): Boolean;
var
  s: String;
begin
  s := 'update T_VIO_HIS set IsReSave=''1'', FWQDZ=''' + gRootUrl + path +
    ''', PHOTOFILE1=''' + p1 + ''', PHOTOFILE2=''' + p2 + ''', PHOTOFILE3=''' +
    p3 + ''' where SystemID=''' + id + '''';
  if gSQLHelper.ExecuteSql(s) then
    gLogger.Info('vio pic url modify OK ' + #13#10 + s)
  else
    gLogger.Error('vio pic url modify Error ' + #13#10 + s);
end;

end.
