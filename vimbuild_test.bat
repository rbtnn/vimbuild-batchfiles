@echo off
setlocal enabledelayedexpansion

call "%~dp0\vimbuild_common.bat" %1
if "%BUILD_ARCH%"=="" goto :FINISH

set PATH=%PATH%;C:\Program Files\Git\usr\bin

pushd testdir
    if exist test.log del /Q test.log
    @echo on
    nmake /nologo /f Make_dos.mak VIMPROG=..\vim %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
    @echo off
    if exist test.log type test.log
popd

:FINISH

