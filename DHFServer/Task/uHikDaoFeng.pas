unit uHikDaoFeng;

interface

uses
  System.Classes, Generics.Collections, IdHTTP, IdURI, SysUtils, uGlobal,
  DateUtils, ActiveX, uTypes, System.Rtti, Xml.XMLIntf, Xml.XMLDoc,
  System.Variants;

type
  THik = class
  private
    FToken: String;
    FConfig: THikDaoFengConfig;
    function DFLogin: String;
    procedure DFLogout;
    function HttPPost(AUrl: String; AParams: TStrings; var AResult: String;
      AEncoding: TEncoding = nil): Boolean;
    function DecodeDFAnalysisOnePicResult(Xml: String): TList<TDFVehInfo>;
    procedure InitVehInfo<T>(rec: Pointer);
    function GetField(const AName: String; fields: TArray<TRttiField>)
      : TRttiField;
  public
    constructor Create;
    destructor Destroy; override;
    function DFCreateImageJob(passList: TList<TPass>): String;
    function GetJobProcess(jobid: String): Integer;
    function DFAnalysisOnePic(Url: String): TList<TDFVehInfo>;
    property Token: String read DFLogin;
    property Config: THikDaoFengConfig read FConfig write FConfig;
  end;

implementation

constructor THik.Create;
begin
  FToken := '';
end;

function THik.DecodeDFAnalysisOnePicResult(Xml: String): TList<TDFVehInfo>;
var
  XMLDoc, DocIntf: IXMLDocument;
  rNode, cNode: IXMLNode;
  I, J: Integer;
  key, value: String;
  veh: TDFVehInfo;
  rrt: TRttiRecordType;
  rField: TRttiField;
  fields: TArray<TRttiField>;
begin
  Result := nil;
  rrt := TRTTIContext.Create.GetType(TypeInfo(TDFVehInfo)).AsRecord;
  fields := rrt.GetFields;
  XMLDoc := TXMLDocument.Create(nil);
  DocIntf := XMLDoc;
  XMLDoc.LoadFromXML(Xml);
  rNode := XMLDoc.ChildNodes.Nodes[0];
  rNode := rNode.ChildNodes.Nodes[0];
  rNode := rNode.ChildNodes.Nodes[0];
  if Trim(rNode.ChildValues['ErrorCode']) = '0' then
  begin
    Result := TList<TDFVehInfo>.Create;
    for I := 0 to rNode.ChildNodes.Count - 1 do
    begin
      if Uppercase(rNode.ChildNodes[I].NodeName) <> Uppercase('stPreProcRet')
      then
        continue;
      InitVehInfo<TDFVehInfo>(@veh);
      cNode := rNode.ChildNodes[I];
      for J := 0 to cNode.ChildNodes.Count - 1 do
      begin
        key := cNode.ChildNodes[J].NodeName;
        if key.Contains('ns2:') then
          key := key.Replace('ns2:', '');
        rField := GetField(key, fields);
        if rField <> nil then
        begin
          if cNode.ChildNodes[J].NodeValue <> null then
            value := cNode.ChildNodes[J].NodeValue
          else
            value := '';
          rField.SetValue(@veh, TValue.From<string>(value));
        end;
      end;
      if veh.nTagID <> '' then
        Result.Add(veh);
    end;
  end;
  XMLDoc := nil;
  DocIntf := nil;
end;

destructor THik.Destroy;
begin
  DFLogout;
  inherited;
end;

function THik.DFAnalysisOnePic(Url: String): TList<TDFVehInfo>;
var
  Params: TStrings;
  s: String;
begin
  Result := nil;
  ActiveX.CoInitializeEx(nil, COINIT_MULTITHREADED);
  Params := TStringList.Create;
  try
    s := '';
    if Token = '' then
      exit;

    Params.Add
      ('<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsdl="http://www.hikvision.com.cn/ver1/ivms/wsdl">');
    Params.Add('   <soap:Header>');
    Params.Add('      <wsdl:HeaderReq>');
    Params.Add('         <wsdl:token>' + Token + '</wsdl:token>');
    Params.Add('         <wsdl:version>1.2</wsdl:version>');
    Params.Add('      </wsdl:HeaderReq>');
    Params.Add('   </soap:Header>');
    Params.Add('   <soap:Body>');
    Params.Add('      <wsdl:PicAnalysisReq>');
    Params.Add('         <wsdl:nDataType>1</wsdl:nDataType>');
    Params.Add('         <wsdl:algorithmType>258</wsdl:algorithmType>');
    Params.Add('         <wsdl:strPicUrl>' + Url + '</wsdl:strPicUrl>');
    Params.Add('         <wsdl:PicData>cid:1211963137164</wsdl:PicData>');
    Params.Add('      </wsdl:PicAnalysisReq>');
    Params.Add('   </soap:Body>');
    Params.Add('</soap:Envelope>');
    if HttPPost(FConfig.DFUrl, Params, s) then
    begin
      Result := DecodeDFAnalysisOnePicResult(s);
    end;
  except
  end;
  Params.Free;
  ActiveX.CoUninitialize;
end;

