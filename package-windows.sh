#!/bin/bash
# Package SecureVault Browser for Windows

echo "=================================================="
echo "SecureVault Browser - Windows Packaging"
echo "=================================================="

if [ ! -d "src/out/SecureVault" ]; then
    echo "Error: Build output not found. Run build-windows.sh first"
    exit 1
fi

cd src/out/SecureVault

echo "Creating Windows package..."

# Create package directory
mkdir -p ../../../package/SecureVault

# Copy files
cp chrome.exe ../../../package/SecureVault/SecureVault.exe
cp *.dll ../../../package/SecureVault/ 2>/dev/null || true
cp *.pak ../../../package/SecureVault/
cp -r locales ../../../package/SecureVault/
cp -r resources ../../../package/SecureVault/ 2>/dev/null || true

cd ../../../

# Create README for package
cat > package/SecureVault/README.txt << 'EOF'
SecureVault Browser - Windows

To run: Double-click SecureVault.exe

Privacy-focused browser with:
- Zero telemetry
- DNS-over-HTTPS by default
- WebRTC protection
- Third-party cookie blocking
- No Google services

For more information: https://github.com/your-repo/securevault-browser
EOF

# Create ZIP archive
cd package
zip -r ../securevault-browser-windows-x64.zip SecureVault/

cd ..
echo ""
echo "=================================================="
echo "Windows package created!"
echo "=================================================="
echo "Output: securevault-browser-windows-x64.zip"
echo ""
