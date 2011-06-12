object Form1: TForm1
  Left = 194
  Top = 104
  Width = 301
  Height = 238
  Caption = 'Tili-Toli'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object TT: TStringGrid
    Left = 8
    Top = 8
    Width = 199
    Height = 199
    Cursor = crHandPoint
    BorderStyle = bsNone
    Color = clHighlight
    ColCount = 4
    DefaultColWidth = 49
    DefaultRowHeight = 49
    FixedCols = 0
    RowCount = 4
    FixedRows = 0
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clHighlightText
    Font.Height = -39
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnKeyDown = FormKeyDown
    OnSelectCell = TTSelectCell
  end
  object Button1: TButton
    Left = 216
    Top = 16
    Width = 73
    Height = 49
    Caption = 'Kever'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Arial Black'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = Button1Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 10
    OnTimer = Timer1Timer
    Left = 112
    Top = 64
  end
end
