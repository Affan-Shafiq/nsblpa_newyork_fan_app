#!/bin/bash

# Generate upload keystore for Google Play Store
# This script creates a keystore file that will be used to sign your app

echo "Generating upload keystore for Google Play Store..."
echo ""

# Navigate to android/app directory
cd android/app

# Generate the keystore
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storetype JKS

echo ""
echo "Keystore generated successfully!"
echo ""
echo "IMPORTANT: Please update the following in android/app/build.gradle.kts:"
echo "1. Replace 'your_key_password' with the password you entered for the key"
echo "2. Replace 'your_store_password' with the password you entered for the store"
echo ""
echo "Example:"
echo "keyPassword = \"your_actual_key_password\""
echo "storePassword = \"your_actual_store_password\""
echo ""
echo "Keep your keystore file and passwords secure!"
echo "You'll need them for future app updates."
