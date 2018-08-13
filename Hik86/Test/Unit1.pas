unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, IOUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext,
  IdCustomHTTPServer, IdBaseComponent, IdComponent, IdCustomTCPServer, IniFiles,
  IdHTTPServer, Generics.Collections, Types, idhttp,uLogger,
  Vcl.StdCtrls, FireDAC.Phys.OracleDef, FireDAC.UI.Intf,
  FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf, FireDAC.Phys,
  FireDAC.Phys.Oracle, IdUri, uCommon,uLogUploadThread, uGlobal,
  FireDAC.Phys.MSSQLDef, IdTCPConnection, IdTCPClient, Vcl.ExtCtrls,
  FireDAC.Phys.ODBCBase, FireDAC.Phys.MSSQL, System.Net.URLClient,
  System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TItsHik86Service = class(TForm)
    Button1: TButton;
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    fdphysrcldrvrlnk1: TFDPhysOracleDriverLink;
    Timer1: TTimer;
    FDGUIxWaitCursor2: TFDGUIxWaitCursor;
    IdHTTP1: TIdHTTP;
    Timer2: TTimer;
    NetHTTPClient1: TNetHTTPClient;
    IdHTTPServer1: TIdHTTPServer;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure Button2Click(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  ItsHik86Service: TItsHik86Service;

implementation

{$R *.dfm}


procedure TItsHik86Service.Button1Click(Sender: TObject);
begin
  TLogUploadThread.Create(false);
end;

procedure TItsHik86Service.Button2Click(Sender: TObject);
begin
  gLogUploadConfig.UploadUrl := 'http://127.0.0.1:8000';
  idhttpserver1.Active := true;
end;

procedure TItsHik86Service.FormCreate(Sender: TObject);
begin
  TCommon.ProgramInit;
end;

procedure TItsHik86Service.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  bytes: TBytes;
  n: integer;
begin
  n := ARequestInfo.PostStream.Size;
  SetLength(bytes, n);
  ARequestInfo.PostStream.ReadBuffer(bytes, n);
  gLogger.Info(TEncoding.UTF8.GetString(bytes));
end;

end.
