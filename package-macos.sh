#!/bin/bash
# Package SecureVault Browser for macOS

echo "=================================================="
echo "SecureVault Browser - macOS Packaging"
echo "=================================================="

if [ ! -d "src/out/SecureVault/Chromium.app" ]; then
    echo "Error: Build output not found. Run build-macos.sh first"
    exit 1
fi

cd src/out/SecureVault

echo "Renaming app bundle..."
cp -R Chromium.app SecureVault.app

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleName SecureVault Browser" SecureVault.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName SecureVault Browser" SecureVault.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.securevault.browser" SecureVault.app/Contents/Info.plist

echo "Creating DMG..."
cd ../../../

# Create DMG
hdiutil create -volname "SecureVault Browser" \
    -srcfolder src/out/SecureVault/SecureVault.app \
    -ov -format UDZO \
    securevault-browser-macos-x64.dmg

echo ""
echo "=================================================="
echo "macOS package created!"
echo "=================================================="
echo "Output: securevault-browser-macos-x64.dmg"
echo ""
