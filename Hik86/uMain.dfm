object ItsHik86Service: TItsHik86Service
  OldCreateOrder = False
  DisplayName = 'ITS Hik86 Service'
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 150
  Width = 215
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
  object Timer1: TTimer
    Interval = 60000
    OnTimer = Timer1Timer
    Left = 160
    Top = 24
  end
end
