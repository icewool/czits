unit uSvcMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, Vcl.ExtCtrls, uCommon, uInThread;

type
  TitsJJCSYSvc = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    inThread: TInThread;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  itsJJCSYSvc: TitsJJCSYSvc;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  itsJJCSYSvc.Controller(CtrlCode);
end;

function TitsJJCSYSvc.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TitsJJCSYSvc.ServiceStart(Sender: TService; var Started: Boolean);
begin
  uCommon.Initialize;
  inThread := TInThread.Create;
end;

procedure TitsJJCSYSvc.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  inThread.Terminate;
  while not inThread.Finished do
  begin
    Sleep(1000);
  end;
  inThread.Free;
  uCommon.Finalizat;
end;

end.
