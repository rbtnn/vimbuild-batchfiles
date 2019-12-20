@echo off
setlocal enabledelayedexpansion

call "%~dp0\vimbuild_common.bat" %1
if "%BUILD_ARCH%"=="" goto :FINISH

if "%BUILD_ARCH%"=="x64" set VIM_CPU=AMD64
if "%BUILD_ARCH%"=="x86" set VIM_CPU=i386

@echo on
nmake /nologo /f Make_mvc.mak USE_WIN32MAK=no CPU=%VIM_CPU% %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
@echo off

:FINISH

