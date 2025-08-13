# Google Play Store Setup Guide

This guide will help you prepare your NSBLPA Fan App for Google Play Store submission.

## Prerequisites

1. **Google Play Console Account**: You need a Google Play Console developer account ($25 one-time fee)
2. **App Bundle**: Google Play prefers Android App Bundles (AAB) over APK files
3. **Privacy Policy**: Required for apps that collect user data
4. **App Icons**: High-resolution app icons in various sizes

## Step 1: Generate Keystore

The keystore is required to sign your app. Run the provided script:

```bash
# Make the script executable
chmod +x generate_keystore.sh

# Run the script
./generate_keystore.sh
```

**Important**: 
- Keep your keystore file (`upload-keystore.jks`) secure
- Remember the passwords you enter
- You'll need this keystore for all future app updates

## Step 2: Update Build Configuration

After generating the keystore, update `android/app/build.gradle.kts`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = "upload"
        keyPassword = "your_actual_key_password"  // Replace with your key password
        storeFile = file("upload-keystore.jks")
        storePassword = "your_actual_store_password"  // Replace with your store password
    }
}
```

## Step 3: Build Release App Bundle

```bash
# Make the build script executable
chmod +x build_release.sh

# Build the app bundle
./build_release.sh
```

Or manually:
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The AAB file will be located at: `build/app/outputs/bundle/release/app-release.aab`

## Step 4: Google Play Console Setup

1. **Create New App**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Click "Create app"
   - Fill in basic app information

2. **App Content**:
   - **App name**: "NYC Profit Pursuers Fan App"
   - **Package name**: "com.nsblpa.fan.newyork"
   - **Short description**: Brief description of your app
   - **Full description**: Detailed description with features
   - **App category**: Sports or Entertainment

3. **Graphics**:
   - **App icon**: 512x512 PNG
   - **Feature graphic**: 1024x500 PNG
   - **Screenshots**: At least 2 screenshots per device type

4. **Content Rating**:
   - Complete the content rating questionnaire
   - Your app will likely be rated "Everyone" or "Teen"

5. **Privacy Policy**:
   - Create a privacy policy (required for data collection)
   - Host it on a public URL
   - Add the URL to your app listing

## Step 5: Upload and Submit

1. **Upload AAB**:
   - Go to "Production" track
   - Click "Create new release"
   - Upload your AAB file
   - Add release notes

2. **Review and Submit**:
   - Review all sections (Store listing, Content rating, etc.)
   - Submit for review
   - Google typically takes 1-7 days to review

## Configuration Details

### Android Configuration
- **minSdk**: 23 (Android 6.0)
- **targetSdk**: 35 (Android 15)
- **compileSdk**: 35

### Permissions
The app requests these permissions:
- `INTERNET`: For API calls and image loading
- `CAMERA`: For taking photos
- `READ_EXTERNAL_STORAGE`: For accessing gallery
- `WRITE_EXTERNAL_STORAGE`: For saving images
- `ACCESS_NETWORK_STATE`: For connectivity handling
- `WAKE_LOCK`: For background processing

### ProGuard Rules
ProGuard is enabled for code obfuscation and size reduction. The rules protect:
- Flutter framework classes
- Firebase services
- Google Sign-In
- HTTP libraries
- Image loading libraries

### Security
- Network security config prevents cleartext traffic
- Backup rules exclude sensitive authentication data
- App signing with upload keystore

## Testing Before Release

1. **Test on Multiple Devices**:
   - Different screen sizes
   - Different Android versions
   - Different manufacturers

2. **Test All Features**:
   - User registration/login
   - Google Sign-In
   - Image upload
   - All app screens
   - Admin features

3. **Performance Testing**:
   - App startup time
   - Memory usage
   - Battery consumption

## Common Issues and Solutions

### Build Issues
- **Keystore not found**: Ensure `upload-keystore.jks` is in `android/app/`
- **Password errors**: Double-check passwords in `build.gradle.kts`
- **ProGuard errors**: Check ProGuard rules for missing classes

### Play Store Issues
- **Rejected for permissions**: Justify each permission in app description
- **Content rating issues**: Review content rating questionnaire
- **Privacy policy required**: Create and host privacy policy

## Post-Launch

1. **Monitor Analytics**: Use Firebase Analytics to track app performance
2. **User Feedback**: Monitor user reviews and ratings
3. **Bug Fixes**: Address issues quickly and release updates
4. **Feature Updates**: Plan regular updates to keep users engaged

## Support

For issues with:
- **Flutter**: Check Flutter documentation
- **Firebase**: Check Firebase documentation
- **Google Play**: Check Google Play Console help
- **App-specific**: Review the code and logs

## Security Notes

- Never commit keystore files to version control
- Store keystore passwords securely
- Use different keystores for debug and release
- Regularly backup your keystore file

Good luck with your app launch! 🚀
