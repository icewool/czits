inherited FrameForceFeedback: TFrameForceFeedback
  Width = 882
  inherited dxLayoutControl2: TdxLayoutControl
    Top = 0
    Width = 882
    Height = 305
    ExplicitTop = 0
    ExplicitHeight = 305
    inherited cxGrid1: TcxGrid
      Top = 45
      Width = 856
      Height = 219
      TabOrder = 4
      ExplicitTop = 45
      ExplicitWidth = 856
      ExplicitHeight = 219
    end
    inherited cbbPagesize: TcxComboBox
      Top = 271
      TabOrder = 5
      ExplicitTop = 271
    end
    inherited btnFirstPage: TcxButton
      Top = 271
      TabOrder = 6
      ExplicitTop = 271
    end
    inherited btnPriorPage: TcxButton
      Top = 271
      TabOrder = 7
      ExplicitTop = 271
    end
    inherited edtPageIndex: TcxTextEdit
      Top = 271
      TabOrder = 8
      ExplicitTop = 271
    end
    inherited btnnextPage: TcxButton
      Top = 271
      TabOrder = 9
      ExplicitTop = 271
    end
    inherited btnLastPage: TcxButton
      Top = 271
      TabOrder = 10
      ExplicitTop = 271
    end
    object cxDateEdit1: TcxDateEdit [7]
      Left = 67
      Top = 13
      AutoSize = False
      Properties.SaveTime = False
      Properties.ShowTime = False
      Properties.ShowToday = False
      Properties.View = cavClassic
      Style.HotTrack = False
      TabOrder = 0
      Height = 21
      Width = 121
    end
    object cxComboBox1: TcxComboBox [8]
      Left = 249
      Top = 13
      AutoSize = False
      Properties.Items.Strings = (
        #29616#22330#24320#20855#22788#32602#25991#20070
        #24050#22788#32602)
      Style.HotTrack = False
      TabOrder = 1
      Text = #29616#22330#24320#20855#22788#32602#25991#20070
      Height = 21
      Width = 128
    end
    object cxComboBox2: TcxComboBox [9]
      Left = 438
      Top = 13
      AutoSize = False
      Properties.Items.Strings = (
        #26159
        #21542)
      Style.HotTrack = False
      TabOrder = 2
      Text = #26159
      Height = 21
      Width = 61
    end
    object cxButton1: TcxButton [10]
      Left = 506
      Top = 13
      Width = 75
      Height = 25
      Caption = #26597#35810
      TabOrder = 3
      OnClick = cxButton1Click
    end
    inherited dxLayoutGroup2: TdxLayoutGroup
      LayoutDirection = ldHorizontal
    end
    inherited dxLayoutGroupPage: TdxLayoutGroup
      Visible = False
    end
    object dxLayoutItem1: TdxLayoutItem
      Parent = dxLayoutGroup2
      CaptionOptions.Text = #36215#22987#26102#38388
      Control = cxDateEdit1
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 121
      ControlOptions.ShowBorder = False
      Index = 0
    end
    object dxLayoutItem2: TdxLayoutItem
      Parent = dxLayoutGroup2
      CaptionOptions.Text = #22788#29702#32467#26524
      Control = cxComboBox1
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 128
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object liPPBM: TdxLayoutItem
      Parent = dxLayoutGroup2
      CaptionOptions.Text = #21305#37197#37096#38376
      Control = cxComboBox2
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 61
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutItem5: TdxLayoutItem
      Parent = dxLayoutGroup2
      CaptionOptions.Text = 'cxButton1'
      CaptionOptions.Visible = False
      Control = cxButton1
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 75
      ControlOptions.ShowBorder = False
      Index = 3
    end
  end
  inherited cxdtrpstry1: TcxEditRepository
    inherited cxdtrpstry1ButtonItem1: TcxEditRepositoryButtonItem
      Properties.Buttons = <
        item
          Action = actnew
          Default = True
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000B8824DFFB882
            4DFFB7814DFE3828184E00000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000B7814CFDB882
            4DFF855E38B806040208271C1036000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000AD7A48F0855E
            38B8060402085C412780B7814DFE4E37216C0000000000000000000000000000
            00000000000000000000000000000000000000000000000000003E2C1A560604
            02085C412780B8824DFFB8824DFFB7814DFE4E37216C00000000000000000000
            0000000000000000000000000000000000000000000000000000000000002B1E
            123BB8824DFFB8824DFFB8824DFFB8824DFFB7814DFE4E37216C000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000543C2375B8824DFFB8824DFFB8824DFFB8824DFFB7814DFE4E37216C0000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000543C2375B8824DFFB8824DFFB8824DFFB8824DFFB7814DFE4E37
            216C000000000000000000000000000000000000000000000000000000000000
            00000000000000000000543C2375B8824DFFB8824DFFB8824DFFB8824DFFB781
            4DFE4E37216C0000000000000000000000000000000000000000000000000000
            0000000000000000000000000000543C2375B8824DFFB8824DFFB8824DFFB882
            4DFFB7814DFE4E37216C00000000000000000000000000000000000000000000
            000000000000000000000000000000000000543C2375B8824DFFB8824DFFB882
            4DFFB8824DFFB7814DFE4E37216C000000000000000000000000000000000000
            00000000000000000000000000000000000000000000543C2375B8824DFFB882
            4DFFB8824DFFB8824DFF5C41267F000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000543C2375B882
            4DFFB8824DFF5C41267F0000000064472A8B4E37216C00000000000000000000
            000000000000000000000000000000000000000000000000000000000000543C
            23755C41267F0000000065472A8CB8824DFFB7814DFE4E37216C000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000065472A8CB8824DFFB8824DFFB8824DFF6A4B2C93000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000543C2375B8824DFFB8824DFF6B4B2D9401010001000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            00000000000000000000543C23756B4B2D940101000100000000}
          Hint = #31614#25910
          Kind = bkGlyph
        end
        item
          Action = actedit
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000003C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF0000000000000000000000000000
            0000000000003C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF0000000000000000000000000000
            0000000000003C3C3CFF3C3C3CFF000000000000000000000000000000000000
            000000000000000000003C3C3CFF3C3C3CFF0000000000000000000000000000
            0000000000003C3C3CFF2D2D2DBE00000000000000001E1E1E7E3C3C3CFF0000
            000000000000000000003C3C3CFF3C3C3CFF0000000000000000000000000000
            0000000000002D2D2DBE040404101E1E1E811E1E1E81000000001E1E1E7E0000
            000000000000000000003C3C3CFF3C3C3CFF0000000000000000000000000000
            000000000000040404101E1E1E813C3C3CFF3C3C3CFF1E1E1E81000000000000
            000000000000000000003C3C3CFF3C3C3CFF0000000000000000000000000000
            0000000000001E1E1E813C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E000000000000
            000000000000000000003C3C3CFF3C3C3CFF0000000000000000000000000000
            00001E1E1E813C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E00000000000000000000
            000000000000000000003C3C3CFF3C3C3CFF0000000000000000000000001A1A
            1A703C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E0000000000000000000000000000
            000000000000000000003C3C3CFF3C3C3CFF00000000000000001A1A1A703C3C
            3CFF3C3C3CFF3C3C3CFF1E1E1E7E040404100000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF0000000000000000353535E03C3C
            3CFF3C3C3CFF1A1A1A700A0A0A2C000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF3C3C3CFF1E1E1E7E00000000000000001A1A1A703535
            35E01A1A1A700A0A0A2C3C3C3CFF000000000000000000000000000000003C3C
            3CFF3C3C3CFF3C3C3CFF1E1E1E7E000000000000000000000000000000000000
            0000000000003C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF3C3C3CFF1E1E1E7E00000000000000000000000000000000000000000000
            0000000000003C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C3CFF3C3C
            3CFF1E1E1E7E0000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000}
          Kind = bkGlyph
        end
        item
          Action = actView
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            000000000000000000040000000A000000100000001300000015000000140000
            00110000000C0000000500000001000000000000000000000000000000000000
            00030000000C070404263F271F836E4235CA7A4839DE915644FF774436DE693C
            30CE3A2019870704032B00000010000000040000000000000000000000030000
            0011442C2486976253F5BE998EFFD9C5BEFFE0CFCAFFEFE6E3FFDDCAC4FFD3BC
            B5FFB48B7FFF895140F540231B92000000180000000500000001010204145536
            2D9CC5A398FFF2E9E7FFF5EFEDFFBCAEA8FF71574CFF593A2DFF755B4EFFBEAE
            A7FFEBE2DEFFE5D8D3FFB79085FF4E2A21A90101021A000000032F23246BB58D
            80FFF9F5F4FFF7F3F2FFC1B3ADFF826555FFB19A85FFC2AC97FFB09783FF7F62
            51FFC0B0A9FFECE3DFFFECE2DFFFA37467FF28191A750000000A5E4F60E1BCB1
            ACFFF6F3F3FFF8F4F3FF7A5E50FFBEA995FF857162FF3F2A22FF746053FFB8A3
            8FFF806658FFEEE5E2FFECE2DFFFB1A29CFF503F50E40000000D182C4D885C63
            72FFB2B0B0FFF1EEEDFF725242FFDDD1B9FF806D5EFF493229FF493228FFCFC0
            A9FF745545FFEBE3E1FFABA6A3FF505566FF142A55AA0000000A05080F21395F
            9DFA697F9AFF626160FF55443CFFB2A894FFE4E0C1FF584135FF847466FFA498
            87FF58483FFF5F5C5CFF4E6586FF2F5191FF050B173C00000004000000031221
            3B685A7FB7FFA6C5E3FF7990ABFF444D59FF3E4248FF2B2A25FF3C4148FF3E48
            56FF627D9EFF789DC9FF3C609FFD0B172E630000000600000000000000000000
            00030F1B3159315593ED6F91C1FF9BB9DCFFB0CDE9FFCBE8FCFFA7C7E6FF87AA
            D3FF5A7EB3FF284B8BF10A152958000000060000000100000000000000000000
            0000000000020204071112223E6F1C3765B0213F76D0274C91FC1E3C74D01933
            62B40F1F3D750204081700000003000000000000000000000000000000000000
            0000000000000000000000000002000000030000000400000005000000050000
            0004000000020000000100000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000}
          Kind = bkGlyph
        end>
    end
  end
  inherited dlgSave: TsSaveDialog
    Left = 269
  end
  inherited actlst1: TActionList
    Left = 208
    Top = 104
    inherited actedit: TAction
      OnExecute = acteditExecute
    end
  end
  inherited dxBarManager1: TdxBarManager
    Left = 104
    Top = 104
    DockControlHeights = (
      0
      0
      0
      0)
    inherited dxBarManager1Bar1: TdxBar
      ItemLinks = <
        item
          Visible = True
          ItemName = 'btnFeedback'
        end>
      Visible = False
    end
    object btnFeedback: TdxBarLargeButton
      Caption = #39044#35686#21453#39304
      Category = 0
      Hint = #39044#35686#21453#39304
      Visible = ivAlways
      OnClick = btnFeedbackClick
      LargeImageIndex = 804
    end
  end
end
