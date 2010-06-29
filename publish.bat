@echo off

REM (Keine Delphi Compilierung)

SET NAME=ViaThinkSoft Stack Manager 5.1
SET URL=http://www.viathinksoft.de/
SET EXE=StackMan.exe

echo Unterzeichne %EXE%...

signtool sign -d "%NAME%" -du "%URL%" -a -t "http://timestamp.verisign.com/scripts/timstamp.dll" -r "ViaThinkSoft Root Certificate Signing Authority" -i "ViaThinkSoft Intermediate Code Signing Certificate Authority" "%EXE%"

echo Compiliere Setup...

"C:\Programme\Inno Setup 5\iscc.exe" /Q "StackMan.iss"

echo Unterzeichne Setup...

SET EXE=Output\setup.exe

signtool sign -d "%NAME%" -du "%URL%" -a -t "http://timestamp.verisign.com/scripts/timstamp.dll" -r "ViaThinkSoft Root Certificate Signing Authority" -i "ViaThinkSoft Intermediate Code Signing Certificate Authority" "%EXE%"

echo Fertig!

pause.
cls
exit
