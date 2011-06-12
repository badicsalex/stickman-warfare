object Form1: TForm1
  Left = 229
  Top = 130
  BorderStyle = bsNone
  Caption = 'Stickman Warfare Portable'
  ClientHeight = 153
  ClientWidth = 474
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 232
    Height = 54
    Caption = 'Stickman'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = 4227327
    Font.Height = -48
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 256
    Top = 8
    Width = 203
    Height = 54
    Caption = 'Warfare'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = 4227327
    Font.Height = -48
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label4: TLabel
    Left = 168
    Top = 64
    Width = 152
    Height = 36
    Caption = 'Portable'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = 4227327
    Font.Height = -32
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 104
    Width = 457
    Height = 41
    Min = 0
    Max = 100
    TabOrder = 0
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 48
    Top = 64
  end
end
