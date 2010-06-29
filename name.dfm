object NameDlg: TNameDlg
  Left = 245
  Top = 108
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  ClientHeight = 113
  ClientWidth = 233
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 9
    Width = 32
    Height = 13
    Caption = 'Name?'
  end
  object NameEdt: TEdit
    Left = 8
    Top = 27
    Width = 217
    Height = 21
    TabOrder = 0
    OnChange = NameEdtChange
  end
  object OKBtn: TButton
    Left = 70
    Top = 77
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 151
    Top = 78
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 3
    OnClick = CancelBtnClick
  end
  object Textmode: TCheckBox
    Left = 8
    Top = 54
    Width = 97
    Height = 17
    Caption = 'Textmodus'
    TabOrder = 1
    OnClick = NameEdtChange
  end
end
