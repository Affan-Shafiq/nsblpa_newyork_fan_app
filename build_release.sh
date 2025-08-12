#!/bin/bash

# Build release APK for Google Play Store
echo "Building release APK for Google Play Store..."

# Clean the project
echo "Cleaning project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build release APK
echo "Building release APK..."
flutter build apk --release

echo ""
echo "Build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "Next steps:"
echo "1. Test the APK on a device"
echo "2. Upload to Google Play Console"
echo "3. Fill in store listing information"
echo "4. Submit for review"
