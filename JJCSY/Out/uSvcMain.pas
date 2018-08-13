unit uSvcMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, uCommon, uTaskManager,
  FireDAC.Phys.OracleDef, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI,
  FireDAC.Stan.Intf, FireDAC.Phys, FireDAC.Phys.Oracle, Vcl.ExtCtrls;

type
  TJJCSYSvc = class(TService)
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
  public
    function GetServiceController: TServiceController; override;
  end;

var
  JJCSYSvc: TJJCSYSvc;

implementation

{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  JJCSYSvc.Controller(CtrlCode);
end;

function TJJCSYSvc.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TJJCSYSvc.ServiceStart(Sender: TService; var Started: Boolean);
begin
  uCommon.Initialize;
  TaskManager := TTaskManager.Create;
  TaskManager.CreateThreads;
end;

procedure TJJCSYSvc.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  TaskManager.Free;
  uCommon.Finalizat;
end;

end.
