unit journal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ImgList;

type
  TMDIJournalForm = class(TForm)
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    Journal1: TMenuItem;
    Close1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Close1Click(Sender: TObject);
  public
    procedure DoRefresh;
  end;

var
  MDIJournalForm: TMDIJournalForm;

implementation

{$R *.dfm}

uses
  main, global;

procedure TMDIJournalForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TMDIJournalForm.DoRefresh;
begin
  if FileExists(getJournalFileName()) then
  begin
    Memo1.Lines.LoadFromFile(getJournalFileName());
  end;
  SendMessage(Memo1.Handle, WM_VSCROLL, SB_BOTTOM, 0); // TODO: geht nicht in w95
end;

procedure TMDIJournalForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDIJournalForm.FormShow(Sender: TObject);
begin
  DoRefresh;
end;

end.
