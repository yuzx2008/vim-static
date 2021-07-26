@echo off
:: Batch file for building/testing Vim on AppVeyor

setlocal ENABLEDELAYEDEXPANSION

:: ----------------------------------------------------------------------
:: Download URLs, local dirs and versions
:: vim
:: TODO
set VIM_URL=https://github.com/vim/vim/archive/%VIM_VERSION%.zip
:: winpty
set WINPTY_URL=https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msys2-2.7.0-ia32.tar.gz
:: Lua
set LUA_VER=54
set LUA_URL=https://downloads.sourceforge.net/luabinaries/lua-5.4.2_Win32_dllw6_lib.zip
set LUA_DIR=C:\Lua

:: Subsystem version (targeting Windows XP)
set SUBSYSTEM_VER=5.01
:: ----------------------------------------------------------------------

if /I "%1"=="" (
	set target=build
) else (
	set target=%1
)

goto %target%
echo Unknown build target.
exit 1


:install
:: ----------------------------------------------------------------------
@echo on

:: Get Vim source code
call :downloadfile %VIM_URL% vim.zip
7z x -y vim.zip
move vim-* vim-src

if not exist downloads mkdir downloads

:: Install winpty
call :downloadfile %WINPTY_URL% downloads\winpty.tar.gz
md c:\winpty
tar --strip-components=1 -xf downloads\winpty.tar.gz -C c:\winpty || exit 1
:: ignore x64
copy /Y c:\winpty\bin\winpty.dll vim-src\src\winpty32.dll
copy /Y c:\winpty\bin\winpty-agent.exe vim-src\src\

:: Lua
call :downloadfile %LUA_URL% downloads\lua.zip
7z x downloads\lua.zip -o%LUA_DIR% > nul || exit 1

:: update path
path %path%;%LUA_DIR%

:: Show PATH for debugging
path

@echo off
goto :eof


:build
:: ----------------------------------------------------------------------
@echo on
cd vim-src\src

:: Setting for targeting Windows XP
set WinSdk71=%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A
set INCLUDE=%WinSdk71%\Include;%INCLUDE%
set "LIB=%WinSdk71%\Lib;%LIB%"
set CL=/D_USING_V110_SDK71_

:: Build GUI version
call "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat"
nmake -f Make_mvc.mak ^
	GUI=yes OLE=no DIRECTX=yes ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=no DEBUG=no ^
	TERMINAL=yes ^
        DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
	|| exit 1
:: Build CUI version
nmake -f Make_mvc.mak ^
	GUI=no OLE=no DIRECTX=no ^
	FEATURES=HUGE IME=yes MBYTE=yes ICONV=no DEBUG=no ^
	TERMINAL=yes ^
        DYNAMIC_LUA=yes LUA=%LUA_DIR% ^
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


:package
:: ----------------------------------------------------------------------
@echo on
call "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat"
cd vim-src\src

:: Create zip packages
copy /Y ..\README.txt ..\runtime
copy /Y ..\vimtutor.bat ..\runtime
copy /Y *.exe ..\runtime\
copy /Y xxd\*.exe ..\runtime
copy /Y tee\*.exe ..\runtime
copy /Y ..\..\diff.exe ..\runtime\
copy /Y winpty* ..\runtime\
copy /Y winpty* ..\..\
rem vim v8.2.0001 -> v82
set dir=vim%VIM_VERSION:~1,1%%VIM_VERSION:~3,1%
mkdir ..\..\vim\%dir%
xcopy ..\runtime ..\..\vim\%dir% /Y /E /V /I /H /R /Q

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
