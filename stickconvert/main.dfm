object Form1: TForm1
  Left = 206
  Top = 151
  Width = 468
  Height = 377
  Caption = 'Stick Ligtmapper and Converter'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 264
    Top = 136
    Width = 14
    Height = 13
    Caption = '0%'
  end
  object Button1: TButton
    Left = 264
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Do your stuff!'
    TabOrder = 0
    OnClick = Button1Click
  end
  object resg: TRadioGroup
    Left = 264
    Top = 8
    Width = 73
    Height = 65
    Caption = 'Resolution'
    ItemIndex = 1
    Items.Strings = (
      '64'
      '128'
      '256')
    TabOrder = 1
  end
  object jpgchk: TCheckBox
    Left = 264
    Top = 80
    Width = 97
    Height = 17
    Caption = 'JPG textures'
    TabOrder = 2
  end
  object OD1: TOpenDialog
    Filter = 'X or 3DS model file|*.x;*.3ds'
    Left = 256
    Top = 152
  end
end
