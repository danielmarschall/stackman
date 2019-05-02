unit global;

interface

uses
  SysUtils, Classes, Dialogs, Forms, Windows, ShellAPI, Controls,
  ComCtrls, WinInet;

type
  TAMode = (emUnknown, emFolder, emText, emAppender, emForeign);

// TODO: So viel wie möglich in den implementation Teil schieben
function allFiles(folder: string): string;
function FilenameToCatname(fil: string): string;
procedure StrokeFromFile(filename: string; index: integer; expected_text: string);
procedure AddToJournal(text: string);
function RemoveForbiddenChars(fn: string; dir: boolean): string;
procedure JournalDeleteEntry(fn: string);
function commonDelete(fn: string): boolean;
procedure commonExternalOpen(fn: string);
function GetUserFriendlyElementName(fn: string): string;
procedure openCategoriesWindow();
procedure newDialog(folder: string);
procedure OpenTextEditor(folder, cat: string);
procedure OpenAppenderEditor(folder, cat: string);
procedure renameDialog(Node: TTreeNode);
function DelTree(DirName : string): Boolean;
function MyAddTrailingPathDelimiter(folder: string): string;
function getDataPath(): string;
function getJournalFileName(): string;
function getAppenderFileName(Folder, Name: string): string;
function getTextFileName(Folder, Name: string): string;
function getFolderName(Folder, Name: string): string;
function GetRelativeNameFromNode(Node: TTreeNode): string;
function GetRelativeFileName(Filename: string): string;
function GetFileNameFromNode(Node: TTreeNode): string;
function GetFolderFromNode(Node: TTreeNode): string;
function IsTextNode(Node: TTreeNode): boolean;
function IsFolderNode(Node: TTreeNode): boolean;
function IsAppenderNode(Node: TTreeNode): boolean;
function IsForeignNode(Node: TTreeNode): boolean;
function IsRootNode(Node: TTreeNode): boolean;
// function GetPersonalFolder(Default: string): string; overload;
function GetPersonalFolder(): string; overload;
function GetCatFromNode(Node: TTreeNode): string;
Function GetHTML(AUrl: string): string;
procedure explode(delim: char; s: string; sl: TStringList);

type
  EStrokeUnknown = class(Exception);
  EStrokeMismatch = class(Exception);
  ENodeError = class(Exception);
  EInternalError = class(Exception);

resourcestring
  lng_cap_new = 'Neue Datei anlegen';
  lng_cap_rename = 'Umbennen';
  lng_jnl_renamed = 'Umbenannt: "%s" zu "%s".';
  lng_already_exists = 'Fehler! Die Datei "%s" existiert bereits.';
  lng_move_error = 'Fehler! Konnte nicht von "%s" nach "%s" verschieben.';
  lng_jnl_delete = 'LÖSCHE %s';
  lng_content_was = 'Der Inhalt war:';
  lng_no_content = 'Die Datei war leer.';
  lng_jnl_open_external = 'Öffne mit externem Programm: %s';
  lng_jnl_created = 'Erstellt: %s';
  lng_jnl_stroke_from = 'Streiche von %s:';
  lng_jnl_add_to = 'Füge hinzu: %s';
  lng_jnl_textchange = 'Textinhalt geändert: %s';
  lng_filenotfound = 'Datei wurde nicht gefunden.';
  lng_editor_title = '%s - Streichlisteneditor';
  lng_texteditor_title = '%s - AUTOSAVE Texteditor';
  lng_stroker_really = 'Möchten Sie diese %d Zeilen wirklich streichen?';
  lng_refresh_strokes_loss = 'Warnung: Beim Neu-Laden werden alle Streich-Vormerkungen (%d) entfernt. Wirklich neu laden?';
  lng_appendfirst = 'Neue Zeile vor dem Schließen in "%s" ablegen?';
  lng_savefirst = 'Die Änderungen an "%s" abspeichern?';
  lng_strokefirst = '%d markierte Zeilen in "%s" vor dem Schließen streichen?';
  lng_notdeleted = 'Fehler: Datei konnte nicht gelöscht werden!';
  lng_error = 'Ein Fehler ist aufgetreten.';
  lng_journal_error = 'Es konnte nicht in das Journal geschrieben werden!';
  lng_deletethis = 'Datensatz "%s" wirklich löschen?';
  lng_notcreated = 'Fehler: Datei konnte nicht erstellt werden!';
  lng_alreadyexists_open = 'Die Datei existiert bereits. Sie wird nun geöffnet.';
  lng_stroke_mismatch = 'Die zu streichende Zeile stimmt nicht mit der angezeigten Fassung überein.';
  lng_stroke_error = 'Unbekannter Fehler beim Streichen.';
  lng_root = 'Datensätze';
  lng_text = 'Text';
  lng_appender = 'Streichliste';

