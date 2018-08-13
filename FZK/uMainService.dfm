object ItsFZKService: TItsFZKService
  OldCreateOrder = False
  DisplayName = 'ITS FZK Service'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 322
  object FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink
    Left = 63
    Top = 67
  end
  object fdphysrcldrvrlnk1: TFDPhysOracleDriverLink
    Left = 79
    Top = 11
  end
  object Timer1: TTimer
    Interval = 60000
    OnTimer = Timer1Timer
    Left = 9
    Top = 8
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrNone
    Left = 136
    Top = 8
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 176
    Top = 64
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 232
    Top = 64
  end
end
