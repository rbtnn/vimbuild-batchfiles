@echo off
setlocal enabledelayedexpansion

if "%1"=="x86" set BUILD_ARCH=x86
if "%1"=="x64" set BUILD_ARCH=x64
if "%BUILD_ARCH%"=="x64" set VIM_CPU=AMD64
if "%BUILD_ARCH%"=="x86" set VIM_CPU=i386
if "%BUILD_ARCH%"==""    goto :FINISH

set INCLUDE=
set LIBPATH=
set LIB=
set PATH=C:\WINDOWS\system32
set VCVARS=
set VIMOPT= SDK_INCLUDE_DIR="%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Include" %2 %3 %4 %5 %6 %7 %8 %9
set CACHE=%~dp0\%BUILD_ARCH%.bat

if exist "%CACHE%" (
    call "%CACHE%"
    goto :BUILD
)

if "%VCVARS%"=="" (
    for /F "usebackq delims==" %%i in (`where /r "%ProgramFiles(x86)%" vcvarsall.bat`) do ( if "%VCVARS%"=="" (set VCVARS=%%i) )
)
if "%VCVARS%"=="" (
    for /F "usebackq delims==" %%i in (`where /r "%ProgramFiles%"      vcvarsall.bat`) do ( if "%VCVARS%"=="" (set VCVARS=%%i) )
)
call "%VCVARS%" %BUILD_ARCH%

echo set INCLUDE=%INCLUDE%  > %CACHE%
echo set LIBPATH=%LIBPATH% >> %CACHE%
echo set LIB=%LIB%         >> %CACHE%
echo set PATH=%PATH%       >> %CACHE%

:BUILD

nmake /nologo /f Make_mvc.mak %VIMOPT% CPU=%VIM_CPU%

:FINISH

