object Form1: TForm1
  Left = 192
  Top = 110
  Width = 550
  Height = 238
  Caption = 'Flooder'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 24
    Top = 16
    Width = 333
    Height = 22
    Caption = '1. Nyisd meg a floodolandó alkalmazást'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 24
    Top = 40
    Width = 221
    Height = 22
    Caption = '2. Írd ide a flood-szöveget'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 24
    Top = 64
    Width = 124
    Height = 22
    Caption = '3. Flood gomb'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 24
    Top = 88
    Width = 450
    Height = 22
    Caption = '4. Írtó gyorsan kattints az alkalmazásra (2 másodperc)'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 40
    Top = 120
    Width = 409
    Height = 21
    TabOrder = 0
    Text = 'Bombaaaaaaa!'
  end
  object Edit2: TEdit
    Left = 40
    Top = 152
    Width = 73
    Height = 21
    TabOrder = 1
    Text = '100'
  end
  object Button1: TButton
    Left = 136
    Top = 152
    Width = 313
    Height = 25
    Caption = 'Flooooooooooooooooooooood!'
    TabOrder = 2
    OnClick = Button1Click
  end
end
