@echo off
color 0a
echo __________________________________________________________________________
echo ################## ddd ####################################################\
echo                    ddd                                      rapiddeploy  ##\
echo                    ddd                                                   ##\
echo    r rrrrr       d ddd                                                   ##\
echo   rrrr  rrr    ddd ddd                              prccdc toolkit 2016  ##\
echo   rrr   rrr   ddd  ddd                                  bofh@pencol.edu  ##\
echo   rrr         dddd ddd                                                   ##\
echo   rrr          ddddddd                                                   ##\
echo   rrr
timeout 8
set NEEDS_REBOOT=0
set RD_Agent=wget.exe
set RD_AgentString="RapidDeploy tool for fetching crtitical MS patches at PRCCDC 2016 bofh@pencol.edu"
cls
color 07
echo This tool will fetch patches from Github by default. If you want to change this behavior invoke repiddeploy
echo with the "-s" flag
echo Examples:
echo "rapiddeploy.cmd -s microsoft         -- download from windows update "
echo "rapiddeploy.cmd -s <URL>             -- download from local mirror at <URL> "
echo ..... Initiating Sytem Fingerprint
systeminfo | find /I "OS Name" > tmp.os
systeminfo | find /I "System Type" > tmp.arch
FOR /F "eol=; tokens=4,5 delims= " %%i in (tmp.os) do set OSNAME=%%i %%j
FOR /F "eol=; tokens=3 delims= " %%i in (tmp.arch) do set OSARCH=%%i
del tmp.os tmp.arch rapid_win.txt rapid_lose.txt
echo ..... Complete
cls
echo -----------  I will now be using logic for:
ver
echo OS:               %OSNAME%
echo Architecture:     %OSARCH%
echo .
echo -----------  I will continue with rapid deployment
echo -----------  Press CNTRL + C to halt me

set Patch_Description_MS09-050="Remote Code Execution in"
set Patch_Description_MS10-061="Remote Code Execution in"
set Patch_Description_MS12-020="MS12-020: Denial of Service Condition in Remote Desktop Protocol"
set Patch_Description_MS15-068="MS15-068: Remote Code Execution in Remote Desktop Protocol"
timeout 6

goto %OSNAME%

:quit
exit

:Windows 10
cls
echo Assembling Patch list for %OSNAME%
set Win10_MS15-068_x64URL=http://www.microsoft.com/blah
goto Win10_%OSARCH%

:Win10_x64-based
set patchdir=Win10_x64
if not exist %patchdir% (mkdir %patchdir%)
echo %Patch_Description_MS15-068%
if exist %patchdir%\MS15-068.msu (call :cleanup MS15-068.msu)
if not exist %patchdir%\MS15-068.msu (call :fetch_patch_newstyle MS15-068 %Win10_MS15-068_x64URL%)
if exist %patchdir%\MS15-068.msu (call :install_patch_newstyle MS15-068)
goto skel

:Win10_x32-based
echo No such agency
goto EOF

:Windows 8
cls
echo Assembling Patch list for %OSNAME%
set Win8_MS09-050_x32URL=
set Win8_MS09-050_x64URL=
set Win8_MS12-020_x32URL=
set Win8_MS12-020_x64URL=
set Win8_MS15-068_x32URL=
set Win8_MS15-068_x64URL=
goto Win8_%OSARCH%

:Win8_x64-based

:Win8_x32-based

:Windows 7
cls
echo Assembling Patch list for %OSNAME%
set Win7_MS09-050_x32URL=
set Win7_MS09-050_x64URL=
set Win7_MS12-020_x32URL=
set Win7_MS12-020_x64URL=
set Win7_MS15-068_x32URL=
set Win7_MS15-068_x64URL=
goto Win7_%OSARCH%

:Win7_x64-based
set patchdir=Win7_x64
set patchlist1=MS12-020 MS15-068 MS09-050
goto skel

:Win7_x32-based
goto EOF

:Windows Vista
cls
echo Assembling Patch list for %OSNAME%
set WinVista_MS09-050_x32URL=
set WinVista_MS09-050_x64URL=
set WinVista_MS12-020_x32URL=
set WinVista_MS12-020_x64URL=
set WinVista_MS15-068_x32URL=
set WinVista_MS15-068_x64URL=
goto WinVista_%OSARCH%

