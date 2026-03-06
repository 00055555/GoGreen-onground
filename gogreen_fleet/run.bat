@echo off
echo =============================================
echo   GoGreen Fleet - Flutter App Launcher
echo =============================================
echo.
set "FLUTTER=D:\flutter\bin\flutter.bat"
set "ADB=C:\Users\Heth\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo [1] Checking for connected/running devices...
%ADB% devices
echo.

echo [2] Running app on Chrome (Web Browser)...
%FLUTTER% run -d chrome
