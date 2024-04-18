; StackMan Setup Script for InnoSetup
; by Daniel Marschall

; http://www.daniel-marschall.de/

; ToDo:
; - For all users or only for me
; - Entry in quick launch

[Setup]
AppName=StackManager
AppVerName=StackManager 5.1
AppVersion=5.1
AppCopyright=© Copyright 2009 - 2010 ViaThinkSoft
AppPublisher=ViaThinkSoft
AppPublisherURL=http://www.viathinksoft.de/
AppSupportURL=http://www.daniel-marschall.de/
AppUpdatesURL=http://www.viathinksoft.de/
DefaultDirName={autopf}\Stack Manager
DefaultGroupName=Stack Manager
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2009 - 2010 ViaThinkSoft
VersionInfoDescription=Stack Manager Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=5.1
OutputDir=.
OutputBaseFilename=StackMan_Setup
; Configure Sign Tool in InnoSetup at "Tools => Configure Sign Tools" (adjust the path to your SVN repository location)
; Name    = sign_single   
; Command = "C:\SVN\...\sign_single.bat" $f
SignTool=sign_single
SignedUninstaller=yes

[Languages]
Name: de; MessagesFile: "compiler:Languages\German.isl"

[LangOptions]
LanguageName=Deutsch
LanguageID=$0407

[Tasks]
Name: "desktopicon"; Description: "Erstelle eine Verknüpfung auf dem &Desktop"; GroupDescription: "Programmverknüpfungen:"; MinVersion: 4,4

[Files]
Source: "StackMan.exe"; DestDir: "{app}"; Flags: ignoreversion signonce

[Icons]
Name: "{group}\Webseiten\ViaThinkSoft"; Filename: "http://www.viathinksoft.de/"
Name: "{group}\Stack Manager"; Filename: "{app}\StackMan.exe"
Name: "{group}\Stack Manager deinstallieren"; Filename: "{uninstallexe}"
Name: "{userdesktop}\Stack Manager"; Filename: "{app}\StackMan.exe"; MinVersion: 4,4; Tasks: desktopicon

[Run]
Filename: "{app}\StackMan.exe"; Description: "Stack Manager starten"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  if CheckForMutexes('StackManSetup')=false then
  begin
    Createmutex('StackManSetup');
    Result := true;
  end
  else
  begin
    Result := False;
  end;
end;