function THik.DFCreateImageJob(passList: TList<TPass>): String;
  function DecodeDFSubJobResult(Xml: String): String;
  begin
    Result := '';
    if pos('<errorCode>0</errorCode>', Xml) > 0 then
    begin
      if pos('<jobId>', Xml) > 0 then
        Result := Xml.Substring(pos('<jobId>', Xml) + 6);
      if (Result <> '') and (pos('</jobId>', Result) > 0) then
        Result := copy(Result, 1, pos('</jobId>', Result) - 1)
      else
        Result := '';
    end;
  end;
  function URLEncode(s: string): string;
  begin
    result := '';
    try
      result := TIdURI.URLEncode(s);
    except
      on e: exception do
      begin
        logger.Error('[URLEncode]' + e.Message + ' ' + s);
      end;
    end;
  end;
var
  Params: TStrings;
  s, imgStr, passTime: String;
  pass: TPass;
  // formatSetting: TFormatSettings;
begin
  Result := '';
  ActiveX.CoInitializeEx(nil, COINIT_MULTITHREADED);
  if Token = '' then
    exit;
  // formatSetting.TimeSeparator := ':';
  // formatSetting.DateSeparator := '-';
  passTime := IntToStr(DateUtils.MilliSecondsBetween(StrToDateTimeDef(pass.GCSJ,
    now), 25569.3333333333));
  Params := TStringList.Create;

  Params.Add
    ('<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsdl="http://www.hikvision.com.cn/ver1/ivms/wsdl" xmlns:ivms="http://www.hikvision.com.cn/ver1/schema/ivms/">');
  Params.Add('   <soap:Header>');
  Params.Add('      <wsdl:HeaderReq>');
  Params.Add('         <wsdl:token>' + FToken + '</wsdl:token>');
  Params.Add('         <wsdl:version>1.2</wsdl:version>');
  Params.Add('      </wsdl:HeaderReq>');
  Params.Add('   </soap:Header>');
  Params.Add('   <soap:Body>');
  Params.Add('      <wsdl:SubmitJobReq>');
  Params.Add('         <wsdl:jobInfo>');
  Params.Add('            <ivms:jobName>job_' +
    FormatDateTime('yyyymmddhhnnsszzz', now()) + '</ivms:jobName>');
  Params.Add('            <ivms:jobType>2</ivms:jobType>');
  Params.Add('            <ivms:dataSourceType>2</ivms:dataSourceType>');
  Params.Add('            <ivms:priority>30</ivms:priority>');
  Params.Add('            <ivms:source>test111</ivms:source>');
  Params.Add('            <ivms:algorithmType>770</ivms:algorithmType>');
  Params.Add('            <!--1 or more repetitions:-->');
  Params.Add('            <ivms:destinationInfos>');
  Params.Add('               <ivms:destinationUrl>' + FConfig.K08SaveUrl +
    '</ivms:destinationUrl>');
  Params.Add('               <ivms:destinationType>11</ivms:destinationType>');
  // Params.Add('               <ivms:destinationType>17</ivms:destinationType>');

  Params.Add('            </ivms:destinationInfos>');
  Params.Add('            <ivms:streamInfo>');
  Params.Add('               <ivms:streamType>2</ivms:streamType>');
  imgStr := '               <ivms:streamUrl>images://{"imageInfos":	[';
  for pass in passList do
  begin
    s := URLEncode(pass.FWQDZ + pass.TP1);
    if s <> ''then
    begin
      imgStr := imgStr + '{"data":"' + s + '",' +
        '"dataType":1,"id":"dddddddddddddd","LaneNO":1,"plate":"' + pass.HPHM +
        '","vehicleDir":0,' + '"targetAttrs":"{\n\t\"crossing_id\":\t\"' +
        gDicDevice[pass.KDBH].ID + '\",\n\t\"pass_id\":\t\"' + pass.GCXH +
        '\",\n\t\"lane_no\":\t\"' + pass.CDBH + '\",\n\t\"pass_time\":\t\"' +
        passTime + '\"\n}"},';
    end;
  end;
  imgStr := copy(imgStr, 1, Length(imgStr) - 1) +
    '],"operate":524287,"targetNum":1,"plateRegMode":	0}</ivms:streamUrl>';
  Params.Add(imgStr);
  Params.Add('               <ivms:smart>false</ivms:smart>');
  Params.Add('               <ivms:maxSplitCount>0</ivms:maxSplitCount>');
  Params.Add('               <ivms:splitTime>0</ivms:splitTime>');
  Params.Add('            </ivms:streamInfo>');
  Params.Add('         </wsdl:jobInfo>');
  Params.Add('      </wsdl:SubmitJobReq>');
  Params.Add('   </soap:Body>');
  Params.Add('</soap:Envelope>');
  logger.Debug(Params.Text);
  if HttPPost(FConfig.DFUrl, Params, s) then
  begin
    logger.Debug(s);
    Result := DecodeDFSubJobResult(s);
  end;
  Params.Free;
  ActiveX.CoUninitialize;
end;

function THik.DFLogin: String;
var
  Params: TStrings;
  s: String;