const
  app_pfx = 'app_';
  txt_pfx = 'tex_';
  c_length_of_pfx = Length(app_pfx); // = Length(txt_pfx)
  II_APPENDER = 0;
  II_TEXT = 1;
  II_FOLDER = 2;
  II_FOREIGN = 3;
  II_ROOT = 4;
  FOLDER_VIEWER = 'Explorer';

// Konfiguration
const
  CfgExpandNodesAtBeginning = false;
  CfgOpenCatWhenEverythingClosed = false;
  CfgAppenderAllowEmptyLines = true;

implementation

uses
  categories, journal, name, appender, texteditor;

resourcestring
  lng_internal_prefix_length_error = 'Entwicklungstechnischer Fehler! Präfixe dürfen nicht unterschiedlich lang sein!';
  lng_internal_unknown_node_type_error = 'Programminterner Fehler! Node-Typ unbekannt!';

function GetModeFromNode(ANode: TTreeNode): TAMode; forward;
function getFileName(mode: TAMode; folder, name: string): string; forward;
function ExtractFileNameWithoutExt(fil: string): string; forward;
function getRawFileName(folder, name: string): string; forward;
function Quote(arg: string): string; forward;

function allFiles(folder: string): string;
begin
  result := getRawFilename(folder, '*');
end;

function ExtractFileNameWithoutExt(fil: string): string;
begin
  result := Copy(ExtractFileName(fil), 1, Length(ExtractFileName(fil))-Length(ExtractFileExt(fil)));
end;

function FilenameToCatname(fil: string): string;
begin
  result := ExtractFileNameWithoutExt(fil);
  result := Copy(result, 1+c_length_of_pfx, length(result)-c_length_of_pfx);
  result := ExtractFilePath(fil) + result;
end;

procedure StrokeFromFile(filename: string; index: integer; expected_text: string);
var
  str: TStrings;
begin
  str := TStringList.Create;
  try
    try
      str.LoadFromFile(filename);
      if str.Strings[index] = expected_text then
        str.Delete(index)
      else
        raise EStrokeMismatch.Create(lng_stroke_mismatch);
      str.SaveToFile(filename);
    except
      on E: EStrokeMismatch do
        raise
      else
        raise EStrokeUnknown.Create(lng_stroke_error);
    end;
  finally
    str.Free;
  end;
end;

procedure AddToJournal(text: string);
var
  f: TextFile;
  l: string;
  i: integer;
begin
  l := Format('[%s] %s', [DateTimeToStr(Now()), text]);

  try
    AssignFile(f, getJournalFileName());
    try
      if FileExists(getJournalFileName()) then
        Append(f)
      else
        ReWrite(f);
      WriteLn(f, l);
    finally
      CloseFile(f);
    end;
  except
    ShowMessage(lng_journal_error);
  end;

  // Andere Forms benachrichtigen

  for i := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[i] is TMDIJournalForm then
    begin
      TMDIJournalForm(Screen.Forms[i]).DoRefresh;
      break;
    end
  end;
end;

