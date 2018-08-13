unit uInThread;

interface

uses
  Classes, SysUtils, IOUtils, Generics.Collections, Variants, DateUtils, Types,
  uBaseThread, uGlobal, uCommon;

type
  TInThread = class(TBaseThread)
  protected
    procedure Prepare; override;
    procedure Perform; override;
    procedure AfterTerminate; override;
  end;

implementation

{ TInThread }

procedure TInThread.Prepare;
begin
  inherited;
  FSleep := gIntervalSecond * 1000;
  logger.Info('Scan Thread start');
end;

procedure TInThread.AfterTerminate;
begin
  inherited;
  logger.Info('Scan Thread stoped');
end;

procedure TInThread.Perform;
var
  fileItem: string;
  records: TStringDynArray;
  sql: TStrings;
begin
  inherited;
  for fileItem in TDirectory.GetFiles(gFilePath) do
  begin
    if TPath.GetFileName(fileItem).StartsWith('JJCSY_') then
    begin
      logger.Info(fileItem);
      Sleep(1000); // 等待文件写入结束
      sql := TStringList.Create;
      try
        sql.LoadFromFile(fileItem);
        sqlhelper.ExecuteSql(sql.Text);
        TFile.Delete(fileItem);
      except
        on e: exception do
        begin
          logger.Error(e.Message);
        end;
      end;
      sql.Free;
    end;
  end;
end;

end.
