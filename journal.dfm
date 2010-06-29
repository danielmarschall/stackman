object MDIJournalForm: TMDIJournalForm
  Left = 288
  Top = 156
  Width = 347
  Height = 180
  Caption = 'Journal'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsMDIChild
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 339
    Height = 134
    Align = alClient
    Color = clBtnFace
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object MainMenu1: TMainMenu
    Images = MainForm.ImageList2
    Left = 8
    Top = 8
    object Journal1: TMenuItem
      Caption = '&Journal'
      GroupIndex = 5
      object Close1: TMenuItem
        Caption = '&Schlie'#223'en'
        ImageIndex = 20
        ShortCut = 27
        OnClick = Close1Click
      end
    end
  end
end
