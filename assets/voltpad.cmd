@echo off

set "PATH=%~dp0;%PATH%"

set "PATH=%~dp0..\volta;%PATH%"

set "VOLTA_HOME=%~dp0..\data\volta"
set "PATH=%VOLTA_HOME%\bin;%PATH%"

"%~dp0codium.cmd" "%*"
