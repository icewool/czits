unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm3 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation
uses uCommon,udbservice,urmservice;
{$R *.dfm}

procedure TForm3.FormCreate(Sender: TObject);
begin

  TCommon.ProgramInit;
  DbService := TDbService.Create;
  RmService := TRmService.Create;
end;

end.
