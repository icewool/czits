unit Unit9;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, uFromHik86Task, IdHttp, FireDAC.Phys.OracleDef,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Stan.Intf,
  FireDAC.Phys, FireDAC.Phys.Oracle, Vcl.StdCtrls, System.NetEncoding,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IOUtils, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdCustomHTTPServer, IdHTTPServer, IdContext;

type
  TForm9 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnInit: TButton;
    FDPhysOracleDriverLink1: TFDPhysOracleDriverLink;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    btnWrite: TButton;
    edtSBBH: TEdit;
    Label1: TLabel;
    edtFXBH: TEdit;
    Label2: TLabel;
    edtXZSD: TEdit;
    Label3: TLabel;
    edtCJJG: TEdit;
    Label4: TLabel;
    edtHPHM: TEdit;
    Label5: TLabel;
    edtHPZL: TEdit;
    Label6: TLabel;
    edtCDBH: TEdit;
    Label7: TLabel;
    edtCLSD: TEdit;
    Label8: TLabel;
    edtHPYS: TEdit;
    Label9: TLabel;
    edtCSYS: TEdit;
    Label10: TLabel;
    edtFWQDZ: TEdit;
    Label11: TLabel;
    edtBABH: TEdit;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    edtTP1: TEdit;
    edtGCSJ: TEdit;
    IdHTTPServer1: TIdHTTPServer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnInitClick(Sender: TObject);
    procedure btnWriteClick(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  private

  public

  end;

var
  Form9: TForm9;

implementation

uses
  uCommon, uTaskManager, uGlobal, UInterface, uTypes, uPGThread, uQTZHelper;

{$R *.dfm}

procedure TForm9.Button1Click(Sender: TObject);
begin
  uCommon.Initialize;
end;

procedure TForm9.Button2Click(Sender: TObject);
begin
  FromHik86Task.Free;
  uCommon.Finalizat;
end;

procedure TForm9.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  s: string;
  stream: TStringStream;
  Params: TStringList;
  ss: TStringList;
begin

  Params := TStringList.Create;
  Params.Delimiter := '&';
  Params.DelimitedText := UTF8ToString(ARequestInfo.UnparsedParams);

  stream := TStringStream.Create;
  (ARequestInfo.PostStream as TMemoryStream).SaveToStream(stream);
  ss := TStringList.Create;
  ss.Delimiter := '&';
  ss.StrictDelimiter := true;
  ss.DelimitedText := stream.DataString;
    Params.AddStrings(ss);
  //s := s + stream.DataString;
  if params.Count = 0 then
    caption := '';
end;

procedure TForm9.btnInitClick(Sender: TObject);
begin
  uCommon.Initialize;
  FromHik86Task := TFromHik86Task.Create;
end;

procedure TForm9.btnWriteClick(Sender: TObject);
var
  ss: TMemoryStream;
  stream: TStringStream;
  data: string;
begin
  TQTZHelper.QTZUrl := 'http://localhost/';//'http://10.43.255.8:20088/';
  ss := TMemoryStream.Create;
  ss.LoadFromFile('c:\a.jpg');        //‘¡U05470
  stream := TStringStream.Create;
  TNetEncoding.Base64.Encode(ss, stream);
  data := stream.DataString;
  TQTZHelper.Surscreen('sbbh','','3','02','hphm','445100','wfdd','lddm','ddms','wfdz','wfsj','','wfxw','','',1,'',data,data,'','');
end;

end.
