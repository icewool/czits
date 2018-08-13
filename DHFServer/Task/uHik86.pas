unit uHik86;

interface

uses
  SysUtils, Classes, System.Generics.Collections, SyncObjs, DateUtils,
  uGlobal, uTypes, IdHttp;

type
  THik86 = class
  private
    FData: TStringStream;
    FCount: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(pass: TPass);
    function Save: boolean;
  end;

var
  Hik86: THik86;

implementation

procedure THik86.Add(pass: TPass);
var
  s: string;
begin
  s := pass.kdbh + #9 + pass.gcsj + #9 + pass.cdbh + #9 + pass.HPHM + #9
    + pass.HPZL + #9 + pass.hpys + #9 + pass.clsd + #9 + pass.FWQDZ +#9
    + pass.tp1 + #9 + pass.tp2 + #9 + pass.tp3 + #9 + pass.WFXW + #13#10;
  FData.WriteString(s);
  Inc(FCount);
end;

function THik86.Save: boolean;
var
  http: TIdHttp;
begin
  result := true;
  logger.Info('[Hik86.Save]' + FCount.ToString);
  if FCount = 0 then exit;
  http := TIdHttp.Create(nil);
  try
    http.Post(gBdrUrl, FData);
  except
    on e: exception do
    begin
      logger.Error('[Hik86.Save]' + e.Message);
      result := false;
    end;
  end;
  http.Free;
end;

constructor THik86.Create;
begin
  FData := TStringStream.Create;
  FCount := 0;
end;

destructor THik86.Destroy;
begin
  FData.Free;
  inherited;
end;

end.
