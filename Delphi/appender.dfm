object MDIAppender: TMDIAppender
  Left = 215
  Top = 137
  Width = 361
  Height = 199
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object VSplitter: TSplitter
    Left = 0
    Top = 94
    Width = 353
    Height = 2
    Cursor = crVSplit
    Align = alBottom
  end
  object topPanel: TPanel
    Left = 0
    Top = 0
    Width = 353
    Height = 94
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object CheckListBox1: TCheckListBox
      Left = 0
      Top = 0
      Width = 353
      Height = 94
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
      OnClick = CheckListBox1Click
      OnDrawItem = CheckListBox1DrawItem
      OnKeyPress = CheckListBox1KeyPress
      OnMeasureItem = CheckListBox1MeasureItem
    end
  end
  object bottomPanel: TPanel
    Left = 0
    Top = 96
    Width = 353
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object newLineEdt: TMemo
      Left = 0
      Top = 0
      Width = 353
      Height = 57
      Align = alClient
      ScrollBars = ssVertical
      TabOrder = 0
      WantReturns = False
      WantTabs = True
      OnChange = newLineEdtChange
      OnKeyDown = newLineEdtKeyDown
    end
  end
  object MainMenu: TMainMenu
    Images = MainForm.ImageList2
    Left = 8
    Top = 8
    object Document1: TMenuItem
      Caption = '&Datensatz'
      GroupIndex = 5
      object Stroke: TMenuItem
        Caption = 'Gew'#228'hlte Eintr'#228'ge &ausstreichen...'
        GroupIndex = 1
        ImageIndex = 23
        ShortCut = 46
        OnClick = StrokeClick
      end
      object Neuladen1: TMenuItem
        Caption = 'Streichliste &neu laden'
        GroupIndex = 1
        ImageIndex = 19
        ShortCut = 116
        OnClick = Neuladen1Click
      end
      object N2: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Save: TMenuItem
        Caption = 'Eintragung &ablegen'
        GroupIndex = 1
        ImageIndex = 8
        OnClick = SaveClick
      end
      object N3: TMenuItem
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
end
