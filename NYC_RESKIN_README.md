# NYC Profit Pursuers Fan App - Reskin Documentation

## Overview
This document outlines the changes made to reskin the Miami Revenue Runners Fan App to the New York Profit Pursuers Fan App.

## Changes Made

### 1. App Configuration
- **Package ID**: Updated to `com.nsblpa.fans.newyork`
- **App Name**: Changed from "Revenue Runners Fan App" to "New York Profit Pursuers Fan App"
- **Description**: Updated in `pubspec.yaml`

### 2. Branding & Colors
- **Primary Color**: Changed to NYC Blue (`#1E40AF`)
- **Secondary Color**: Changed to NYC Orange (`#FF6B35`)
- **Accent Color**: Kept Green (`#10B981`) for profit/growth theme
- **Theme**: Updated in `lib/theme/app_theme.dart`

### 3. UI Updates
- **App Bar Titles**: Updated across all screens
- **Login/Signup Screens**: Replaced Miami logo with NYC-themed icon
- **Welcome Messages**: Updated to "NYC Profit Pursuers"
- **Team Names**: Changed from "Revenue Runners" to "NYC Profit Pursuers"

### 4. Platform-Specific Changes

#### Android
- **Package ID**: `com.nsblpa.fans.newyork`
- **App Label**: "NYC Profit Pursuers Fan App"
- **Icon**: Using default launcher icon (needs NYC logo)

#### iOS
- **Display Name**: "NYC Profit Pursuers"
- **Bundle ID**: Should be updated in Xcode project settings

### 5. Files Modified
- `lib/main.dart` - App title and class name
- `lib/theme/app_theme.dart` - Color scheme
- `pubspec.yaml` - App description
- `android/app/build.gradle.kts` - Package ID
- `android/app/src/main/AndroidManifest.xml` - App label and icon
- `ios/Runner/Info.plist` - Display name
- `lib/screens/home_screen.dart` - App bar title
- `lib/screens/login_screen.dart` - Logo and welcome text
- `lib/screens/signup_screen.dart` - Logo and welcome text
- `lib/screens/news_feed_screen.dart` - News title
- `lib/screens/game_day_screen.dart` - Team name references
- `lib/screens/game_detail_screen.dart` - Team name
- `lib/screens/admin_game_editor_screen.dart` - Team name
- `lib/constants/app_config.dart` - Team ID (needs update)

### 6. Assets
- **Logo**: Created placeholder for NYC logo
- **Logo Generator**: Created `nyc_logo_generator.html` for simple logo creation
- **Placeholder**: Added `assets/logos/nyc_logo_placeholder.txt`

## TODO Items

### High Priority
1. **Team ID**: Update `AppConfig.teamId` in `lib/constants/app_config.dart` to the actual NYC team ID
2. **Logo**: Create and add proper NYC Profit Pursuers logo
3. **Firebase Configuration**: Update Firebase project settings for NYC team

### Medium Priority
1. **App Icon**: Create proper app icons for all platforms
2. **Splash Screen**: Update launch screen with NYC branding
3. **Content**: Update any hardcoded content specific to Miami

### Low Priority
1. **Localization**: Add NYC-specific language/localization
2. **Analytics**: Update analytics tracking for NYC team
3. **Push Notifications**: Update notification settings for NYC team

## Building the App

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Notes
- The app maintains all original functionality
- Only branding and team-specific content has been changed
- Firebase configuration may need updates for the new team
- The team ID in `AppConfig.teamId` needs to be updated to the actual NYC team document ID in Firestore

## Color Palette
- **Primary (NYC Blue)**: `#1E40AF`
- **Secondary (NYC Orange)**: `#FF6B35`
- **Accent (Profit Green)**: `#10B981`
- **Background**: `#F8FAFC`
- **Surface**: `#FFFFFF`
- **Text Primary**: `#1F2937`
- **Text Secondary**: `#6B7280`
- **Error**: `#EF4444`
