unit main;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, ShellAPI;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Window1: TMenuItem;
    Help1: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    FileKategorien1: TAction;
    FileExit1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton3: TToolButton;
    ToolButton9: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    N1: TMenuItem;
    Beenden1: TMenuItem;
    Kategorie1: TMenuItem;
    N2: TMenuItem;
    JournalOpen: TMenuItem;
    Timer1: TTimer;
    Timer2: TTimer;
    Neu1: TMenuItem;
    AufUpdatesprfen1: TMenuItem;
    FileNeu1: TAction;
    FileJournal1: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    HelpUpdates1: TAction;
    ImageList2: TImageList;
    procedure FileKategorien1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JournalOpenClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Neu1Click(Sender: TObject);
    procedure AufUpdates1Click(Sender: TObject);
  private
    CloseTimerInitialized: boolean;
    CloseTimerMin: Integer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  about, categories, global, journal;

procedure TMainForm.FileKategorien1Execute(Sender: TObject);
begin
  openCategoriesWindow();
end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.JournalOpenClick(Sender: TObject);
var
  i: integer;
  somethingfound: boolean;
begin
  somethingfound := false;

  for i := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[i] is TMDIJournalForm then
    begin
      Screen.Forms[i].BringToFront;
      Screen.Forms[i].WindowState := wsNormal;
      somethingfound := true;
      break;
    end
  end;

  if not somethingfound then
  begin
    TMDIJournalForm.Create(Application);
  end;
end;

procedure TMainForm.Neu1Click(Sender: TObject);
var
  i: integer;
  somethingfound: boolean;
begin
  somethingfound := false;

  for i := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[i] is TMDICategories then
    begin
      TMDICategories(Screen.Forms[i]).DoNew;
      somethingfound := true;
      break;
    end
  end;

  if not somethingfound then
  begin
    newDialog(''); // Aus der Wurzel erstellen
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  // timer1.Enabled := false;

  if not CloseTimerInitialized then
  begin
    CloseTimerMin := Screen.FormCount;
  end;

  if Screen.FormCount <= CloseTimerMin then
  begin
    if not CloseTimerInitialized then
    begin
      Kategorie1.Click; // Im OnShow ist das Ergebnis anders (Fenster zu klein, schwarze Ränder an abgerundeten Fensterkanten)
    end
    else
    begin
      if CfgOpenCatWhenEverythingClosed then Kategorie1.Click; // Das Fenster soll immer geöffnet werden, wenn alles andere geschlossen ist
    end;
  end;

  if not CloseTimerInitialized then
  begin
    CloseTimerInitialized := true;
  end;
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
begin
  StatusBar.Panels.Items[1].Text := DateTimeToStr(Now());
end;

procedure TMainForm.AufUpdates1Click(Sender: TObject);
const
  abbreviation = 'stackman';
  thisversion = '5.1';
resourcestring
  lng_no_new_version = 'Es ist keine neue Programmversion vorhanden.';
  lng_update_error = 'Ein Fehler ist aufgetreten. Wahrscheinlich ist keine Internetverbindung aufgebaut, oder der der ViaThinkSoft-Server temporär offline.';
  lng_caption_error = 'Fehler';
  lng_caption_information = 'Information';
  lng_update_new_version = 'Eine neue Programmversion (%s) ist vorhanden. Möchten Sie diese jetzt herunterladen?';
const
  url_comparison = 'http://www.viathinksoft.de/update/?id=%s&expect_version=%s';
  url_version = 'http://www.viathinksoft.de/update/?id=%s';
  url_download = 'http://www.viathinksoft.de/update/?id=@%s';
  res_nothing = 'NO_UPDATES';
  res_updates = 'UPDATE_AVAILABLE';
var
  temp: string;
begin
  temp := GetHTML(Format(url_comparison, [abbreviation, thisversion]));

  if temp = res_nothing then
  begin
    Application.MessageBox(PChar(lng_no_new_version), PChar(lng_caption_information), MB_OK + MB_ICONASTERISK);
  end
  else if temp = res_updates then
  begin
    temp := GetHTML(Format(url_version, [abbreviation]));
    if Application.MessageBox(PChar(Format(lng_update_new_version, [temp])), PChar(lng_caption_information), MB_YESNO + MB_ICONASTERISK) = ID_YES then
    begin
      ShellExecute(application.handle, 'open', pchar(Format(url_download, [abbreviation])), '', '', sw_normal);
    end;
  end
  else
  begin
    Application.MessageBox(PChar(lng_update_error), PChar(lng_caption_error), MB_OK + MB_ICONERROR)
  end;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin         
  if not DirectoryExists(getDataPath()) then
  begin
    ForceDirectories(getDataPath());
  end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  StatusBar.Panels.Items[0].Width := StatusBar.Width - StatusBar.Panels.Items[1].Width;
end;

end.
