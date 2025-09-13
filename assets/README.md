# Assets Directory

This directory contains all the static assets for the Finance Tracker app.

## Directory Structure

```
assets/
├── images/          # App images and illustrations
├── icons/           # Custom app icons
├── animations/      # Lottie animation files
└── fonts/           # Custom fonts (Poppins family)
```

## Images
- Background images for app themes
- Illustrations for empty states
- Logo and branding assets

## Icons
- Custom SVG icons for categories
- Payment method icons
- Navigation and UI icons

## Animations
- Loading animations
- Success/error animations
- Onboarding animations

## Fonts
- Poppins Regular (400)
- Poppins Medium (500)
- Poppins SemiBold (600)
- Poppins Bold (700)

## Usage

All assets are referenced in `pubspec.yaml` and can be used throughout the app:

```dart
// Images
Image.asset('assets/images/logo.png')

// Icons
SvgPicture.asset('assets/icons/wallet.svg')

// Animations
Lottie.asset('assets/animations/loading.json')
```

## Adding New Assets

1. Place files in appropriate subdirectory
2. Update `pubspec.yaml` if needed
3. Reference in code using asset path
4. Optimize images for mobile (WebP recommended)
5. Ensure proper naming conventions (snake_case)

## Optimization

- Use WebP format for images when possible
- Compress images to reduce app size
- Use SVG for scalable icons
- Optimize Lottie animations for performance