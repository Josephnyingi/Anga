@echo off
echo Building ANGA Web App with simplified main...

REM Backup original main.dart
copy lib\main.dart lib\main_original.dart

REM Use simplified main
copy lib\main_simple.dart lib\main.dart

REM Build the app
flutter build web --release

REM Restore original main.dart
copy lib\main_original.dart lib\main.dart

echo Build complete!
