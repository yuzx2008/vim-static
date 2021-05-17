@echo off
:: Batch file for building/testing Vim on AppVeyor

setlocal ENABLEDELAYEDEXPANSION
rem FOR /f "delims=. tokens=1-3" %%i in ("%APPVEYOR_REPO_TAG_NAME%") do set PATCHLEVEL=%%k

rem cd %APPVEYOR_BUILD_FOLDER%

if /I "%ARCH%"=="x64" (
	set BIT=64
) else (
	set BIT=32
)

:: ----------------------------------------------------------------------
:: Download URLs, local dirs and versions
:: vim
:: TODO
set VIM_URL=https://github.com/vim/vim/archive/%VIM_VERSION%.zip
:: winpty
set WINPTY_URL=https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msvc2015.zip

:: Subsystem version (targeting Windows XP)
set SUBSYSTEM_VER32=5.01
set SUBSYSTEM_VER64=5.02
set SUBSYSTEM_VER=!SUBSYSTEM_VER%BIT%!
:: ----------------------------------------------------------------------

if /I "%1"=="" (
	set target=build
) else (
	set target=%1
)

goto %target%_%ARCH%
echo Unknown build target.
exit 1


:install_x86
:install_x64
:: ----------------------------------------------------------------------
@echo on

:: Get Vim source code
call :downloadfile %VIM_URL% vim.zip
7z x -y vim.zip
move vim-* vim

if not exist downloads mkdir downloads

:: Install winpty
call :downloadfile %WINPTY_URL% downloads\winpty.zip
7z x -y downloads\winpty.zip -oc:\winpty > nul || exit 1
if /i "%ARCH%"=="x64" (
	copy /Y c:\winpty\x64_xp\bin\winpty.dll        vim\src\winpty64.dll
	copy /Y c:\winpty\x64_xp\bin\winpty-agent.exe  vim\src\
) else (
	copy /Y c:\winpty\ia32_xp\bin\winpty.dll       vim\src\winpty32.dll
	copy /Y c:\winpty\ia32_xp\bin\winpty-agent.exe vim\src\
)

:: Show PATH for debugging
path

@echo off
goto :eof


:build_x86
:build_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src

:: Setting for targeting Windows XP
set WinSdk71=%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A
set INCLUDE=%WinSdk71%\Include;%INCLUDE%
if /i "%ARCH%"=="x64" (
	set "LIB=%WinSdk71%\Lib\x64;%LIB%"
) else (
	set "LIB=%WinSdk71%\Lib;%LIB%"
)
set CL=/D_USING_V110_SDK71_

:: Replace VIM_VERSION_PATCHLEVEL in version.h with the actual patchlevel
:: Set CHERE_INVOKING to start Cygwin in the current directory
rem set CHERE_INVOKING=1
rem c:\cygwin64\bin\bash -lc "sed -i -e /VIM_VERSION_PATCHLEVEL/s/0/$(sed -n -e '/included_patches/{n;n;n;s/ *\([0-9]*\).*/\1/p;q}' version.c)/ version.h"

:: Remove progress bar from the build log
rem sed -e "s/@<<$/@<< | sed -e 's#.*\\\\r.*##'/" Make_mvc.mak > Make_mvc2.mak
:: Build GUI version
nmake -f Make_mvc2.mak ^
	GUI=yes OLE=no DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=no DEBUG=no ^
	TERMINAL=yes ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc2.mak ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=no DEBUG=no ^
	TERMINAL=yes ^
	|| exit 1

:check_executable
:: ----------------------------------------------------------------------
start /wait .\gvim -u NONE -c "redir @a | ver | 0put a | wq!" ver.txt
type ver.txt
.\vim --version
:: Print interface versions
start /wait .\gvim -u NONE -S ..\..\if_ver.vim -c quit
type if_ver.txt
@echo off
goto :eof


:package_x86
:package_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src

mkdir GvimExt64
mkdir GvimExt32
:: Build both 64- and 32-bit versions of gvimext.dll for the installer
start /wait cmd /c ""C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64 && cd GvimExt && nmake CPU=AMD64 clean all > ..\gvimext.log"
type gvimext.log
copy GvimExt\gvimext.dll   GvimExt\gvimext64.dll
move GvimExt\gvimext.dll   GvimExt64\gvimext.dll
copy /Y GvimExt\README.txt GvimExt64\
copy /Y GvimExt\*.inf      GvimExt64\
copy /Y GvimExt\*.reg      GvimExt64\
start /wait cmd /c ""C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x86 && cd GvimExt && nmake CPU=i386 clean all > ..\gvimext.log"
type gvimext.log
copy GvimExt\gvimext.dll   GvimExt32\gvimext.dll
copy /Y GvimExt\README.txt GvimExt32\
copy /Y GvimExt\*.inf      GvimExt32\
copy /Y GvimExt\*.reg      GvimExt32\

:: Create zip packages
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y xxd\*.exe ..\runtime
copy /Y tee\*.exe ..\runtime
mkdir ..\runtime\GvimExt64
mkdir ..\runtime\GvimExt32
copy /Y GvimExt64\*.*                    ..\runtime\GvimExt64\
copy /Y GvimExt32\*.*                    ..\runtime\GvimExt32\
copy /Y ..\..\diff.exe ..\runtime\
copy /Y winpty* ..\runtime\
copy /Y winpty* ..\..\
set dir=vim%APPVEYOR_REPO_TAG_NAME:~1,1%%APPVEYOR_REPO_TAG_NAME:~3,1%
mkdir ..\vim\%dir%
xcopy ..\runtime ..\vim\%dir% /Y /E /V /I /H /R /Q

@echo off
goto :eof


:test_x86
:test_x64
:: ----------------------------------------------------------------------
@echo on
cd vim\src\testdir
nmake -f Make_dos.mak VIMPROG=..\gvim || exit 1
nmake -f Make_dos.mak clean
nmake -f Make_dos.mak VIMPROG=..\vim || exit 1

@echo off
goto :eof


:downloadfile
:: ----------------------------------------------------------------------
:: call :downloadfile <URL> <localfile>
if not exist %2 (
	curl -f -L %1 -o %2
)
if ERRORLEVEL 1 (
	rem Retry once.
	curl -f -L %1 -o %2 || exit 1
)
@goto :eof
