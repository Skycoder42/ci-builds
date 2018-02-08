@echo off
setlocal

set scriptdir=%~dp0
set outDir=%scriptdir%\cryptopp
cd %scriptdir%
mkdir cryptopp
mkdir build
cd build

:: get the sources
powershell -Command "Invoke-WebRequest https://github.com/weidai11/cryptopp/archive/%CRYPTOPP_NAME%.zip -OutFile .\%CRYPTOPP_NAME%.zip" || exit /B 1
powershell -Command "(Get-FileHash -Algorithm SHA512 -Path C:\tmp\cryptopp-CRYPTOPP_5_6_5.zip).Hash.equals('%CRYPTOPP_SHA512SUM%')"
7z x .\%CRYPTOPP_NAME%.zip || exit /B 1

cd cryptopp-%CRYPTOPP_NAME%

:: setup env and fixup project files
call %VC_DIR% %VC_VARSALL% || exit /B 1
set PATH=%PATH%;C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\

start /wait devenv.exe /upgrade .\cryptlib.vcxproj
powershell -Command "(gc cryptlib.vcxproj) -replace '<RuntimeLibrary>MultiThreadedDebug<\/RuntimeLibrary>', '<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>' | Out-File -encoding ASCII cryptlib.vcxproj" || exit /B 1
powershell -Command "(gc cryptlib.vcxproj) -replace '<RuntimeLibrary>MultiThreaded<\/RuntimeLibrary>', '<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>' | Out-File -encoding ASCII cryptlib.vcxproj" || exit /B 1

:: build debug and release
mkdir %outDir%\lib
msbuild /t:Build /p:Configuration=Debug;Platform=%VC_ARCH% cryptlib.vcxproj || exit /B 1
cd %VC_ARCH%\Output\Debug
copy cryptlib.lib %outDir%\lib\cryptlibd.lib
:: d only in cryplib, because copy replace....
copy cryptlib.pdb %outDir%\lib\cryptlib.pdb
cd ..\..\..

msbuild /t:Build /p:Configuration=Release;Platform=%VC_ARCH% cryptlib.vcxproj || exit /B 1
cd %VC_ARCH%\Output\Release
copy cryptlib.lib %outDir%\lib\cryptlib.lib
cd ..\..\..

mkdir %outDir%\include\cryptopp
for %%I in (*.h) do copy %%I %outDir%\include\cryptopp\

cd %scriptdir%
