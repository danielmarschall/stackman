unit name;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons;

type
  TNameDlg = class(TForm)
    Label1: TLabel;
    NameEdt: TEdit;
    OKBtn: TButton;
    CancelBtn: TButton;
    Textmode: TCheckBox;
    procedure CancelBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NameEdtChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

var
  NameDlg: TNameDlg;

implementation

{$R *.dfm}

procedure TNameDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrAbort;
end;

procedure TNameDlg.FormShow(Sender: TObject);
begin
  OkBtn.Enabled := false;
  NameEdt.SetFocus;
end;

procedure TNameDlg.NameEdtChange(Sender: TObject);
begin
  OKBtn.Enabled := NameEdt.Text <> '';
end;

procedure TNameDlg.OKBtnClick(Sender: TObject);
begin
  if NameEdt.Text <> '' then
  begin
    ModalResult := mrOk;
  end;
end;

procedure TNameDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
  begin
    close;
  end;
end;

end.
 
