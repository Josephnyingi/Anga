@echo off
echo ========================================
echo Building Anga Flutter APK
echo ========================================

echo.
echo Choose APK type:
echo 1. Debug APK (for testing)
echo 2. Release APK (for distribution)
echo 3. Both
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto debug
if "%choice%"=="2" goto release
if "%choice%"=="3" goto both
goto invalid

:debug
echo.
echo Building Debug APK...
flutter build apk --debug
echo.
echo Debug APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-debug.apk
goto end

:release
echo.
echo Building Release APK...
flutter build apk --release
echo.
echo Release APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
goto end

:both
echo.
echo Building both Debug and Release APKs...
flutter build apk --debug
flutter build apk --release
echo.
echo Both APKs built successfully!
echo Debug APK: build\app\outputs\flutter-apk\app-debug.apk
echo Release APK: build\app\outputs\flutter-apk\app-release.apk
goto end

:invalid
echo Invalid choice. Please run the script again.
goto end

:end
echo.
echo ========================================
echo Build complete!
echo ========================================
pause
