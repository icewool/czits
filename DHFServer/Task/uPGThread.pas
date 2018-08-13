unit uPGThread;

interface

uses
  Windows, Classes, Types, SysUtils, IOUtils, DateUtils, Generics.Collections,
  Variants, uBaseThread, uTypes, uGlobal, uCommon, UInterface;

type
  TPGThread = class(TBaseThread)
  private
    FSourcePath, FTargetPath, FTargetUrl: string;
    FVioList: TList<TPass>;
    function DealOnePass(pass: TPass): boolean;
    function GetPassList: TList<TPass>;
  protected
    procedure Prepare; override;
    procedure Perform; override;
    procedure AfterTerminate; override;
  public
    constructor Create(SourcePath, TargetPath, TargetUrl: string); overload;
  end;
var
  pgThread: TPGThread;
implementation

{ TPGThread }

constructor TPGThread.Create(SourcePath, TargetPath, TargetUrl: string);
begin
  FSourcePath := SourcePath;
  FTargetPath := TargetPath;
  FTargetUrl := TargetUrl;
  inherited Create;
end;

procedure TPGThread.Prepare;
begin
  inherited;
  logger.Info('PGThread Start');
  FVioList := TList<TPass>.Create;
end;

procedure TPGThread.AfterTerminate;
begin
  inherited;
  FVioList.Free;
  logger.Info('PGThread Stoped');
end;

procedure TPGThread.Perform;
var
  pass: TPass;
  list: TList<TPass>;
begin
  list := GetPassList;
  if list.Count > 0 then
  begin
    logger.Info('PGThread.GetPassList: ' + list.Count.ToString);
    for pass in list do
    begin
      DealOnePass(pass);
    end;
    Tmypint.SaveVIO(FVioList);
  end;
  list.Free;
  Sleep(10 * 60 * 1000);
end;

function TPGThread.GetPassList: TList<TPass>;
var
  fn: string;
  ss: TStringDynArray;
  s: string;
  arr: TArray<String>;
  pass: TPass;
begin
  result := TList<TPass>.Create;
  for fn in TDirectory.GetFiles(FSourcePath, '*.ini') do
  begin
    ss := TFile.ReadAllLines(fn);
    if Length(ss) = 3 then
    begin
      s := ss[2];
      arr := s.Split(['^']);
      if Length(arr) = 13 then
      begin
        pass.kdbh := '44519300001001';
        pass.gcsj := arr[1];
        pass.clsd := arr[6];
        pass.tp1 := arr[11];
        pass.tp2 := arr[12];
        pass.GCXH := TPath.GetFileNameWithoutExtension(fn);
        result.Add(pass);
      end;
    end;
  end;
end;

function TPGThread.DealOnePass(pass: TPass): boolean;
var
  device: TDevice;
  yyyymm, dd, targetPath: string;
begin
  result := true;

  yyyymm := formatdatetime('yyyymm', Now);
  dd := formatdatetime('dd', Now);
  pass.FWQDZ := Format('%s/%s/%s/%s/', [FTargetURL, yyyymm, dd, pass.kdbh]);
  targetPath := Format('%s\%s\%s\%s\', [FTargetPath, yyyymm, dd, pass.kdbh]);

  try
    if not DirectoryExists(targetPath) then
      ForceDirectories(targetPath);
    TFile.Move(FSourcePath + '\' + pass.tp1, targetPath + pass.tp1);
    TFile.Move(FSourcePath + '\' + pass.tp2, targetPath + pass.tp2);
    TFile.Delete(FSourcePath + '\' + pass.GCXH + '.ini');
    device := gDicDevice[pass.KDBH];
    pass.WFXW := Tmypint.getSpeedtoWFXW(pass.HPZL, strtointdef(pass.clsd, 0), device.XZSD);
    FVioList.Add(pass);
  except
    on e: exception do
    begin
      logger.Error('[TPGThread.DealOnePass]' + e.Message);
      result := false;
    end;
  end;
end;

end.