:WinVista_x64-based

:WinVista_x32-based

:Windows XP
echo Assembling Patch list for %OSNAME%
goto WinXP_%OSARCH%

:WinXP_x64-based
echo Windows XP 64 bit. No. Just no. I'm not writing anything for this. You're on your own.
goto EOF

:WinXP_x32-based

:skel
rem if not exist %patchdir% (mkdir %patchdir%)
rem for %%m in (%patchlist1%) do call :%%m
color 07
timeout 5
if exist rapid_win.txt start /low /min notepad.exe rapid_win.txt
if exist rapid_lose.txt start /low /min notepad.exe rapid_lose.txt
echo Please review the autopatching logs to find any mistakes that I have surely made
if %NEEDS_REBOOT% GEQ 1 (goto :schedule_reboot)
goto EOF

:cleanup
	echo Patch %1 is already in the download cache
	dir %patchdir%\%1
	echo Do you want me to remove it?
	set /P CONFIRM=[y/N]  
	if /I %CONFIRM%==y del %patchdir%\%1
	if /I %CONFIRM%==n echo keeping the file
	goto EOF

:fetch_patch_oldstyle
	color 0c
	echo Invoking: %RD_Agent% -v -c -U %RD_AgentString% %2 -O %patchdir%\%1.exe -t 5 -T 15 -a debug.txt >> rapid_win.txt
	%RD_Agent% -v -c -U %RD_AgentString% %2 -O %patchdir%\%1.exe -t 5 -T 15 -a debug.txt
	goto EOF

:fetch_patch_newstyle
	color 0c
	echo Invoking: %RD_Agent% -v -c -U %RD_AgentString% %2 -O %patchdir%\%1.msu -t 5 -T 15 -a debug.txt >> rapid_win.txt
	%RD_Agent% -v -c -U %RD_AgentString% %2 -O %patchdir%\%1.msu -t 5 -T 15 -a debug.txt
	goto EOF

:install_patch_oldstyle
	color 0f
	echo Invoking: C:\Windows\System32\msiexec.exe /passive /norestart /i %patchdir%\%1.exe >> rapid_win.txt
	C:\Windows\System32\msiexec.exe /passive /i %patchdir%\%1.exe
	rem if %ERRORLEVEL%==0 set LAST_SUCCESS=1
	call :success_patch %1.exe
	goto EOF

:install_patch_newstyle
	color 0f
	echo Invoking: C:\Windows\System32\msiexec.exe /passive /norestart /i %patchdir%\%1.msu >> rapid_win.txt
	C:\Windows\System32\msiexec.exe /passive /i %patchdir%\%1.msu
	rem if %ERRORLEVEL%==0 set LAST_SUCCESS=1
	call :success_patch %1
	goto EOF

:success_patch
	color 0a
	echo Sucessfully patched %1 on %OSNAME% %OSARCH%
	echo [!] Sucessfully patched %1 on %OSNAME% %OSARCH% >> rapid_win.txt
	set NEEDS_REBOOT=1
	goto EOF

:fail_patch
	color 0c
	echo Patch %1 on %OSNAME% %OSARCH% is not confirmed
	echo [X] Patch %1 on %OSNAME% %OSARCH% is not confirmed >> rapid_lose.txt
	goto EOF

:MS08-067

echo %Patch_Description%

IF NOT EXIST %patchdir%\MS15-068.exe call :fetch_patch MS15-068 %MS15-068_URL%
	rem else call :cleanup MS15-068
call :install_patch MS15-068 
	call :success_patch MS15-068 %MS15-068_URL% %OSNAME% %OSARCH%
	rem else call :fail_patch MS15-068 %MS15-068_URL%
	set LAST_SUCCESS=0

:schedule_reboot
	echo "To finish patching, I need to reboot the machine now"
	echo .
	echo "If this is not a good time to reboot, cancel the reboot with --> /shutdown /a"
     	shutdown /r /t 90 /c "Rapiddeploy has finished patching - Rebooting in 90 seconds" /d p:2:18
:EOF