begin
  if FToken = '' then
  begin
    Params := TStringList.Create;
    Params.Add
      ('<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsdl="http://www.hikvision.com.cn/ver1/ivms/wsdl">');
    Params.Add('   <soap:Header/>');
    Params.Add('   <soap:Body>');
    Params.Add('      <wsdl:LoginReq>');
    Params.Add('         <wsdl:userName>' + FConfig.DFUser +
      '</wsdl:userName>');
    Params.Add('         <wsdl:password>' + FConfig.DFPwd +
      '</wsdl:password>');
    Params.Add('      </wsdl:LoginReq>');
    Params.Add('   </soap:Body>');
    Params.Add('</soap:Envelope>');
    if HttPPost(FConfig.DFUrl, Params, s) then
    begin
      if pos('<token>', s) > 0 then
        FToken := copy(s, pos('<token>', s) + 7, Length(s));
      if (FToken <> '') and (pos('</token>', FToken) > 0) then
        FToken := copy(FToken, 1, pos('</token>', FToken) - 1)
      else
        FToken := '';
    end;
    Params.Free;
  end;
  Result := FToken;
  if FToken = '' then
    logger.Error('Get token error');
end;

procedure THik.DFLogout;
var
  Params: TStrings;
  s: String;
begin
  if FToken <> '' then
  begin
    Params := TStringList.Create;
    Params.Add
      ('<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsdl="http://www.hikvision.com.cn/ver1/ivms/wsdl">');
    Params.Add('   <soap:Header>');
    Params.Add('      <wsdl:HeaderReq>');
    Params.Add('         <wsdl:token>' + FToken + '</wsdl:token>');
    Params.Add('         <wsdl:version>1.2</wsdl:version>');
    Params.Add('      </wsdl:HeaderReq>');
    Params.Add('   </soap:Header>');
    Params.Add('   <soap:Body>');
    Params.Add('      <wsdl:LogoutReq>');
    Params.Add('         <wsdl:token>' + FToken + '</wsdl:token>');
    Params.Add('      </wsdl:LogoutReq>');
    Params.Add('   </soap:Body>');
    Params.Add('</soap:Envelope>');
    HttPPost(FConfig.DFUrl, Params, s);
    Params.Free;
  end;
end;

function THik.GetField(const AName: String; fields: TArray<TRttiField>)
  : TRttiField;
var
  Field: TRttiField;
begin
  for Field in fields do
    if SameText(Field.Name, AName) then
      exit(Field);
  Result := nil;
end;

function THik.GetJobProcess(jobid: String): Integer;
var
  Params: TStrings;
  s: String;
begin
  Result := 0;
  Params := TStringList.Create;
  Params.Add
    ('<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:wsdl="http://www.hikvision.com.cn/ver1/ivms/wsdl">');
  Params.Add('   <soap:Header>');
  Params.Add('      <wsdl:HeaderReq>');
  Params.Add('         <wsdl:token>' + Token + '</wsdl:token>');
  Params.Add('         <wsdl:version>1.2</wsdl:version>');
  Params.Add('      </wsdl:HeaderReq>');
  Params.Add('   </soap:Header>');
  Params.Add('   <soap:Body>');
  Params.Add('      <wsdl:JobStatusReq>');
  Params.Add('         <wsdl:jobIds>' + jobid + '</wsdl:jobIds>');
  Params.Add('      </wsdl:JobStatusReq>');
  Params.Add('   </soap:Body>');
  Params.Add('</soap:Envelope>');
  if HttPPost(FConfig.DFUrl, Params, s) then
  begin
    if pos('<ns2:errorCode>113</ns2:errorCode>', s) > 0 then // 作业id不存在
      Result := 100
    else if pos('<ns2:process>100.0</ns2:process>', s) > 0 then
      Result := 100
    else if pos('<ns2:errorCode>106</ns2:errorCode>', s) > 0 then // token过期
      FToken := '';
  end;
  Params.Free;
end;

function THik.HttPPost(AUrl: String; AParams: TStrings; var AResult: String;
  AEncoding: TEncoding = nil): Boolean;
var
  http: TIdHTTP;
  stream: TMemoryStream;
  I: Integer;
begin
  AResult := '';
  Result := false;
  I := 0;
  while (I < 2) and not Result do
  begin
    http := TIdHTTP.Create(nil);
    stream := TMemoryStream.Create;
    try
      if AEncoding = nil then
        AParams.SaveToStream(stream)
      else
        AParams.SaveToStream(stream, AEncoding);
      AResult := UTF8ToString(http.Post(AUrl, stream));
      Result := True;
    except
      on e: exception do
      begin
        logger.Error('[THik.HttpPost]' + e.Message);
        AResult := http.ResponseText;
        inc(I);
      end;
    end;
    stream.Free;
    http.Disconnect;
    http.Free;
  end;
end;

procedure THik.InitVehInfo<T>(rec: Pointer);
var
  rrt: TRttiRecordType;
  rField: TRttiField;
begin
  rrt := TRTTIContext.Create.GetType(TypeInfo(T)).AsRecord;
  for rField in rrt.GetFields do
    rField.SetValue(rec, TValue.From<string>(''));
  rrt := nil;
end;

end.
