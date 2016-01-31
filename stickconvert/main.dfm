object Form1: TForm1
  Left = 997
  Top = 675
  Width = 542
  Height = 495
  Caption = 'Stick Ligtmapper and Converter'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 256
    Top = 240
    Width = 3
    Height = 13
    Caption = ' '
  end
  object Button1: TButton
    Left = 256
    Top = 272
    Width = 81
    Height = 25
    Caption = 'Choose file'
    TabOrder = 4
    OnClick = Buton1Click
  end
  object resg: TRadioGroup
    Left = 256
    Top = 56
    Width = 73
    Height = 113
    Caption = 'Resolution'
    ItemIndex = 1
    Items.Strings = (
      '64'
      '128'
      '256'
      '512'
      '1024'
      '2048')
    TabOrder = 1
  end
  object jpgchk: TCheckBox
    Left = 256
    Top = 184
    Width = 97
    Height = 17
    Caption = 'JPG textures'
    TabOrder = 2
  end
  object kellLMchk: TCheckBox
    Left = 256
    Top = 208
    Width = 145
    Height = 17
    Caption = 'Don'#39't generate lightmap'
    TabOrder = 3
  end
  object buttonLang: TButton
    Left = 256
    Top = 16
    Width = 97
    Height = 25
    Caption = 'Language/Nyelv'
    TabOrder = 0
    OnClick = LangClick
  end
  object OD1: TOpenDialog
    Filter = 'X or 3DS model file|*.x;*.3ds'
    Left = 256
    Top = 304
  end
end
