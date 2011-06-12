object Form1: TForm1
  Left = 188
  Top = 112
  Width = 304
  Height = 125
  Caption = 'Stickman Server Stats'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 72
    Top = 32
    Width = 115
    Height = 13
    Caption = 'Elvileg ezt nem láthatod.'
  end
  object PopupMenu1: TPopupMenu
    Left = 32
    Top = 24
    object menuitem1: TMenuItem
      Caption = 'Stickman Warfare serverstats'
      Enabled = False
    end
    object menuitem2: TMenuItem
      Caption = 'Main server:'
    end
    object menuitem3: TMenuItem
      Caption = 'Exit'
      OnClick = menuitem3Click
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 224
    Top = 32
  end
  object IML: TImageList
    DrawingStyle = dsTransparent
    Left = 200
    Top = 24
  end
end
