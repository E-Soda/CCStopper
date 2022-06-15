@echo off
title CCStopper - Block Adobe Processes
mode con: cols=100 lines=42

:: Asks for Administrator Permissions
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd","/c %~s0 ::","","runas",1)(window.close) && exit
cd /d "%~dp0"

:: Thanks to Verix#2020, from GenP Discord.
for /f "usebackq tokens=3*" %%A IN (`reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\PHSP_23_3" /v InstallLocation`) do set psAppLocation=%%A %%B

set file1="C:\Program Files (x86)\Adobe\Adobe Sync\CoreSync\CoreSync.exe"
set file2="C:\Program Files\Adobe\Adobe Creative Cloud Experience\CCXProcess.exe"
set file3="C:\Program Files (x86)\Common Files\Adobe\Adobe Desktop Common\ADS\Adobe Desktop Service.exe"
set file4="C:\Program Files\Common Files\Adobe\Creative Cloud Libraries\CCLibrary.exe"
set file5="%psAppLocation%\LogTransport2.exe"
set file6="C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\AdobeCollabSync.exe"
set files=%file1% %file2% %file3% %file4% %file5% %file6%

set targetExists=false
set blockedExists=false

:: Check if files are already blocked
:blockedCheck
setlocal EnableDelayedExpansion
for %%a in (%files%) do (
	set "_=%%a" & set blocked=!_:.exe=.exe.blocked!
	if exist !blocked! (
		set blockedExists=true
	)
)
setlocal DisableDelayedExpansion

if %blockedExists% == true (
	cls
	echo:
	echo:
	echo                   _______________________________________________________________
	echo                  ^|                                                               ^| 
	echo                  ^|                                                               ^|
	echo                  ^|                            CCSTOPPER                          ^|
	echo                  ^|                        BlockProcesses Module                  ^|
	echo                  ^|      ___________________________________________________      ^|
	echo                  ^|                                                               ^|
	echo                  ^|                ADOBE FILES ARE ALREADY BLOCKED!               ^|
	echo                  ^|                                                               ^|
	echo                  ^|             Would you like to restore those files?            ^|
	echo                  ^|      ___________________________________________________      ^|
	echo                  ^|                                                               ^|
	echo                  ^|      [1] Restore Adobe files                                  ^|
	echo                  ^|      ___________________________________________________      ^|
	echo                  ^|                                                               ^|
	echo                  ^|      [Q] Exit Module                                          ^|
	echo                  ^|                                                               ^|
	echo                  ^|                                                               ^|
	echo                  ^|_______________________________________________________________^|
	echo:          
	choice /C:1Q /N /M ">                                            Select [1,Q]: "
	if errorlevel 2 (
		goto exit
	)
	if errorlevel 1 (
		goto mainScript
	)
) else (
	goto targetCheck
)

:: Check if target path exists
:targetCheck
for %%a in (%files%) do (
	if exist %%a (
		set targetExists=true	
	)
)

if %targetExists% == true (
	goto mainScript
) else (
	cls
	echo The target file cannot be found. Cannot proceed with blocking adobe files.
	pause
	goto exit
)

:exit
start cmd /k %~dp0\..\CCStopper.bat
exit

:mainScript
Powershell -ExecutionPolicy RemoteSigned -File .\StopProcesses.ps1
setlocal EnableDelayedExpansion
for %%a in (%files%) do (
	set "_=%%a" & set blocked=!_:.exe=.exe.blocked!

	for %%f in (%%a) do set name="%%~nxf"
	for %%f in (!blocked!) do set blockedName="%%~nxf"
	
	if %targetExists% == true (
		rename %%a !blockedName! >nul 2>&1
	) else if %blockedExists% == true (
		rename !blocked! !name! >nul 2>&1
	)
)
setlocal DisableDelayedExpansion
goto done

:done
cls
:: Thanks https://github.com/massgravel/Microsoft-Activation-Scripts for the UI
echo:
echo:
echo                   _______________________________________________________________
echo                  ^|                                                               ^| 
echo                  ^|                                                               ^|
echo                  ^|                            CCSTOPPER                          ^|
echo                  ^|                        BlockProcesses Module                  ^|
echo                  ^|      ___________________________________________________      ^|
echo                  ^|                                                               ^|
echo                  ^|              Blocking adobe process files complete!           ^|
echo                  ^|      ___________________________________________________      ^|
echo                  ^|                                                               ^|
echo                  ^|      [Q] Exit Module                                          ^|
echo                  ^|                                                               ^| 
echo                  ^|                                                               ^| 
echo                  ^|_______________________________________________________________^|
echo:          
choice /C:Q /N /M ">                                            Select [Q]: "

if errorlevel 1 (
	goto exit
)