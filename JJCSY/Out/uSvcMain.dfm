object JJCSYSvc: TJJCSYSvc
  OldCreateOrder = False
  DisplayName = 'ITS JJCSY Service'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 224
  Width = 310
  object FDPhysOracleDriverLink1: TFDPhysOracleDriverLink
    Left = 63
    Top = 16
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrNone
    Left = 63
    Top = 88
  end
end
