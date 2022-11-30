object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 295
  ClientWidth = 307
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 24
    Top = 32
    Width = 16
    Height = 13
    Caption = 'lbl1'
    FocusControl = edt1
  end
  object lbl2: TLabel
    Left = 24
    Top = 96
    Width = 16
    Height = 13
    Caption = 'lbl1'
    FocusControl = edt2
  end
  object lbl3: TLabel
    Left = 24
    Top = 152
    Width = 16
    Height = 13
    Caption = 'lbl1'
    FocusControl = edt3
  end
  object lbl4: TLabel
    Left = 24
    Top = 216
    Width = 16
    Height = 13
    Caption = 'lbl1'
    FocusControl = edt4
  end
  object edt1: TEdit
    Left = 24
    Top = 56
    Width = 265
    Height = 21
    TabOrder = 0
  end
  object edt2: TEdit
    Tag = 1
    Left = 24
    Top = 120
    Width = 265
    Height = 21
    TabOrder = 1
  end
  object edt3: TEdit
    Left = 24
    Top = 176
    Width = 265
    Height = 21
    TabOrder = 2
  end
  object edt4: TEdit
    Left = 24
    Top = 240
    Width = 265
    Height = 21
    TabOrder = 3
  end
end
