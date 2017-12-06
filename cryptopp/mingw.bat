@echo off
setlocal

set PATH=C:\Qt\Tools\mingw530_32\bin;%PATH%;
set MAKEFLAGS=-j%NUMBER_OF_PROCESSORS%

set scriptdir=%~dp0
set outDir=%scriptdir%/cryptopp
cd %scriptdir%
mkdir cryptopp
mkdir build
cd build

:: get the sources
powershell -Command "Invoke-WebRequest https://github.com/weidai11/cryptopp/archive/%CRYPTOPP_NAME%.zip -OutFile .\%CRYPTOPP_NAME%.zip" || exit /B 1
:: TODO verify checksum
7z x .\%CRYPTOPP_NAME%.zip || exit /B 1

:: build
cd cryptopp-%CRYPTOPP_NAME%
mingw32-make static || exit /B 1
mingw32-make install PREFIX=%outDir:\=/% || exit /B 1

cd %scriptdir%
