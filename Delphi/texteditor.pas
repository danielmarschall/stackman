unit texteditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ShellAPI, ExtCtrls, System.UITypes;

type
  TMDITextEditor = class(TForm)
    MainMenu1: TMainMenu;
    Document1: TMenuItem;
    Save: TMenuItem;
    N2: TMenuItem;
    ExternalOpen: TMenuItem;
    Delete: TMenuItem;
    N4: TMenuItem;
    DocumentClose1: TMenuItem;
    Memo1: TMemo;
    AutoSaveTimer: TTimer;
    procedure DocumentClose1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure ExternalOpenClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure AutoSaveTimerTimer(Sender: TObject);
  private
    fcat: string;
    fprefix: string;
    fautosave: boolean;
    changed: boolean;
    function DoSave: boolean;
    procedure UpdateCaption;
  public
    property folder: string read fprefix;
    property cat: string read fcat;
    property autosave: boolean read fautosave;
    constructor Create(AOwner: TComponent; Folder, Category: string); reintroduce;
  end;

var
  MDITextEditor: TMDITextEditor;

implementation

{$R *.dfm}

uses
  main, categories, global;

constructor TMDITextEditor.Create(AOwner: TComponent; Folder, Category: string);
begin
  inherited Create(AOwner);

  fautosave := true;
  fcat := category;
  fprefix := MyAddTrailingPathDelimiter(folder);
end;

procedure TMDITextEditor.DeleteClick(Sender: TObject);
var
  fn: string;
  i: integer;
begin
  fn := getTextFileName(folder, cat);
  if commonDelete(fn) then
  begin
    Close;

    // TODO: Eigentlich sollte das innerhalb von commonDelete() stattfinden
    for i := Screen.FormCount - 1 downto 0 do
    begin
      if Screen.Forms[i] is TMDICategories then
      begin
        TMDICategories(Screen.Forms[i]).DeleteNode(folder, cat);
      end
    end;
  end;
end;

procedure TMDITextEditor.DocumentClose1Click(Sender: TObject);
begin
  Close;
end;

function TMDITextEditor.DoSave: boolean;
begin
  //if changed then
  //begin
    result := true;

    AddToJournal(Format(lng_jnl_textchange, [folder + cat]));

    try
      Memo1.Lines.SaveToFile(getTextFileName(folder, cat));
    except
      result := false;
    end;

    changed := false;
    AutoSaveTimer.Enabled := false;
    UpdateCaption;
  //end
  //else result := true;
end;

procedure TMDITextEditor.ExternalOpenClick(Sender: TObject);
var
  fn: string;
begin
  fn := getTextFileName(folder, cat);
  commonExternalOpen(fn);
end;

procedure TMDITextEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDITextEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  userResponse: integer;
begin
  if changed then
  begin
    if not AUTOSAVE then
    begin
      BringToFront;
      WindowState := wsNormal;

      userResponse := MessageDlg(Format(lng_savefirst, [folder + cat]),
        mtConfirmation, mbYesNoCancel, 0);
      case userResponse of
        idYes: CanClose := DoSave;
        idNo: CanClose := true;
        idCancel: begin
          CanClose := false;
          Exit;
        end;
      end;
    end
    else
      CanClose := DoSave;
  end;
end;

procedure TMDITextEditor.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
  Memo1.Lines.LoadFromFile(getTextFileName(folder, cat));

  changed := false;
  AutoSaveTimer.Enabled := false;
  UpdateCaption;

  Memo1.SetFocus;
end;

procedure TMDITextEditor.Memo1Change(Sender: TObject);
begin
  changed := true;
  AutoSaveTimer.Enabled := true;
  UpdateCaption;
end;

procedure TMDITextEditor.SaveClick(Sender: TObject);
begin
  DoSave;
end;

procedure TMDITextEditor.AutoSaveTimerTimer(Sender: TObject);
begin
  if AUTOSAVE and Changed then
  begin
    DoSave;
  end;
end;

procedure TMDITextEditor.UpdateCaption;
var
  capname: string;
begin
  capname := Format(lng_texteditor_title, [folder + cat]);
  if changed then capname := capname + ' *';

  if Caption <> capname then Caption := capname; // Kein Aufblitzen
end;

end.
