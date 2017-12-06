set CRYPTOPP_VERSION=5_6_5
set CRYPTOPP_NAME=CRYPTOPP_%CRYPTOPP_VERSION%
set CRYPTOPP_SHA512SUM=abca8089e2d587f59c503d2d6412b3128d061784349c735f3ee46be1cb9e3d0d0fed9a9173765fa033eb2dc744e03810de45b8cc2f8ca1672a36e4123648ea44

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
