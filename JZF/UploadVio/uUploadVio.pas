unit uUploadVio;

interface

uses
  System.Classes, SysUtils, ActiveX, uGlobal, uRequestItf, uJsonUtils,
  FireDAC.Comp.Client, Generics.Collections;

type
  TUploadVioThread = class(TThread)
  private
    procedure UploadVio(systemid: String);
    procedure GetVio;
  protected
    procedure Execute; override;
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TUploadVioThread.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ TUploadVioThread }

procedure TUploadVioThread.Execute;
begin
  ActiveX.CoInitialize(nil);
  gLogger.Info('Upload Vio Thread Start');
  GetVio();
  gLogger.Info('Upload Vio Thread End');
  ActiveX.CoUninitialize;
end;

procedure TUploadVioThread.GetVio;
var
  s: String;
begin
  s := 'select a.systemid from T_VIO_HIS a inner join S_Device b on a.WFDD = b.SBBH where b.AutoUpload = 1 and a.zt=''2''';
  s := s + ' union ';
  s := s + ' select systemid from T_VIO_HIS where DATEDIFF(DAY, WFSJ, GETDATE()) >= 10 and zt = ''2'' ';
  with gSQLHelper.Query(s) do
  begin
    while not Eof do
    begin
      UploadVio(Fields[0].AsString);
      Next;
    end;
    Free;
  end;
end;

procedure TUploadVioThread.UploadVio(systemid: String);
var
  s: string;
begin
  s := TRequestItf.DbQuery('UploadVio', 'systemid=' + systemid);
  gLogger.Info('[UploadVio] ' + systemid + ',上传结果:' + s);
end;

end.
