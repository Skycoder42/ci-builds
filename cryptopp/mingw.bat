@echo on
setlocal

dir C:\
dir C:\mingw-w64
dir C:\mingw-w64\x86_64-7.3.0-posix-seh-rt_v5-rev0
dir C:\mingw-w64\x86_64-7.3.0-posix-seh-rt_v5-rev0\bin

set scriptdir=%~dp0
set outDir=%scriptdir%\cryptopp
cd %scriptdir%
mkdir cryptopp
mkdir build
cd build

:: get the sources
powershell -Command "Invoke-WebRequest https://github.com/weidai11/cryptopp/archive/%CRYPTOPP_NAME%.zip -OutFile .\%CRYPTOPP_NAME%.zip" || exit /B 1
powershell -Command "(Get-FileHash -Algorithm SHA512 -Path .\%CRYPTOPP_NAME%.zip).Hash.equals('%CRYPTOPP_SHA512SUM%')"
7z x .\%CRYPTOPP_NAME%.zip || exit /B 1

cd cryptopp-%CRYPTOPP_NAME%

:: setup env and fixup project files
set PATH=C:\mingw-w64\x86_64-7.3.0-posix-seh-rt_v5-rev0\bin;%PATH%
where mingw32-make
mingw32-make static
mingw32-make install PREFIX=$outDir
