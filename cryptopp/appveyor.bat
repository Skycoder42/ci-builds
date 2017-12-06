set CRYPTOPP_NAME=CRYPTOPP_%CRYPTOPP_VERSION%

if "%PLATFORM%" == "mingw" (
	call %~dp0\mingw.bat || exit /B 1
) else (
	:: prepare vcvarsall
	if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2017" (
		set VC_DIR="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat"
	)
	if "%APPVEYOR_BUILD_WORKER_IMAGE%" == "Visual Studio 2015" (
		set VC_DIR="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
	)


	echo %PLATFORM% | findstr /C:"_64" > nul && (
		set VC_VARSALL=amd64
		set VC_ARCH=x64
	) || (
		set VC_VARSALL=amd64_x86
		set VC_ARCH=Win32
	)

	:: build
	call %~dp0\msvc.bat %VC_ARCH% || exit /B 1
)

cd cryptopp
7z a cryptopp_%CRYPTOPP_VERSION%_%PLATFORM%.zip cryptopp || exit \B 1
dir
