object Form1: TForm1
  Left = 225
  Top = 103
  BorderIcons = [biSystemMenu]
  BorderStyle = bsNone
  Caption = 'PC Ágyú!'
  ClientHeight = 258
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  HelpFile = 'Pc Ágyú súgó.hlp'
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  WindowState = wsMaximized
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 14
  object graph: TPaintBox
    Left = 0
    Top = 0
    Width = 436
    Height = 258
    Align = alClient
    OnMouseMove = graphMouseMove
  end
  object Button1: TButton
    Left = 0
    Top = 0
    Width = 129
    Height = 25
    Caption = 'Új pálya'
    TabOrder = 0
    OnClick = Button1Click
    OnKeyDown = FormKeyDown
  end
  object Button2: TButton
    Left = 671
    Top = 0
    Width = 129
    Height = 25
    Caption = 'Beállítások'
    TabOrder = 1
    OnClick = Button2Click
    OnKeyDown = FormKeyDown
  end
  object Timer1: TTimer
    Interval = 30
    OnTimer = Timer1Timer
    Left = 24
    Top = 24
  end
  object Timer2: TTimer
    Interval = 1
    OnTimer = Timer2Timer
    Left = 88
    Top = 32
  end
end
