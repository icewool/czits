program Project1;

uses
  Vcl.Forms,
  Unit1 in 'C:\Users\tangys\Desktop\新建文件夹\Unit1.pas' {Form1},
  LatLngHelper in 'LatLngHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
