inherited FrameZBGL_RY: TFrameZBGL_RY
  Width = 700
  inherited dxLayoutControl2: TdxLayoutControl
    Width = 700
    inherited cxGrid1: TcxGrid
      Top = 45
      Width = 674
      Height = 219
      TabOrder = 4
      ExplicitTop = 45
      ExplicitWidth = 674
      ExplicitHeight = 219
      inherited GridView: TcxGridDBTableView
        OptionsCustomize.ColumnSorting = True
      end
    end
    inherited cbbPagesize: TcxComboBox
      TabOrder = 5
    end
    inherited btnFirstPage: TcxButton
      TabOrder = 6
    end
    inherited btnPriorPage: TcxButton
      TabOrder = 7
    end
    inherited edtPageIndex: TcxTextEdit
      TabOrder = 8
    end
    inherited btnnextPage: TcxButton
      TabOrder = 9
    end
    inherited btnLastPage: TcxButton
      TabOrder = 10
    end
    object cboBCLB: TcxComboBox [7]
      Left = 308
      Top = 13
      AutoSize = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.Items.Strings = (
        #20840#37096
        #39046#23548
        #27665#35686
        #21327#35686)
      Properties.OnChange = cboBCLBPropertiesChange
      Style.HotTrack = False
      TabOrder = 1
      Text = #20840#37096
      Height = 21
      Width = 90
    end
    object cxButton2: TcxButton [8]
      Left = 630
      Top = 13
      Width = 25
      Height = 25
      OptionsImage.ImageIndex = 42
      OptionsImage.Images = DM.ilBarSmall
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.Transparent = True
      TabOrder = 2
      OnClick = cxButton2Click
    end
    object cxButton1: TcxButton [9]
      Left = 662
      Top = 13
      Width = 25
      Height = 25
      OptionsImage.Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000B8824DFFAE7B
        49F1A17243DF805A35B149331E65060503090000000000000000000000000000
        0000000000000000000000000000000000000000000000000000B8824DFFB882
        4DFFB8824DFFB8824DFFB8824DFFA57445E42A1E123A00000000000000000000
        0000000000000000000000000000000000000000000000000000B8824DFFB882
        4DFFB8824DFFB8824DFFB8824DFFB8824DFFAF7C49F319110A22000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000E0A06132F2114418F653CC6B8824DFFB8824DFF704F2F9B000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000001A120B24B8824DFFB8824DFFA17243DF000000000000
        0000000000000A07040E8B623AC1B8824DFFB7814DFE4F38216D000000000000
        0000000000000000000000000000B8824DFFB8824DFFB07C4AF4000000000000
        00000D09051292673DCAB8824DFFB7814DFE4A351F6700000000000000000000
        0000000000000000000018110A21B8824DFFB8824DFFA27244E000000000110C
        0717986B3FD2B8824DFFB6804CFC45311D600000000000000000000000000000
        00000403020523190F318D633BC3B8824DFFB8824DFF71502F9D160F091E9C6E
        41D8B8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB882
        4DFFB8824DFFB8824DFFB8824DFFB8824DFFB07C4AF41A120B24896139BEB882
        4DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB882
        4DFFB8824DFFB8824DFFB8824DFFA77646E82C1F123D00000000120D0819996C
        40D4B8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB8824DFFB07C
        4AF4A27344E1825C36B44C36206A0A07040E0000000000000000000000000D09
        051291663DC9B8824DFFB7814DFE49331E650000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000907040D886039BDB8824DFFB7814DFE4C36206A00000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000060402087F5A35B0B8824DFFB7814DFE5039226F000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      OptionsImage.ImageIndex = 48
      OptionsImage.Images = DM.ilBarSmall
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.Transparent = True
      TabOrder = 3
      OnClick = cxButton1Click
    end
    object cbbDWMC: TcxComboBox [10]
      Left = 67
      Top = 13
      AutoSize = False
      Properties.DropDownListStyle = lsEditFixedList
      Style.HotTrack = False
      TabOrder = 0
      Height = 21
      Width = 180
    end
    inherited dxLayoutGroup2: TdxLayoutGroup
      LayoutDirection = ldHorizontal
    end
    inherited dxLayoutGroupPage: TdxLayoutGroup
      Visible = False
    end
    object dxLayoutItem1: TdxLayoutItem
      Parent = dxLayoutGroup2
      CaptionOptions.Text = #29677#27425#31867#21035
      Control = cboBCLB
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 90
      ControlOptions.ShowBorder = False
      Index = 1
    end
    object dxLayoutItem2: TdxLayoutItem
      Parent = dxLayoutGroup2
      AlignHorz = ahRight
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = cxButton2
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 25
      ControlOptions.ShowBorder = False
      Index = 2
    end
    object dxLayoutItem4: TdxLayoutItem
      Parent = dxLayoutGroup2
      AlignHorz = ahRight
      CaptionOptions.Text = 'New Item'
      CaptionOptions.Visible = False
      Control = cxButton1
      ControlOptions.OriginalHeight = 25
      ControlOptions.OriginalWidth = 25
      ControlOptions.ShowBorder = False
      Index = 3
    end
    object dxLayoutItem5: TdxLayoutItem
      Parent = dxLayoutGroup2
      CaptionOptions.Text = #21333#20301#21517#31216
      Control = cbbDWMC
      ControlOptions.OriginalHeight = 21
      ControlOptions.OriginalWidth = 180
      ControlOptions.ShowBorder = False
      Index = 0
    end
  end
  inherited cxdtrpstry1: TcxEditRepository
    inherited cxdtrpstry1ButtonItem1: TcxEditRepositoryButtonItem
      Properties.Buttons = <
        item
          Action = actedit
          ContentAlignment = taLeftJustify
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000000000000000
            00000000000000000000000000000000001F421C11FF30140DEC190A06B30304
            075F0000001B0000000500000000000000000000000000000000000000000000
            00000000000000000000000000000000001E663C2BE7B9C7D2FF7889A2FF2441
            82FF051033AF0000002100000005000000000000000000000000000000000000
            0002000000090000000E0000000F0000002041261BAE879AB2FFC8E3F5FF1F66
            B6FF2B6BA8FF051236AD0000001F000000040000000000000000000000000000
            00088C6657C0C38C7AFFC38C79FFCBA395FFA89894FF488BC3FFDEFEFDFF51B4
            E3FF1F68B7FF3173AEFF061538AA0000001C0000000400000000000000000000
            000CC5917EFFFDFBFAFFFCF8F6FFFAF7F5FFECEAE9FF7CA3BFFF479FD2FFDEFE
            FDFF59BFE9FF216BB9FF367BB3FF07173AA70000001A00000004000000000000
            000CC79481FFFEFBFAFFF9F0EAFFF8F0EAFFF7F0EBFFE8E4E1FF7EA4BFFF4BA5
            D5FFDEFEFDFF61CAEFFF246FBCFF3B83B9FF081A3DA300000018000000000000
            000BC99786FFFEFCFBFFF9F2EDFFF9F2EDFFF9F0EBFFF8F2EDFFEBE7E5FF82A7
            C2FF4EAAD7FFDEFEFDFF68D4F4FF2875BEFF3F8BBEFF091B3F9E000000000000
            000ACB9C8BFFFEFDFCFFFAF3EFFFFAF4EEFFFAF3EEFFFAF1ECFFF8F2EEFFEDE9
            E7FF85ABC7FF51AEDAFFDEFEFDFF6EDDF8FF2C7BC2FF18448BFF000000000000
            0009CFA08DFFFEFEFDFFFBF5F1FFFBF5F0FFFBF4F0FFFAF3EFFFFAF3EFFFF8F4
            EFFFEFECE9FF89AECAFF54B1DCFFDEFEFDFF4FA6D4FF102C4E93000000000000
            0009D0A393FFFEFEFDFFFAF5F3FFFBF6F2FFFBF5F1FFFBF5F0FFFBF5F0FFFAF4
            EFFFFAF6F1FFF3EFEDFF83A0B8FF357FBCFF173A598F0000000C000000000000
            0008D3A897FFFEFEFEFFFBF6F4FFFBF6F4FFFCF6F3FFFCF6F3FFFCF4F2FFFBF5
            F1FFFBF5F0FFFAF6F3FFE2CCC4FF000000160000000600000001000000000000
            0007D3AB9AFFFFFEFEFFFCF8F6FFFCF7F5FFFCF7F5FFFBF6F4FFFBF6F4FFFCF6
            F3FFFCF6F2FFFBF6F1FFD1A494FF0000000C0000000000000000000000000000
            0006D8AE9DFFFFFFFEFFFDF9F7FFFDF9F7FFFCF8F7FFFCF8F6FFFCF7F5FFFBF7
            F5FFFBF7F4FFFCF7F3FFD3A897FF0000000B0000000000000000000000000000
            0006D8B0A0FFFFFFFFFFFDFAF9FFFDFAF8FFFDFAF8FFFDF9F7FFFCF8F7FFFBF8
            F6FFFBF7F6FFFCF7F5FFD4AC9BFF0000000A0000000000000000000000000000
            0005D9B3A3FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFEFEFFFEFEFEFFFFFE
            FEFFFEFEFEFFFEFEFEFFD7AE9EFF000000090000000000000000000000000000
            0003A3867AC0DBB5A5FFDAB5A4FFDAB5A4FFDAB4A4FFD9B3A3FFD9B3A3FFD9B3
            A2FFD9B2A2FFD8B2A2FFA08377C2000000060000000000000000}
          Kind = bkGlyph
        end
        item
          Action = actdelete
          Default = True
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000020000000A00000010000000090000000200000000000000000000
            00020000000A000000120000000C000000030000000000000000000000000000
            00020000000F0F0742921D0F7EEF0603347A0000000E00000002000000020000
            000F0804347C1D0F7EF00F084194000000120000000200000000000000000000
            0008120B47923233AFFF3648CCFF1D1EA5FF0603357A0000000F0000000F0703
            357C1F20A5FF3747CCFF2D2FAEFF120B46950000000B00000000000000000000
            000C281C8DF1596CD8FF3B51D3FF3A4FD2FF1E22A6FF0602347D0502357E2022
            A6FF3A50D3FF3A50D3FF4C5FD4FF291D8CF10000001000000000000000000000
            0006130F3C734D4FBAFF667EE0FF415AD6FF415AD7FF1F24A7FF2529A8FF415A
            D7FF415AD7FF5B72DEFF484AB8FF130F3C790000000900000000000000000000
            00010000000A16123F73585CC1FF758DE6FF4A64DBFF4A65DBFF4A65DBFF4A64
            DBFF6983E3FF5356C0FF16123F780000000C0000000200000000000000000000
            0000000000010000000A191643755D63C7FF6783E5FF5774E2FF5774E2FF5774
            E2FF565CC6FF1916437A0000000D000000020000000000000000000000000000
            00000000000100000009100E3D734A50BEFF7492EBFF6383E7FF6483E7FF6383
            E7FF3840B6FF0B0839780000000C000000020000000000000000000000000000
            0001000000071413416E555CC5FF85A1EFFF7897EDFF9CB6F4FF9DB7F5FF7997
            EEFF7796EDFF414ABCFF0E0C3C730000000A0000000100000000000000000000
            00041818456B636CCFFF93AFF3FF83A1F1FFA6BFF7FF676DCAFF7E87DDFFAFC7
            F8FF83A3F2FF83A1F1FF5058C4FF121040710000000600000000000000000000
            00065759C3EFAFC6F6FF8EADF4FFABC4F8FF6F76D0FF1817456F24244F70868E
            E1FFB5CCF9FF8DACF4FFA1B8F4FF5758C3EF0000000900000000000000000000
            000331326B8695A0EAFFC0D3F9FF7880D7FF1C1C496B00000006000000072527
            526C8B93E6FFC1D3F9FF949EE9FF303168870000000500000000000000000000
            00010000000431336B825E62CBEC1F204D680000000500000001000000010000
            00052728536B5E62CBEC31326883000000070000000100000000000000000000
            0000000000000000000200000004000000020000000100000000000000000000
            0001000000030000000500000004000000010000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000}
          Kind = bkGlyph
        end>
    end
  end
  inherited actlst1: TActionList
    inherited actedit: TAction
      OnExecute = acteditExecute
    end
    inherited actdelete: TAction
      OnExecute = actdeleteExecute
    end
  end
end
