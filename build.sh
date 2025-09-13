#!/bin/bash

echo "Building Finance Tracker App..."
echo ""

echo "Step 1: Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "Error: Failed to get dependencies"
    exit 1
fi
echo "Dependencies downloaded successfully!"
echo ""

echo "Step 2: Running Flutter Doctor to check setup..."
flutter doctor
echo ""

echo "Step 3: Cleaning previous build..."
flutter clean
echo ""

echo "Step 4: Building APK for Android..."
flutter build apk --release
if [ $? -ne 0 ]; then
    echo "Error: Failed to build APK"
    exit 1
fi
echo ""

echo "✅ Build completed successfully!"
echo ""
echo "📱 APK Location: build/app/outputs/flutter-apk/app-release.apk"
echo "📋 Install on device: flutter install"
echo "🚀 Run in development: flutter run"
echo ""