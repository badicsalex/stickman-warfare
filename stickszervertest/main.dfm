object Form1: TForm1
  Left = 302
  Top = 116
  Width = 642
  Height = 439
  Caption = 'Stick Szerver teszter'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 80
    Width = 41
    Height = 13
    Caption = 'Playerek'
  end
  object Label2: TLabel
    Left = 208
    Top = 80
    Width = 23
    Height = 13
    Caption = 'Chat'
  end
  object Label3: TLabel
    Left = 16
    Top = 16
    Width = 23
    Height = 13
    Caption = 'N'#233'v:'
  end
  object Label4: TLabel
    Left = 8
    Top = 40
    Width = 33
    Height = 13
    Caption = 'Jelsz'#243':'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 72
    Width = 609
    Height = 2
  end
  object Label8: TLabel
    Left = 184
    Top = 16
    Width = 26
    Height = 13
    Caption = 'Host:'
  end
  object Label5: TLabel
    Left = 384
    Top = 16
    Width = 22
    Height = 13
    Caption = 'UID:'
  end
  object Button1: TButton
    Left = 184
    Top = 40
    Width = 177
    Height = 25
    Caption = 'Login'
    TabOrder = 0
    OnClick = Button1Click
  end
  object clients: TMemo
    Left = 8
    Top = 96
    Width = 193
    Height = 297
    ReadOnly = True
    TabOrder = 1
  end
  object chat: TMemo
    Left = 208
    Top = 96
    Width = 409
    Height = 273
    ReadOnly = True
    TabOrder = 2
  end
  object Edit1: TEdit
    Left = 208
    Top = 376
    Width = 345
    Height = 21
    TabOrder = 3
  end
  object Button2: TButton
    Left = 560
    Top = 376
    Width = 57
    Height = 21
    Caption = 'K'#252'ld'
    Enabled = False
    TabOrder = 4
    OnClick = Button2Click
  end
  object Edit2: TEdit
    Left = 48
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 5
  end
  object Edit3: TEdit
    Left = 224
    Top = 16
    Width = 137
    Height = 21
    TabOrder = 6
    Text = 'sticktop.teteny.bme.hu'
  end
  object Edit4: TEdit
    Left = 48
    Top = 40
    Width = 121
    Height = 21
    PasswordChar = '*'
    TabOrder = 7
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 576
    Top = 8
  end
end
