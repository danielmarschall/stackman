unit appender;

interface

uses
  SysUtils, Windows, Classes, Graphics, Forms, Controls, StdCtrls, ExtCtrls,
  Dialogs, Menus, ImgList, ShellAPI, CheckLst;

type
  TMDIAppender = class(TForm)
    newLineEdt: TMemo;
    MainMenu: TMainMenu;
    Document1: TMenuItem;
    Save: TMenuItem;
    ExternalOpen: TMenuItem;
    DocumentClose1: TMenuItem;
    N2: TMenuItem;
    Delete: TMenuItem;
    N3: TMenuItem;
    bottomPanel: TPanel;
    topPanel: TPanel;
    CheckListBox1: TCheckListBox;
    Neuladen1: TMenuItem;
    Stroke: TMenuItem;
    N4: TMenuItem;
    VSplitter: TSplitter;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure ExternalOpenClick(Sender: TObject);
    procedure DocumentClose1Click(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure newLineEdtKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckListBox1DrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure CheckListBox1MeasureItem(Control: TWinControl;
      Index: Integer; var Height: Integer);
    procedure StrokeClick(Sender: TObject);
    procedure Neuladen1Click(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure newLineEdtChange(Sender: TObject);
    procedure CheckListBox1KeyPress(Sender: TObject; var Key: Char);
  protected
    function DoAppend: boolean;
    function DoStroke: boolean;
    procedure RefreshList;
  private
    fcat: string;
    fprefix: string;
    procedure ExtendedUpdateCaption;
    function StrokeCount: integer;
  public
    property folder: string read fprefix;
    property cat: string read fcat;
    constructor Create(AOwner: TComponent; Folder, Category: string); reintroduce;
  end;

implementation

{$R *.dfm}

uses
  main, categories, global;

constructor TMDIAppender.Create(AOwner: TComponent; Folder, Category: string);
begin
  inherited Create(AOwner);

  fcat := category;
  fprefix := MyAddTrailingPathDelimiter(folder);
end;

procedure TMDIAppender.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

function TMDIAppender.DoStroke: boolean;
var
  i: integer;
begin
  AddToJournal(Format(lng_jnl_stroke_from, [folder + cat]));

  result := true;
  // TODO: Downto für den Benutzer nicht ganz nachvollziehbar. Aber wichtig für das Löschen.
  for i := CheckListBox1.Items.Count - 1 downto 0 do
  begin
    if CheckListBox1.Checked[i] then
    begin
      try
        AddToJournal(Format('- %s', [CheckListBox1.Items.Strings[i]]));
        StrokeFromFile(getAppenderFileName(folder, cat), i, CheckListBox1.Items.Strings[i]);
        CheckListBox1.Items.Delete(i);
      except
        on E : EStrokeMismatch do
        begin
          result := false;
          ShowMessage(lng_stroke_mismatch);
          CheckListBox1.ItemIndex := i;
          break; exit;
        end;

        (* on E : EStrokeUnknown do
        begin
          result := false;
          ShowMessage(lng_stroke_error);
          CheckListBox1.ItemIndex := i;
          break; exit;
        end; *)

        else
        begin
          result := false;
          ShowMessage(lng_stroke_error);
          CheckListBox1.ItemIndex := i;
          break; exit;
        end;
      end;
    end;
  end;

  Stroke.Enabled := false;
  ExtendedUpdateCaption;
end;

function TMDIAppender.DoAppend: boolean;
var
  f: TextFile;
  i: integer;
begin
  AddToJournal(Format(lng_jnl_add_to, [folder + cat]));

  result := true;
  try
    AssignFile(f, getAppenderFileName(folder, cat));
    try
      Append(f);

      if (newLineEdt.Lines.Count = 0) and (CfgAppenderAllowEmptyLines) then
      begin
        CheckListBox1.Items.Add(newLineEdt.Text{ = ''});
        AddToJournal(Format('+ %s', [newLineEdt.Lines.Text]));
        WriteLn(f, newLineEdt.Lines.Text);
      end
      else
      begin
        for i := 0 to newLineEdt.Lines.Count - 1 do
        begin
          if ((newLineEdt.Lines.Strings[i] = '') and CfgAppenderAllowEmptyLines) or
              (newLineEdt.Lines.Strings[i] <> '') then
          begin
            CheckListBox1.Items.Add(newLineEdt.Lines.Strings[i]);
            AddToJournal(Format('+ %s', [newLineEdt.Lines.Strings[i]]));
            WriteLn(f, newLineEdt.Lines.Strings[i]);
          end;
        end;
      end;
    finally
      CloseFile(f);
    end;
  except
    result := false;
    ShowMessage(lng_error);
  end;

  CheckListBox1.TopIndex := CheckListBox1.Items.Count - 1; // Nach unten scrollen
end;

procedure TMDIAppender.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  userResponse: integer;
begin
  if strokecount > 0 then
  begin
    userResponse := MessageDlg(Format(lng_strokefirst, [strokecount, cat]),
      mtConfirmation, mbYesNoCancel, 0);

    case userResponse of
      idYes: CanClose := DoStroke;
      idNo: CanClose := true;
      idCancel: begin
        CanClose := false;
        exit;
      end;
    end;
  end;

  if newLineEdt.Text = '' then
  begin
    CanClose := true;
    exit;
  end
  else
  begin
    BringToFront;
    WindowState := wsNormal;

    userResponse := MessageDlg(Format(lng_appendfirst, [folder + cat]),
      mtConfirmation, mbYesNoCancel, 0);
    case userResponse of
      idYes: CanClose := DoAppend;
      idNo: CanClose := true;
      idCancel: begin
        CanClose := false;
        exit;
      end;
    end;
  end;
end;

procedure TMDIAppender.FormShow(Sender: TObject);
begin
  Caption := Format(lng_editor_title, [folder + cat]);

  newLineEdt.Clear;

  RefreshList;

  Save.Enabled := false;
  ExtendedUpdateCaption;

  newLineEdt.SetFocus;
end;

procedure TMDIAppender.ExternalOpenClick(Sender: TObject);
var
  fn: string;
begin
  fn := getAppenderFileName(folder, cat);
  commonExternalOpen(fn);
end;

procedure TMDIAppender.DocumentClose1Click(Sender: TObject);
begin
  Close;
end;

procedure TMDIAppender.SaveClick(Sender: TObject);
begin
  if DoAppend then
  begin
    newLineEdt.Clear;
    Save.Enabled := false;
    ExtendedUpdateCaption;
  end;
end;

procedure TMDIAppender.newLineEdtKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
  begin
    Key := 0;
    if CfgAppenderAllowEmptyLines and (newLineEdt.Text = '') then
    begin
      Save.Enabled := true;
    end;
    Save.Click;
  end;
end;

procedure TMDIAppender.DeleteClick(Sender: TObject);
var
  fn: string;
  i: integer;
begin
  fn := getAppenderFileName(folder, cat);
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

procedure TMDIAppender.FormCreate(Sender: TObject);
begin
  CheckListBox1.Style := lbOwnerDrawVariable;
  CheckListBox1.Clear;

  Stroke.Enabled := false;

  ExtendedUpdateCaption;

  newLineEdt.Clear;
end;

procedure TMDIAppender.RefreshList;
begin
  CheckListBox1.Items.Clear;
  CheckListBox1.Items.LoadFromFile(getAppenderFileName(folder, cat));
  CheckListBox1.TopIndex := CheckListBox1.Items.Count-1; // Nach unten scrollen
end;

function TransformDrawingText(s: string): string;
begin
  result := StringReplace(s, #9, '                ', [rfReplaceAll]);     // TODO: gilt nicht für w95...
end;

// http://www.delphipraxis.net/post1068742.html#1068742
// Bugfix: Invalidate
// Bugfix: Leere Zeilen

procedure TMDIAppender.CheckListBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with CheckListbox1.Canvas do
  begin
    FillRect(Rect);
    DrawText(Handle, PChar(TransformDrawingText(CheckListBox1.Items[Index])), -1, Rect, DT_LEFT or DT_TOP or DT_WORDBREAK);
    Invalidate;
  end;
end;

procedure TMDIAppender.CheckListBox1KeyPress(Sender: TObject; var Key: Char);
begin
  CheckListBox1Click(self); // z.B. wenn man die Leertaste drÃ¼ckt
end;

procedure TMDIAppender.CheckListBox1MeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
var
  tempCanvas: TCanvas;
  notUsed: HWND;
  destRect: TRect;
  txt: PChar;
begin
  tempCanvas := TCanvas.Create;
  try
    tempCanvas.Handle := GetDeviceContext(notUsed);
    destRect := CheckListBox1.ClientRect;
    if CheckListBox1.Items[Index] = '' then
      txt := ' '
    else
      txt := PChar(TransformDrawingText(CheckListBox1.Items[Index]));
    Height := DrawText(tempCanvas.Handle, txt, -1, destRect, DT_WORDBREAK);
  finally
    tempCanvas.Free;
  end;
end;

procedure TMDIAppender.StrokeClick(Sender: TObject);
var
  userResponse: integer;
begin
  userResponse := MessageDlg(Format(lng_stroker_really, [StrokeCount]), mtConfirmation, mbYesNoCancel, 0);

  if userResponse = idYes then
  begin
    DoStroke;
  end;
end;

function TMDIAppender.StrokeCount: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to CheckListBox1.Count - 1 do
  begin
    if CheckListBox1.Checked[i] then
    begin
      inc(result);
    end;
  end;
end;

procedure TMDIAppender.Neuladen1Click(Sender: TObject);
var
  userResponse: integer;
begin
  userResponse := 0;

  if stroke.Enabled then
  begin
    userResponse := MessageDlg(Format(lng_refresh_strokes_loss, [StrokeCount]), mtWarning, mbYesNoCancel, 0);
  end;

  if (not stroke.Enabled) or (userResponse = idYes) then
  begin
    CheckListBox1.Visible := false;
    RefreshList;
    CheckListBox1.Visible := true;
  end;
end;

procedure TMDIAppender.CheckListBox1Click(Sender: TObject);
var
  i: integer;
begin
  Stroke.Enabled := false;

  for i := 0 to CheckListBox1.Count - 1 do
  begin
    if CheckListBox1.Checked[i] then
    begin
      Stroke.Enabled := true;
      break;
    end;
  end;

  ExtendedUpdateCaption;
end;

procedure TMDIAppender.newLineEdtChange(Sender: TObject);
begin
  Save.Enabled := newLineEdt.Text <> '';
  ExtendedUpdateCaption;
end;

procedure TMDIAppender.ExtendedUpdateCaption;
var
  changed: boolean;
  capname: string;
begin
  changed := Save.Enabled or Stroke.Enabled;

  capname := Format(lng_editor_title, [folder + cat]);
  if changed then capname := capname + ' *';

  if Caption <> capname then Caption := capname; // Kein Aufblitzen
end;

end.
