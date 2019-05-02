unit categories;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList, Menus, ShellAPI, global;

type
  TMDICategories = class(TForm)
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    Kategorie1: TMenuItem;
    KategorieDelete1: TMenuItem;
    EditorOpen: TMenuItem;
    N2: TMenuItem;
    KategorieRefresh1: TMenuItem;
    KategorieClose1: TMenuItem;
    PopupMenu1: TPopupMenu;
    PEditor: TMenuItem;
    PDelete: TMenuItem;
    PExternal: TMenuItem;
    N4: TMenuItem;
    ExternalOpen: TMenuItem;
    N5: TMenuItem;
    PUmbenennen: TMenuItem;
    KategorieUmbenennen1: TMenuItem;
    TreeView1: TTreeView;
    PNeu: TMenuItem;
    N1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure KategorieDelete1Click(Sender: TObject);
    procedure EditorOpenClick(Sender: TObject);
    procedure KategorieClose1Click(Sender: TObject);
    procedure KategorieRefresh1Click(Sender: TObject);
    procedure ExternalOpenClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure KategorieUmbenennen1Click(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure PNeuClick(Sender: TObject);
    procedure TreeView1KeyPress(Sender: TObject; var Key: Char);
  private
    procedure recursiveItemListing(folder: string; parentnode: TTreeNode);
  public
    procedure DeleteNode(folder, cat: string);
    procedure InsertNode(folder, cat: string; em: TAMode);
    procedure RefreshList;
    procedure DoNew;
  end;

var
  MDICategories: TMDICategories;

implementation

{$R *.dfm}

uses
  main;

procedure TMDICategories.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDICategories.FormShow(Sender: TObject);
begin
  RefreshList;
  TreeView1.SetFocus;
end;

procedure TMDICategories.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  // if Change = ctState then
  // begin
    PNeu.Visible := true;
    N1.Visible := true;
    PEditor.Visible := true;
    PExternal.Visible := true;
    N2.Visible := true;
    PDelete.Visible := true;

    PNeu.Default := false;
    PEditor.Default := true;

    //PNeu.Enabled := (TreeView1.SelectionCount = 1) and
    //  ((IsFolderNode(TreeView1.Selected)) or
    //   (IsRootNode(TreeView1.Selected)));
    PNeu.Enabled := true;

    EditorOpen.Enabled := (TreeView1.SelectionCount = 1) and
      ((IsAppenderNode(TreeView1.Selected)) or
       (IsForeignNode(TreeView1.Selected)) or
       (IsTextNode(TreeView1.Selected)));
    ExternalOpen.Enabled := (TreeView1.SelectionCount = 1) and
      ((IsAppenderNode(TreeView1.Selected)) or
       (IsRootNode(TreeView1.Selected)) or
       (IsFolderNode(TreeView1.Selected)) or
       (IsForeignNode(TreeView1.Selected)) or
       (IsTextNode(TreeView1.Selected)));
    KategorieDelete1.Enabled := (TreeView1.SelectionCount = 1) and
      ((IsAppenderNode(TreeView1.Selected)) or
       (IsFolderNode(TreeView1.Selected)) or
       (IsForeignNode(TreeView1.Selected)) or
       (IsTextNode(TreeView1.Selected)));
    KategorieUmbenennen1.Enabled := (TreeView1.SelectionCount = 1) and
      ((IsAppenderNode(TreeView1.Selected)) or
       (IsFolderNode(TreeView1.Selected)) or
       (IsForeignNode(TreeView1.Selected)) or
       (IsTextNode(TreeView1.Selected)));

    PEditor.Enabled := EditorOpen.Enabled;
    PExternal.Enabled := ExternalOpen.Enabled;
    PDelete.Enabled := KategorieDelete1.Enabled;
    PUmbenennen.Enabled := KategorieUmbenennen1.Enabled;
  // end;
end;

procedure TMDICategories.TreeView1DblClick(Sender: TObject);
begin
  if TreeView1.SelectionCount = 1 then
  begin
    EditorOpen.Click;
  end;
end;

procedure TMDICategories.TreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    if TreeView1.SelectionCount = 1 then
    begin
      if TreeView1.Selected.HasChildren then
      begin
        if TreeView1.Selected.Expanded then
          TreeView1.Selected.Collapse(false)
        else
          TreeView1.Selected.Expand(false);
      end
      else
      begin
        EditorOpen.Click;
      end;
    end;
  end;
end;

procedure TMDICategories.RefreshList;
var
  root: TTreeNode;
begin
  TreeView1.Visible := false;
  TreeView1.Items.Clear;
  TreeView1.Visible := true;

  root := TreeView1.Items.Add(nil, lng_root);
  root.ImageIndex := II_ROOT;
  root.SelectedIndex := II_ROOT;
  recursiveItemListing('', root);
  root.Expand(false);
end;

procedure TMDICategories.KategorieDelete1Click(Sender: TObject);
var
  fn: string;
begin
  if TreeView1.SelectionCount = 1 then
  begin
    fn := GetFileNameFromNode(TreeView1.Selected);
    if commonDelete(fn) then
    begin
       // TODO: Eigentlich sollte das innerhalb von commonDelete() stattfinden
      TreeView1.Selected.Delete;
    end;
  end;
end;

procedure TMDICategories.DeleteNode(folder, cat: string);

  procedure Rec(folder, cat: string; t: TTreeNode);
  var
    i: integer;
  begin
    if (folder = GetFolderFromNode(t)) and
       (cat = GetCatFromNode(t)) then
    begin
      t.Delete;
      exit;
    end;

    for i := t.Count - 1 downto 0 do
    begin
      Rec(folder, cat, t.Item[i]);
    end;
  end;

begin
  Rec(folder, cat, treeview1.Items.Item[0]);
end;

procedure TMDICategories.InsertNode(folder, cat: string; em: TAMode);

  procedure Rec(folder, cat: string; em: TAMode; t: TTreeNode);
  var
    i: integer;
    n: TTreeNode;
  begin
    if (folder = GetFolderFromNode(t)) and
       (IsFolderNode(t) or IsRootNode(t)) then
    begin
      n := treeview1.Items.AddChild(t, cat);
      t.Expand(false); // Ordner aufklappen
      with n do
      begin
        if em = emFolder then
        begin
          ImageIndex := II_FOLDER;
          SelectedIndex := II_FOLDER;
          recursiveItemListing(folder + cat, n);
        end
        else
        begin
          if em = emText then
          begin
            ImageIndex := II_TEXT;
            SelectedIndex := II_TEXT;
          end
          else if em = emAppender then
          begin
            ImageIndex := II_APPENDER;
            SelectedIndex := II_APPENDER;
          end
          else if em = emForeign then
          begin
            ImageIndex := II_FOREIGN;
            SelectedIndex := II_FOREIGN;
          end;
        end;
      end;

      exit;
    end;

    for i := t.Count - 1 downto 0 do
    begin
      Rec(folder, cat, em, t.Item[i]);
    end;
  end;

  procedure NodeForceDir(folder: string);

    function CreateIfExists(foldername: string; node: TTreeNode): TTreeNode;
    var
      i: integer;
      somethingfound: boolean;
    begin
      result := nil;

      somethingfound := false;
      for i := 0 to node.Count - 1 do
      begin
        if (node.Item[i].Text = foldername) and
           (IsFolderNode(node.Item[i]) or IsRootNode(node.Item[i])) then
        begin
          somethingfound := true;
          result := node.Item[i];
          break;
        end;
      end;

      if not somethingfound then
      begin
        result := treeview1.Items.AddChild(node, foldername);
        node.Expand(false);

        with result do
        begin
          ImageIndex := II_FOLDER;
          SelectedIndex := II_FOLDER;
        end;
      end;
    end;

  var
    x: tstringlist;
    i: Integer;
    node: TTreeNode;
  begin
    x := TStringList.Create;
    try
      Explode(PathDelim, folder, x);
      node := treeview1.Items.Item[0];
      for i := 0 to x.count - 1 do
      begin
        if x.Strings[i] <> '' then
        begin
          node := CreateIfExists(x.Strings[i], node);
        end;
      end;
    finally
      x.Free;
    end;
  end;

var
  sl: TStringList;
  i: integer;
begin
  if (em = emFolder) and (cat = '') then
  begin
    sl := TStringList.Create;
    try
      explode(PathDelim, folder, sl);
      cat := sl.Strings[sl.Count-2];
      folder := '';
      for i := 0 to sl.Count - 3 do
      begin
        folder := folder + sl.Strings[i] + PathDelim;
      end;
    finally
      sl.Free;
    end;
  end;

  NodeForceDir(folder);
  Rec(folder, cat, em, treeview1.Items.Item[0]);
end;

procedure TMDICategories.DoNew;
var
  folder: string;
  pnode: TTreeNode;
begin
  if TreeView1.SelectionCount = 1 then
  begin
    if IsFolderNode(TreeView1.Selected) or
       IsRootNode(TreeView1.Selected) then
    begin
      pnode := TreeView1.Selected;
    end
    else
    begin
      pnode := TreeView1.Selected.Parent;
    end;
    folder := GetFolderFromNode(pnode);
    newDialog(folder);
  end
  else
  begin
    newDialog(''); // In der Wurzel erstellen
    TreeView1.Items.Item[0];
  end;
end;

procedure TMDICategories.EditorOpenClick(Sender: TObject);
var
  cat, folder: string;
begin
  if TreeView1.SelectionCount = 1 then
  begin
    cat := TreeView1.Selected.Text;
    folder := GetFolderFromNode(TreeView1.Selected);

    if (IsForeignNode(TreeView1.Selected)) then
    begin
      ExternalOpen.Click;
    end
    else if (IsAppenderNode(TreeView1.Selected)) or
            (IsTextNode(TreeView1.Selected)) then
    begin
      if not FileExists(GetFileNameFromNode(TreeView1.Selected)) then
      begin
        ShowMessage(lng_filenotfound);
        Exit;
      end;

      if IsAppenderNode(TreeView1.Selected) then
      begin
        OpenAppenderEditor(folder, cat);
      end
      else
      begin
        OpenTextEditor(folder, cat);
      end;
    end;
  end;
end;

procedure TMDICategories.KategorieClose1Click(Sender: TObject);
begin
  Close;
end;

procedure TMDICategories.KategorieRefresh1Click(Sender: TObject);
begin
  RefreshList;

  TreeView1.SetFocus;
end;

procedure TMDICategories.KategorieUmbenennen1Click(Sender: TObject);
begin
  renameDialog(TreeView1.Selected);
end;

procedure TMDICategories.PNeuClick(Sender: TObject);
begin
  DoNew();
end;

procedure TMDICategories.ExternalOpenClick(Sender: TObject);
var
  fn: string;
begin
  if TreeView1.SelectionCount = 1 then
  begin
    fn := GetFileNameFromNode(TreeView1.Selected);
    commonExternalOpen(fn);
  end;
end;

procedure TMDICategories.PopupMenu1Popup(Sender: TObject);
begin
  if TreeView1.SelectionCount = 1 then
  begin
    PNeu.Visible := isFolderNode(TreeView1.Selected) or IsRootNode(TreeView1.Selected);
    N1.Visible := isFolderNode(TreeView1.Selected) or IsRootNode(TreeView1.Selected);
    PEditor.Visible := true;
    PExternal.Visible := true;
    N2.Visible := true;
    PDelete.Visible := true;
    PUmbenennen.Visible := true;

    PNeu.Default := false;
    PEditor.Default := true;
  end
  else
  begin
    PNeu.Visible := true;
    N1.Visible := false;
    PEditor.Visible := false;
    PExternal.Visible := false;
    N2.Visible := false;
    PDelete.Visible := false;
    PUmbenennen.Visible := false;

    PNeu.Default := true;
    PEditor.Default := false;
  end;
end;

procedure TMDICategories.recursiveItemListing(folder: string;
  parentnode: TTreeNode);
var
  tmp_sr: TSearchRec;
  i_folder: TTreeNode;
begin
  folder := MyAddTrailingPathDelimiter(folder);
  if FindFirst(allFiles(folder), faAnyFile, tmp_sr) = 0 then
  begin
    repeat
      if (tmp_sr.Name <> '.') and (tmp_sr.Name <> '..') then
      begin
        if directoryExists(getFolderName(folder, tmp_sr.Name)) then
        begin
          i_folder := TreeView1.Items.AddChild(parentnode, tmp_sr.Name);
          if CfgExpandNodesAtBeginning then parentnode.Expand(false);
          i_folder.ImageIndex := II_FOLDER;
          i_folder.SelectedIndex := II_FOLDER;
          recursiveItemListing(folder + tmp_sr.Name, i_folder);
        end
        else if (folder + tmp_sr.Name) = GetRelativeFileName(getAppenderFileName(folder, FilenameToCatname(tmp_sr.Name))) then
        begin
          with TreeView1.Items.AddChild(parentnode, FilenameToCatname(tmp_sr.Name)) do
          begin
            ImageIndex := II_APPENDER;
            SelectedIndex := II_APPENDER;
          end;
          if CfgExpandNodesAtBeginning then parentnode.Expand(false);
        end
        else if (folder + tmp_sr.Name) = GetRelativeFileName(getTextFileName(folder, FilenameToCatname(tmp_sr.Name))) then
        begin
          with TreeView1.Items.AddChild(parentnode, FilenameToCatname(tmp_sr.Name)) do
          begin
            ImageIndex := II_TEXT;
            SelectedIndex := II_TEXT;
          end;
          if CfgExpandNodesAtBeginning then parentnode.Expand(false);
        end
        else if getFolderName(folder, tmp_sr.Name) <> getJournalFileName() then
        begin
          with TreeView1.Items.AddChild(parentnode, tmp_sr.Name) do
          begin
            ImageIndex := II_FOREIGN;
            SelectedIndex := II_FOREIGN;
          end;
          if CfgExpandNodesAtBeginning then parentnode.Expand(false);
        end;
      end;
    until FindNext(tmp_sr) <> 0;
    FindClose(tmp_sr);
  end;
end;

procedure TMDICategories.TreeView1KeyPress(Sender: TObject; var Key: Char);
begin
  // Verhindert einen Windows-Sound beim Drücken von Enter
  if key = #13 then key := #0;
  if key = #10 then key := #0;
end;

end.
