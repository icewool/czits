unit uDaoFengSender;

interface

uses
  SysUtils, Classes, System.Generics.Collections, SyncObjs, DateUtils,
  uGlobal, uTypes, uHikDaoFeng;

type
  TDaoFengSender = class
  private
    cs: TCriticalSection;
    FLastTime: Double;
    FList: TList<TPass>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Send(pass: TPass);
  end;

var
  DaoFengSender: TDaoFengSender;

implementation
uses
  uInterface;
procedure TDaoFengSender.Send(pass: TPass);
var
  tmp: TList<TPass>;
  hik: THik;
begin
  if gHikConfig.DFUrl = '' then exit;
  cs.Enter;
  FList.Add(pass);
  if (FList.Count >= 250)or(now - FLastTime > OneSecond * 5) then
  begin
    FLastTime := now;
    tmp := FList;
    FList := TList<TPass>.Create;  // 避免阻塞所有线程
    cs.Leave;
    hik := THik.Create;
    hik.DFCreateImageJob(tmp);
    hik.Free;
    tmp.Free;
  end
  else
    cs.Leave;
end;

constructor TDaoFengSender.Create;
begin
  cs := TCriticalSection.Create;
  FList := TList<TPass>.Create;
  FLastTime := now;
end;

destructor TDaoFengSender.Destroy;
begin
  if FList.Count >= 0 then
  begin
    Tmypint.SavePass(FList);
  end;
  FList.Free;
  cs.Free;
  inherited;
end;

end.
