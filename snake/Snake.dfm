object Form1: TForm1
  Left = 334
  Top = 188
  Width = 505
  Height = 347
  Caption = 'PC Snake!!!'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Pb: TPaintBox
    Left = 0
    Top = 0
    Width = 495
    Height = 313
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindow
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnDblClick = PbDblClick
  end
  object egy: TImage
    Left = 88
    Top = 216
    Width = 20
    Height = 19
    Visible = False
  end
  object ket: TImage
    Left = 88
    Top = 240
    Width = 20
    Height = 19
    Visible = False
  end
  object ha: TImage
    Left = 88
    Top = 264
    Width = 20
    Height = 19
    Visible = False
  end
  object temp: TImage
    Left = 112
    Top = 216
    Width = 20
    Height = 19
    Visible = False
  end
  object Timer1: TTimer
    Interval = 150
    OnTimer = Timer1Timer
    Left = 8
    Top = 24
  end
  object kep: TImageList
    Height = 19
    Width = 19
    Left = 40
    Top = 24
  end
end
