object Form1: TForm1
  Left = 307
  Top = 195
  BorderStyle = bsNone
  Caption = 'Stickman Warfare Installer'
  ClientHeight = 289
  ClientWidth = 408
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 272
    Width = 377
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Select directory and click install!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 4227327
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
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
    Left = 192
    Top = 56
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
    Left = 80
    Top = 120
    Width = 247
    Height = 36
    Caption = 'SFX Installer'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = 4227327
    Font.Height = -32
    Font.Name = 'Courier New'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ProgressBar1: TProgressBar
    Left = 16
    Top = 240
    Width = 377
    Height = 25
    Min = 0
    Max = 100
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 16
    Top = 160
    Width = 297
    Height = 21
    Color = 3618615
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 4227327
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = 'Edit1'
  end
  object Button1: TButton
    Left = 320
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 16
    Top = 192
    Width = 377
    Height = 41
    Caption = 'Install'
    Default = True
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -48
    Font.Name = 'Courier New'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 360
    Top = 0
    Width = 51
    Height = 17
    Caption = 'X'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial Black'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = Button3Click
  end
end
