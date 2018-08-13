object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 231
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnSwitch: TButton
    Left = 24
    Top = 24
    Width = 75
    Height = 25
    Caption = #21551#21160
    TabOrder = 0
    OnClick = btnSwitchClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 600000
    OnTimer = Timer1Timer
    Left = 128
    Top = 24
  end
end
