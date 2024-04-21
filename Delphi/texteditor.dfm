object MDITextEditor: TMDITextEditor
  Left = 255
  Top = 367
  Caption = 'Text-Editor'
  ClientHeight = 121
  ClientWidth = 331
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  Menu = MainMenu1
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 331
    Height = 121
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    OnChange = Memo1Change
    ExplicitWidth = 339
    ExplicitHeight = 134
  end
  object MainMenu1: TMainMenu
    Images = MainForm.ImageList2
    Left = 8
    Top = 8
    object Document1: TMenuItem
      Caption = '&Datensatz'
      GroupIndex = 5
      object Save: TMenuItem
        Caption = 'Text abspeichern'
        GroupIndex = 1
        ImageIndex = 8
        ShortCut = 16467
        OnClick = SaveClick
      end
      object N2: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object ExternalOpen: TMenuItem
        Caption = 'Mit &externem Programm '#246'ffnen'
        GroupIndex = 1
        ImageIndex = 22
        ShortCut = 121
        OnClick = ExternalOpenClick
      end
      object Delete: TMenuItem
        Caption = 'Datensatz &l'#246'schen...'
        GroupIndex = 1
        ImageIndex = 5
        ShortCut = 16392
        OnClick = DeleteClick
      end
      object N4: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object DocumentClose1: TMenuItem
        Caption = '&Schlie'#223'en'
        GroupIndex = 1
        ImageIndex = 20
        ShortCut = 27
        OnClick = DocumentClose1Click
      end
    end
  end
  object AutoSaveTimer: TTimer
    Interval = 10000
    OnTimer = AutoSaveTimerTimer
    Left = 40
    Top = 8
  end
end
