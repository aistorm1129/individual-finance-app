# Finance Tracker - Setup Guide

## 🚀 Quick Start Guide

### Prerequisites

Before building the Finance Tracker app, ensure you have:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Android Studio** or **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code with Flutter extension

3. **Android SDK** (for Android builds)
   - Installed via Android Studio
   - Accept Android licenses: `flutter doctor --android-licenses`

4. **Xcode** (for iOS builds - Mac only)
   - Download from Mac App Store

### 🔧 Setup Instructions

#### 1. Clone and Setup Project
```bash
# Navigate to project directory
cd individual-finance

# Get Flutter dependencies
flutter pub get

# Verify setup
flutter doctor
```

#### 2. Run the App

**Development Mode:**
```bash
flutter run
```

**Specific Platform:**
```bash
# Android
flutter run -d android

# iOS (Mac only)
flutter run -d ios

# Web
flutter run -d chrome
```

#### 3. Build for Production

**Easy Build (Windows):**
```bash
./build.bat
```

**Easy Build (Mac/Linux):**
```bash
./build.sh
```

**Manual Build Commands:**

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle:**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (Mac only):**
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode
```

**Web:**
```bash
flutter build web --release
# Output: build/web/
```

### 📱 Installation

**Install on Connected Device:**
```bash
flutter install
```

**Install APK Manually:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 🛠 Development Commands

```bash
# Hot reload (development)
flutter hot-reload

# Hot restart
flutter hot-restart

# Run tests
flutter test

# Format code
flutter format .

# Analyze code
flutter analyze

# Clean build cache
flutter clean
```

### 🔍 Troubleshooting

#### Common Issues:

1. **"Flutter command not found"**
   - Add Flutter to your system PATH
   - Restart terminal/command prompt

2. **"Android licenses not accepted"**
   ```bash
   flutter doctor --android-licenses
   ```

3. **"No connected devices"**
   - Enable USB debugging on Android device
   - For iOS, ensure device is trusted

4. **Build failures**
   ```bash
   flutter clean
   flutter pub get
   flutter pub deps
   ```

5. **Gradle build issues**
   - Check Android SDK is properly installed
   - Verify ANDROID_HOME environment variable

#### Check System Setup:
```bash
flutter doctor -v
```

This command shows detailed information about your Flutter installation and any issues that need to be resolved.

### 📁 Project Structure

```
individual-finance/
├── android/          # Android-specific files
├── ios/              # iOS-specific files
├── lib/              # Dart source code
│   ├── models/       # Data models
│   ├── providers/    # State management
│   ├── screens/      # UI screens
│   ├── widgets/      # Reusable components
│   ├── services/     # Business logic
│   └── utils/        # Utilities
├── web/              # Web-specific files
├── assets/           # Images, fonts, etc.
├── build/            # Build outputs
└── pubspec.yaml      # Dependencies
```

### 🎨 Features Included

- ✅ **Complete Expense Tracking**
- ✅ **Smart Category Management**
- ✅ **Interactive Reports & Charts**
- ✅ **Payment Reminders**
- ✅ **Dark/Light Mode**
- ✅ **Local Data Storage**
- ✅ **Modern Material Design UI**
- ✅ **Smooth Animations**
- ✅ **Mockup Data Included**

### 📞 Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Run `flutter doctor` to verify your setup
3. Check Flutter documentation: https://flutter.dev/docs
4. Create an issue in the project repository

### 🚀 Next Steps

Once the app is built and running:

1. Explore the dashboard with pre-loaded demo data
2. Add your own expenses using the "+" button
3. View detailed reports in the Reports tab
4. Set up payment reminders in Settings
5. Customize categories and preferences

**Happy expense tracking! 💰📱**