function RemoveForbiddenChars(fn: string; dir: boolean): string;
begin
  result := fn;
  fn := StringReplace(fn, '<', '_', [rfReplaceAll]);
  fn := StringReplace(fn, '>', '_', [rfReplaceAll]);
  fn := StringReplace(fn, '|', '_', [rfReplaceAll]);
  fn := StringReplace(fn, '"', '_', [rfReplaceAll]);
  fn := StringReplace(fn, '?', '_', [rfReplaceAll]);
  fn := StringReplace(fn, ':', '_', [rfReplaceAll]);
  fn := StringReplace(fn, '/', '_', [rfReplaceAll]);
  if not dir then fn := StringReplace(fn, '\', '_', [rfReplaceAll]);
  fn := StringReplace(fn, '*', '_', [rfReplaceAll]);
end;

procedure JournalDeleteEntry(fn: string);
var
  dump: TStringList;
  i: integer;
begin
  if not fileexists(fn) then exit;

  AddToJournal(Format(lng_jnl_delete, [GetUserFriendlyElementName(fn)]));

  dump := TStringList.Create;
  try
    dump.LoadFromFile(fn);

    if dump.Count > 0 then
    begin
      AddToJournal(lng_content_was);
      for i := 0 to dump.Count - 1 do
      begin
        AddToJournal('- ' + dump.Strings[i]);
      end;
    end
    else
    begin
      AddToJournal(lng_no_content);
    end;
  finally
    dump.Free;
  end;
end;

function commonDelete(fn: string): boolean;
var
  userResponse: integer;
begin
  result := false;

  userResponse := MessageDlg(Format(lng_deletethis, [GetRelativeFileName(fn)]),
    mtConfirmation, mbYesNoCancel, 0);

  if userResponse = idYes then
  begin
    JournalDeleteEntry(fn);

    if fileexists(fn) then
    begin
      DeleteFile(PChar(fn));
    end
    else if directoryexists(fn) then
    begin
      DelTree(fn);
    end;

    if FileExists(fn) or DirectoryExists(fn) then
    begin
      ShowMessage(lng_notdeleted);
      Exit;
    end;

    result := true;
  end;
end;

function GetUserFriendlyElementName(fn: string): string;
begin
  result := GetRelativeFileName(fn); // TODO: Benutzer soll was anderes sehen als die Dateinamenserweiterungen
end;

procedure commonExternalOpen(fn: string);
begin
  AddToJournal(Format(lng_jnl_open_external, [GetUserFriendlyElementName(fn)]));

  if FileExists(fn) then
  begin
    ShellExecute(Application.Handle, 'open', PChar(fn), '',
      PChar(Quote(fn)), SW_NORMAL);
  end
  else if DirectoryExists(fn) then
  begin
    ShellExecute(Application.Handle, 'open', FOLDER_VIEWER,
      PChar(Quote(fn)), '', SW_NORMAL);
  end
  else
  begin
    ShowMessage(lng_filenotfound);
  end;
end;

procedure openCategoriesWindow();
var
  i: integer;
  somethingfound: boolean;
begin
  somethingfound := false;

  for i := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[i] is TMDICategories then
    begin
      TMDICategories(Screen.Forms[i]).RefreshList;
      Screen.Forms[i].BringToFront;
      Screen.Forms[i].WindowState := wsNormal;
      somethingfound := true;
      break;
    end
  end;

  if not somethingfound then
  begin
    TMDICategories.Create(Application);
  end;
end;

procedure newDialog(folder: string);
var
  f: TextFile;
  realfolder, new_folder, new_cat: string;
  i: integer;
  new_fn: string;
  em: TAMode;
  beschreibung: string;
begin
  NameDlg.Caption := lng_cap_new;
  NameDlg.NameEdt.Text := '';
  NameDlg.Textmode.Checked := false;
  NameDlg.Textmode.Enabled := true;

  if NameDlg.ShowModal = mrOk then
  begin
    new_cat := ExtractFileName(namedlg.NameEdt.Text);
    new_cat := RemoveForbiddenChars(new_cat, false);

    folder := MyAddTrailingPathDelimiter(folder);

    new_folder := ExtractFilePath(namedlg.NameEdt.Text);
    new_folder := RemoveForbiddenChars(folder + new_folder, true);

    if NameDlg.Textmode.Checked then
    begin
      new_fn := getTextFileName(new_folder, new_cat);
      em := emText;
      beschreibung := lng_text;
    end
    else
    begin
      new_fn := getAppenderFileName(new_folder, new_cat);
      em := emAppender;
      beschreibung := lng_appender;
    end;

    new_fn := RemoveForbiddenChars(new_fn, false);

    realfolder := ExtractFilePath(new_fn);
    ForceDirectories(realfolder);

    if FileExists(new_fn) then
    begin
      ShowMessage(lng_alreadyexists_open);
      if em = emText then
        OpenTextEditor(new_folder, new_cat)
      else
        OpenAppenderEditor(new_folder, new_cat);
      Exit;
    end;

    AssignFile(f, new_fn);
    ReWrite(f);
    CloseFile(f);

    if not FileExists(new_fn) then
    begin
      ShowMessage(lng_notcreated);
      Exit;
    end;

    AddToJournal(Format(lng_jnl_created, [GetUserFriendlyElementName(new_fn)]));

    for i := Screen.FormCount - 1 downto 0 do
    begin
      if Screen.Forms[i] is TMDICategories then
      begin
        // TMDICategories(Screen.Forms[i]).RefreshList;

        TMDICategories(Screen.Forms[i]).InsertNode(new_folder, new_cat, em);
      end
    end;

    if em = emText then
      OpenTextEditor(new_folder, new_cat)
    else
      OpenAppenderEditor(new_folder, new_cat);
  end;
end;

procedure OpenTextEditor(folder, cat: string);
var
  somethingfound: boolean;
  i: integer;
begin
  somethingfound := false;

  for i := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[i] is TMDITextEditor then
    begin
      if (TMDITextEditor(Screen.Forms[i]).cat = cat) and
         (TMDITextEditor(Screen.Forms[i]).folder = folder) then
      begin
        Screen.Forms[i].BringToFront;
        Screen.Forms[i].WindowState := wsNormal;
        somethingfound := true;
        break;
      end;
    end
  end;

  if not somethingfound then
  begin
    TMDITextEditor.Create(Application, folder, cat);
  end;
end;

procedure OpenAppenderEditor(folder, cat: string);
var
  somethingfound: boolean;
  i: integer;
begin
  somethingfound := false;

  for i := Screen.FormCount - 1 downto 0 do
  begin
    if Screen.Forms[i] is TMDIAppender then
    begin
      if (TMDIAppender(Screen.Forms[i]).cat = cat) and
         (TMDIAppender(Screen.Forms[i]).folder = folder) then
      begin
        Screen.Forms[i].BringToFront;
        Screen.Forms[i].WindowState := wsNormal;
        somethingfound := true;
        break;
      end;
    end
  end;

  if not somethingfound then
  begin
    TMDIAppender.Create(Application, folder, cat);
  end;
end;

function GetModeFromNode(ANode: TTreeNode): TAMode;
begin
  result := emUnknown;

  if IsAppenderNode(ANode) then
  begin
    result := emAppender;
  end
  else if IsTextNode(ANode) then
  begin
    result := emText;
  end
  else if IsFolderNode(ANode) then
  begin
    result := emFolder;
  end else if IsForeignNode(ANode) then
  begin
    result := emForeign;
  end;

  if result = emUnknown then
  begin
    raise ENodeError.Create(lng_internal_unknown_node_type_error);
  end;
end;

function getFileName(mode: TAMode; folder, name: string): string;
begin
  if (mode = emFolder) or (mode = emForeign) then
  begin
    result := getFolderName(folder, name);
    result := RemoveForbiddenChars(result, true);
  end
  else if mode = emText then
  begin
    result := getTextFileName(folder, name);
    result := RemoveForbiddenChars(result, false);
  end
  else if mode = emAppender then
  begin
    result := getAppenderFileName(folder, name);
    result := RemoveForbiddenChars(result, false);
  end
  else
  begin
    raise ENodeError.Create(lng_internal_unknown_node_type_error);
  end;
end;

procedure renameDialog(Node: TTreeNode);
var
  realfolder, new_cat, new_folder: string;
  i: integer;
  tofile, fromfile: string;
  old_folder, old_cat: string;
  old_em, new_em: TAMode;
const
  folder = ''; // Wir gehen beim Umbenennen von der Wurzel aus
begin
  old_em := GetModeFromNode(Node);
  old_folder := GetFolderFromNode(Node);
  old_cat := GetCatFromNode(Node);

  NameDlg.Caption := lng_cap_rename;
  NameDlg.NameEdt.Text := old_folder + old_cat;
  NameDlg.Textmode.Checked := IsTextNode(Node);
  NameDlg.Textmode.Enabled := not IsFolderNode(Node) and not IsForeignNode(Node);

  if NameDlg.ShowModal = mrOk then
  begin
    if IsFolderNode(Node) or IsForeignNode(Node) then
    begin
      new_em := old_em;
    end
    else
    begin
      if NameDlg.Textmode.Checked then
        new_em := emText
      else
        new_em := emAppender;
    end;

    new_cat := ExtractFileName(namedlg.NameEdt.Text);
    new_cat := RemoveForbiddenChars(new_cat, false);

    // folder := MyAddTrailingPathDelimiter(folder);

    new_folder := ExtractFilePath(namedlg.NameEdt.Text);
    new_folder := RemoveForbiddenChars(folder + new_folder, true);

    realfolder := ExtractFilePath(getFileName(old_em, new_folder, new_cat));
    if not IsFolderNode(Node) then ForceDirectories(realfolder);

    // Enthält RemoveForbiddenChars()
    fromfile := getFileName(old_em, old_folder, old_cat);
    tofile := getFileName(new_em, new_folder, new_cat);

    if fromfile = tofile then exit;

    if fileExists(tofile) then
    begin
      ShowMessageFmt(lng_already_exists, [GetUserFriendlyElementName(tofile)]);
      Exit;
    end;

    if not moveFile(pchar(fromfile), pchar(tofile)) then
    begin
      ShowMessageFmt(lng_move_error, [GetUserFriendlyElementName(fromfile), GetUserFriendlyElementName(tofile)]);
      Exit;
    end;

    AddToJournal(Format(lng_jnl_renamed, [GetUserFriendlyElementName(fromfile), GetUserFriendlyElementName(tofile)]));

    for i := Screen.FormCount - 1 downto 0 do
    begin
      if Screen.Forms[i] is TMDICategories then
      begin
        // TMDICategories(Screen.Forms[i]).RefreshList;

        TMDICategories(Screen.Forms[i]).DeleteNode(old_folder, old_cat);
        TMDICategories(Screen.Forms[i]).InsertNode(new_folder, new_cat, new_em);
      end
    end;

    Node.Selected := true;
  end;
end;

// http://delphi.about.com/cs/adptips1999/a/bltip1199_2.htm
// Modifiziert
Function DelTree(DirName : string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf : array [0..MAX_PATH] of char;
begin
  // Backslash am Ende entfernen
  if Copy(DirName, length(DirName), 1) = PathDelim then
    DirName := Copy(DirName, 1, Length(DirName)-1);

  try
    Fillchar(SHFileOpStruct, SizeOf(SHFileOpStruct), 0);
    FillChar(DirBuf, SizeOf(DirBuf), 0);
    StrPCopy(DirBuf, DirName);
    with SHFileOpStruct do
    begin
      Wnd := 0;
      pFrom := @DirBuf;
      wFunc := FO_DELETE;
      fFlags := FOF_ALLOWUNDO;
      fFlags := fFlags or FOF_NOCONFIRMATION;
      fFlags := fFlags or FOF_SILENT;
    end;
    Result := (SHFileOperation(SHFileOpStruct) = 0);
  except
    Result := False;
  end;
end;

function MyAddTrailingPathDelimiter(folder: string): string;
begin
  result := folder;

  if folder = '' then exit;

  result := IncludeTrailingPathDelimiter(folder);

  //if Copy(folder, length(folder), 1) <> PathDelim then
  //  result := result + PathDelim;
end;

function getDataPath(): string;
const
  DataDirName = 'StackMan-Data';
begin
  if directoryExists(DataDirName) then
    result := DataDirName + PathDelim
  else
    result := GetPersonalFolder() + DataDirName + PathDelim;
end;

function getJournalFileName(): string;
const
  JournalFile = 'Journal.txt';
begin
  result := getDataPath() + JournalFile;
end;

function getRawFileName(folder, name: string): string;
begin
  Folder := MyAddTrailingPathDelimiter(folder);
  result := getDataPath() + Folder + name;
end;

function getAppenderFileName(Folder, Name: string): string;
begin
  result := getRawFileName(folder, app_pfx + Name + '.txt');
end;

function getTextFileName(Folder, Name: string): string;
begin
  result := getRawFileName(folder, txt_pfx + Name + '.txt');
end;

function getFolderName(Folder, Name: string): string;
begin
  result := getRawFileName(folder, Name);
end;

function GetRelativeFileName(Filename: string): string;
var
  datadir: string;
begin
  result := filename;
  datadir := getDataPath();

  if LowerCase(copy(result, 1, length(datadir))) = LowerCase(datadir) then
  begin
    result := copy(result, 1+length(datadir), length(result)-length(datadir));
  end;
end;

function GetRelativeNameFromNode(Node: TTreeNode): string;
begin
  result := getFilenameFromNode(Node);
  result := GetRelativeFileName(result);
  // result := FilenameToCatname(result);
end;

function IsTextNode(Node: TTreeNode): boolean;
begin
  result := Node.ImageIndex = II_TEXT;
end;

function IsFolderNode(Node: TTreeNode): boolean;
begin
  result := Node.ImageIndex = II_FOLDER;
end;

function IsAppenderNode(Node: TTreeNode): boolean;
begin
  result := Node.ImageIndex = II_APPENDER;
end;

function IsForeignNode(Node: TTreeNode): boolean;
begin
  result := Node.ImageIndex = II_FOREIGN;
end;

function IsRootNode(Node: TTreeNode): boolean;
begin
  result := Node.ImageIndex = II_ROOT;
end;

function GetFileNameFromNode(Node: TTreeNode): string;
var
  folder: string;
begin
  folder := GetFolderFromNode(Node);

  if IsTextNode(Node) then
  begin
    result := GetTextFileName(folder, GetCatFromNode(Node));
  end
  else if IsAppenderNode(Node) then
  begin
    result := GetAppenderFileName(folder, GetCatFromNode(Node));
  end
  else if IsForeignNode(Node) then
  begin
    result := GetRawFileName(folder, GetCatFromNode(Node));
  end
  else if isRootNode(Node) then
  begin
    result := getDataPath();
  end
  else if IsFolderNode(Node) then
  begin
    result := GetRawFileName(folder, '');
  end
  else
  begin
    raise ENodeError.Create(lng_internal_unknown_node_type_error);
  end;
end;

function GetFolderFromNode(Node: TTreeNode): string;
var
  par: TTreeNode;
begin
  if isRootNode(node) then exit;
  if isFolderNode(node) then
    par := node
  else
    par := node.Parent;
  while not isRootNode(par) do
  begin
    result := par.Text + PathDelim + result;
    par := par.Parent;
  end;
end;

function Quote(arg: string): string;
begin
  result := '"' + arg + '"';
end;

(* function GetPersonalFolder: string;
var
  path : array [0..MAX_PATH] of char;
begin
  SHGetSpecialFolderPath(0, @path, CSIDL_PERSONAL, false);
  if path = '' then
    result := ExtractFilePath(Application.ExeName)
  else
    result := IncludeTrailingPathDelimiter(path);
end; *)

function GetPersonalFolder(DefaultPath: string): string; overload;
// This function replaces SHGetSpecialFolderPath from ShlObj.pas .
// It dynamically loads the DLL, so that also Windows 95 without
// Internet Explorer 4 Extension can work with it.
type
  TSHGetSpecialFolderPath = function(hwndOwner: HWND; lpszPath: PChar;
    nFolder: Integer; fCreate: BOOL): BOOL; stdcall;
    
  procedure Fail;
  begin
    if DefaultPath = '' then
      result := ExtractFilePath(ParamStr(0))
    else
      result := IncludeTrailingPathDelimiter(DefaultPath);
  end;

const
{$IFDEF MSWINDOWS}
  shell32 = 'shell32.dll';
{$ENDIF}
{$IFDEF LINUX}
  shell32 = 'libshell32.borland.so';
{$ENDIF}
CSIDL_PERSONAL = $0005;
var
  SpecialFolder: TSHGetSpecialFolderPath;
  Handle: THandle;
  path: array [0..MAX_PATH] of char;
begin
  result := '';
  Handle := LoadLibrary(shell32);
  if Handle <> 0 then
  begin
    {$IFDEF UNICODE}
    @SpecialFolder := GetProcAddress(Handle, 'SHGetSpecialFolderPathW');
    {$ELSE}
    @SpecialFolder := GetProcAddress(Handle, 'SHGetSpecialFolderPathA');
    {$ENDIF}
    if @SpecialFolder <> nil then
    begin
      FillChar(path, sizeof(path), 0);
      if SpecialFolder(0, @path, CSIDL_PERSONAL, false) and (path <> '') then
      begin
        result := IncludeTrailingPathDelimiter(path)
      end
      else
      begin
        Fail;
      end;
    end
    else
    begin
      Fail;
    end;
    FreeLibrary(Handle);
  end
  else
  begin
    Fail;
  end;
end;

function GetPersonalFolder(): string;
begin
  result := GetPersonalFolder('C:\');
end;

function GetCatFromNode(Node: TTreeNode): string;
begin
  if IsFolderNode(Node) then
    result := ''
  else
    result := Node.Text;
end;

// http://www.delphipraxis.net/post43515.html
Function GetHTML(AUrl: string): string;
var
  databuffer : array[0..4095] of char;
  ResStr : string;
  hSession, hfile: hInternet;
  dwindex,dwcodelen,dwread,dwNumber: cardinal;
  dwcode : array[1..20] of char;
  res    : pchar;
  Str    : pchar;
begin
  ResStr:='';
  if system.pos('http://',lowercase(AUrl))=0 then
     AUrl:='http://'+AUrl;

  // Hinzugefügt
  application.ProcessMessages;

  hSession:=InternetOpen('InetURL:/1.0',
                         INTERNET_OPEN_TYPE_PRECONFIG,
                         nil,
                         nil,
                         0);
  if assigned(hsession) then
  begin
    // Hinzugefügt
    application.ProcessMessages;

    hfile:=InternetOpenUrl(
           hsession,
           pchar(AUrl),
           nil,
           0,
           INTERNET_FLAG_RELOAD,
           0);
    dwIndex  := 0;
    dwCodeLen := 10;

    // Hinzugefügt
    application.ProcessMessages;

    HttpQueryInfo(hfile,
                  HTTP_QUERY_STATUS_CODE,
                  @dwcode,
                  dwcodeLen,
                  dwIndex);
    res := pchar(@dwcode);
    dwNumber := sizeof(databuffer)-1;
    if (res ='200') or (res ='302') then
    begin
      while (InternetReadfile(hfile,
                              @databuffer,
                              dwNumber,
                              DwRead)) do
      begin

        // Hinzugefügt
        application.ProcessMessages;

        if dwRead =0 then
          break;
        databuffer[dwread]:=#0;
        Str := pchar(@databuffer);
        resStr := resStr + Str;
      end;
    end
    else
      ResStr := 'Status:'+res;
    if assigned(hfile) then
      InternetCloseHandle(hfile);
  end;

  // Hinzugefügt
  application.ProcessMessages;

  InternetCloseHandle(hsession);
  Result := resStr;
end;

procedure explode(delim: char; s: string; sl: TStringList);
var
  i: integer;
  tmp: string;
begin
  tmp := '';
  for i := 1 to length(s) do
  begin
    if s[i] = delim then
    begin
      sl.Add(tmp);
      tmp := '';
    end
    else
      tmp := tmp + s[i];
  end;
  sl.Add(tmp);
end;

begin
  if Length(app_pfx) <> Length(txt_pfx) then
  begin
    raise EInternalError.Create(lng_internal_prefix_length_error);
    Halt;
  end;
end.




