@echo off
echo Testing iOS build setup...
echo.
echo This will fail on Windows (expected), but helps verify configuration
echo.

cd mobile

echo Checking Flutter setup...
flutter doctor

echo.
echo Attempting iOS build (will fail on Windows)...
flutter build ios --no-codesign

echo.
echo If you see "Building for iOS is only supported on macOS" - that's correct!
echo Your setup is ready for GitHub Actions or Codemagic.
echo.
pause




