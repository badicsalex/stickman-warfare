object Form2: TForm2
  Left = 192
  Top = 105
  BorderStyle = bsSingle
  Caption = 'PC Ágyú beállítások'
  ClientHeight = 388
  ClientWidth = 241
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 56
    Width = 241
    Height = 9
    Shape = bsBottomLine
    Style = bsRaised
  end
  object Bevel2: TBevel
    Left = 0
    Top = 312
    Width = 241
    Height = 9
    Shape = bsBottomLine
    Style = bsRaised
  end
  object porig: TRadioButton
    Left = 88
    Top = 8
    Width = 49
    Height = 17
    Caption = 'Porig'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = porigClick
    OnKeyDown = FormKeyDown
  end
  object zaszlo: TRadioButton
    Left = 88
    Top = 24
    Width = 57
    Height = 17
    Caption = 'Zászló'
    TabOrder = 1
    OnClick = zaszloClick
    OnKeyDown = FormKeyDown
  end
  object kapu: TRadioButton
    Left = 88
    Top = 40
    Width = 49
    Height = 17
    Caption = 'Kapu'
    TabOrder = 2
    OnClick = kapuClick
    OnKeyDown = FormKeyDown
  end
  object min: TEdit
    Left = 144
    Top = 32
    Width = 89
    Height = 21
    TabOrder = 3
    Text = '4000'
    OnKeyDown = FormKeyDown
  end
  object gravity: TTrackBar
    Left = 0
    Top = 88
    Width = 241
    Height = 17
    Max = 18
    Min = 2
    Orientation = trHorizontal
    Frequency = 1
    Position = 10
    SelEnd = 0
    SelStart = 0
    TabOrder = 4
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnKeyDown = FormKeyDown
  end
  object StaticText1: TStaticText
    Left = 0
    Top = 24
    Width = 77
    Height = 17
    Caption = 'Rombolás mód:'
    TabOrder = 5
  end
  object StaticText2: TStaticText
    Left = 144
    Top = 16
    Width = 85
    Height = 17
    Caption = 'Minimum erõsség'
    TabOrder = 6
  end
  object StaticText3: TStaticText
    Left = 88
    Top = 72
    Width = 52
    Height = 17
    Caption = 'Gravitáció'
    TabOrder = 7
  end
  object szelero: TTrackBar
    Left = 0
    Top = 128
    Width = 241
    Height = 17
    Max = 15
    Min = 1
    Orientation = trHorizontal
    Frequency = 1
    Position = 15
    SelEnd = 0
    SelStart = 0
    TabOrder = 8
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnKeyDown = FormKeyDown
  end
  object legellen: TTrackBar
    Left = 0
    Top = 168
    Width = 241
    Height = 17
    Max = 5
    Orientation = trHorizontal
    Frequency = 1
    Position = 1
    SelEnd = 0
    SelStart = 0
    TabOrder = 9
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnKeyDown = FormKeyDown
  end
  object domborzat: TTrackBar
    Left = 0
    Top = 208
    Width = 241
    Height = 17
    Max = 18
    Min = 2
    Orientation = trHorizontal
    Frequency = 1
    Position = 10
    SelEnd = 0
    SelStart = 0
    TabOrder = 10
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnKeyDown = FormKeyDown
  end
  object erdes: TTrackBar
    Left = 0
    Top = 248
    Width = 241
    Height = 17
    Orientation = trHorizontal
    Frequency = 1
    Position = 5
    SelEnd = 0
    SelStart = 0
    TabOrder = 11
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnKeyDown = FormKeyDown
  end
  object aaa: TStaticText
    Left = 88
    Top = 112
    Width = 61
    Height = 17
    Caption = 'Szélerõsség'
    TabOrder = 12
  end
  object vartav: TTrackBar
    Left = 0
    Top = 296
    Width = 241
    Height = 17
    Max = 45
    Min = 11
    Orientation = trHorizontal
    Frequency = 1
    Position = 41
    SelEnd = 0
    SelStart = 0
    TabOrder = 13
    ThumbLength = 10
    TickMarks = tmBottomRight
    TickStyle = tsAuto
    OnKeyDown = FormKeyDown
  end
  object StaticText5: TStaticText
    Left = 88
    Top = 152
    Width = 65
    Height = 17
    Caption = 'Légellenállás'
    TabOrder = 14
  end
  object StaticText6: TStaticText
    Left = 88
    Top = 184
    Width = 55
    Height = 17
    Caption = 'Domborzat'
    TabOrder = 15
  end
  object StaticText7: TStaticText
    Left = 88
    Top = 224
    Width = 51
    Height = 17
    Caption = 'Érdesség:'
    TabOrder = 16
  end
  object StaticText8: TStaticText
    Left = 88
    Top = 272
    Width = 81
    Height = 17
    Caption = 'Várak távolsága'
    TabOrder = 17
  end
  object Button1: TButton
    Left = 0
    Top = 328
    Width = 241
    Height = 25
    Caption = 'OK'
    TabOrder = 18
    OnClick = Button1Click
    OnKeyDown = FormKeyDown
  end
  object Button2: TButton
    Left = 0
    Top = 360
    Width = 241
    Height = 25
    Caption = 'Súgó'
    TabOrder = 19
    OnClick = Button2Click
    OnKeyDown = FormKeyDown
  end
end
