unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  Vcl.ExtCtrls, uCommon, uGlobal, uSavePicThread;

type
  TItsPicReSaveService = class(TService)
    Timer1: TTimer;
    IdHTTP1: TIdHTTP;
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure Timer2Timer(Sender: TObject);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  ItsPicReSaveService: TItsPicReSaveService;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  ItsPicReSaveService.Controller(CtrlCode);
end;

function TItsPicReSaveService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TItsPicReSaveService.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
  TCommon.ProgramInit;
  Timer1.Interval := gHeartbeatInterval * 60000;
  Timer1Timer(nil);
  Timer1.Enabled := True;
  Timer2.Enabled := True;
  gLogger.Info('Service Started');
end;

procedure TItsPicReSaveService.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  Timer1.Enabled := False;
  Timer2.Enabled := False;
  gLogger.Info('Service Stoped');
  TCommon.ProgramDestroy;
end;

procedure TItsPicReSaveService.Timer1Timer(Sender: TObject);
var
  response: TStringStream;
  requestStream: TStringStream;
begin
  response := TStringStream.Create('');
  requestStream := TStringStream.Create('');
  requestStream.WriteString('ServiceName=' + self.Name);
  try
    IdHTTP1.Post(gHeartbeatUrl + 'ServiceHeartbeat', requestStream, response);
  except
  end;
  requestStream.Free;
  response.Free;
end;

procedure TItsPicReSaveService.Timer2Timer(Sender: TObject);
begin
  if FormatDatetime('hhnn', Now()) = '0300' then
  begin
    if gRootUrl = '' then
    begin
      gLogger.Error('Url Root is not Config');
      Exit;
    end;
    TSavePicThread.Create(False);
  end;
end;

end.
