program StackMan;

uses
  Forms,
  main in 'MAIN.PAS' {MainForm},
  appender in 'appender.pas' {MDIAppender},
  texteditor in 'texteditor.pas' {MDITexteditor},
  about in 'ABOUT.PAS' {AboutBox},
  categories in 'categories.pas' {MDICategories},
  name in 'NAME.PAS' {NameDlg},
  global in 'global.pas',
  journal in 'JOURNAL.PAS' {MDIJournalForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'ViaThinkSoft Stack Manager';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TNameDlg, NameDlg);
  Application.Run;
end.
