@echo off
setlocal enabledelayedexpansion
setlocal enableextensions

if not defined TAR (
   where tar >nul 2>&1 || goto :ERROR-NOTAR
   set TAR=tar
)

"%TAR%" --help | find "(bsdtar)" >nul || goto :ERROR-WRONGTAR

set MODULE_NAME=jsonparser
set GAME_NAME=%MODULE_NAME%_demo
set GAME_LINUX_NAME=%GAME_NAME%_linux
set GAME_WINDOWS_NAME=%GAME_NAME%_windows
set THISDIR=%~dp0
set THISDIR=%THISDIR:~0,-1%
set AGSTAR=%THISDIR%\ags-tar.cmd
set AGSGAMEPROJECT=%THISDIR%\..\%GAME_NAME%
set BUILDDIR=%THISDIR%\BUILD
set BUILDDIRWINDOWS=%THISDIR%\BUILD\%GAME_WINDOWS_NAME%
set BUILDDIRLINUX=%THISDIR%\BUILD\%GAME_LINUX_NAME%
set DISTDIR=%THISDIR%\DIST

if [%~1]==[] goto :NOPARAM
set AGSGAMEPROJECT="%~1"

:NOPARAM

md "%BUILDDIRWINDOWS%"
md "%BUILDDIRLINUX%"
md "%DISTDIR%"
del "%BUILDDIRWINDOWS%\*" /f /q /s
del "%BUILDDIRLINUX%\*" /f /q /s
del "%DISTDIR%\*" /f /q /s
set COMPILEDDIRWINDOWS="%AGSGAMEPROJECT%\Compiled\Windows"
set COMPILEDDIRLINUX="%AGSGAMEPROJECT%\Compiled\Linux"

xcopy /e /k /h /i "%COMPILEDDIRWINDOWS%\*" "%BUILDDIRWINDOWS%"
xcopy /e /k /h /i "%COMPILEDDIRLINUX%\*" "%BUILDDIRLINUX%"


rem Remove warnings.log and friends
del "%BUILDDIRWINDOWS%\*.log" /f /q /s

"%TAR%" -a -cf "%DISTDIR%\%GAME_WINDOWS_NAME%.zip" "%BUILDDIRWINDOWS%"
pushd "%DISTDIR%"
call "%AGSTAR%" "%BUILDDIRLINUX%\%GAME_NAME%"
del /q %GAME_NAME%.mtree
ren %GAME_NAME%.tar.gz %GAME_LINUX_NAME%.tar.gz
popd

rem Module export part
set MB_MODULEDIR=%THISDIR%\MODULE
set MB_EXPORTER=%THISDIR%\AGSModuleExporter.exe
set MB_ASC=%MODULE_NAME%.asc
set MB_ASH=%MODULE_NAME%.ash
set MB_XML=%MODULE_NAME%.xml
set MB_SCM=%MODULE_NAME%.scm

md "%MB_MODULEDIR%"
del "%MB_MODULEDIR%\*" /f /q /s

xcopy "%AGSGAMEPROJECT%\%MB_ASC%" "%MB_MODULEDIR%"
xcopy "%AGSGAMEPROJECT%\%MB_ASH%" "%MB_MODULEDIR%"
xcopy "%AGSGAMEPROJECT%\..\%MB_XML%" "%MB_MODULEDIR%"
"%MB_EXPORTER%" -script "%MB_MODULEDIR%\%MB_ASC%" -module "%DISTDIR%\%MB_SCM%"

goto :END

:ERROR-NOTAR
1>&2 echo No version of tar is available
exit /b 1

:ERROR-WRONGTAR
1>&2 echo The version of tar which was found wasn't bsdtar
exit /b 1

:END
endlocal
