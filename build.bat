@echo off
echo Building Finance Tracker App...
echo.

echo Step 1: Getting Flutter dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo Error: Failed to get dependencies
    pause
    exit /b 1
)
echo Dependencies downloaded successfully!
echo.

echo Step 2: Running Flutter Doctor to check setup...
call flutter doctor
echo.

echo Step 3: Cleaning previous build...
call flutter clean
echo.

echo Step 4: Building APK for Android...
call flutter build apk --release
if %errorlevel% neq 0 (
    echo Error: Failed to build APK
    pause
    exit /b 1
)
echo.

echo ✅ Build completed successfully!
echo.
echo 📱 APK Location: build\app\outputs\flutter-apk\app-release.apk
echo 📋 Install on device: flutter install
echo 🚀 Run in development: flutter run
echo.

pause