#!/bin/bash
# Package SecureVault Browser for Linux

echo "=================================================="
echo "SecureVault Browser - Linux Packaging"
echo "=================================================="

if [ ! -f "src/out/SecureVault/chrome" ]; then
    echo "Error: Build output not found. Run build.sh first"
    exit 1
fi

cd src/out/SecureVault

echo "Creating Linux package..."

# Create package directory
mkdir -p ../../../package/securevault-browser

# Copy files
cp chrome ../../../package/securevault-browser/securevault
cp *.pak ../../../package/securevault-browser/
cp *.so* ../../../package/securevault-browser/ 2>/dev/null || true
cp -r locales ../../../package/securevault-browser/
cp -r resources ../../../package/securevault-browser/ 2>/dev/null || true

cd ../../../

# Create launcher script
cat > package/securevault-browser/securevault-browser << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/securevault" \
    --disable-background-networking \
    --disable-breakpad \
    --disable-crash-reporter \
    --disable-sync \
    --disable-translate \
    --disable-domain-reliability \
    --disable-component-update \
    --disable-client-side-phishing-detection \
    --disable-default-apps \
    --no-first-run \
    --no-default-browser-check \
    --no-service-autorun \
    --no-pings \
    --dns-over-https-mode=secure \
    --enable-features=WebRTCHideLocalIpsWithMdns \
    --force-webrtc-ip-handling-policy=default_public_interface_only \
    "$@"
EOF

chmod +x package/securevault-browser/securevault-browser
chmod +x package/securevault-browser/securevault

# Create desktop file
cat > package/securevault-browser/securevault-browser.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Name=SecureVault Browser
Comment=Privacy and security-focused web browser
Exec=/opt/securevault-browser/securevault-browser %U
Terminal=false
Type=Application
Icon=securevault-browser
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
EOF

# Create README
cat > package/securevault-browser/README.txt << 'EOF'
SecureVault Browser - Linux

Installation:
1. Extract this archive
2. Run: ./securevault-browser

Or install system-wide:
sudo mv securevault-browser /opt/
sudo ln -s /opt/securevault-browser/securevault-browser /usr/local/bin/
sudo cp /opt/securevault-browser/securevault-browser.desktop /usr/share/applications/

Privacy-focused browser with:
- Zero telemetry
- DNS-over-HTTPS by default
- WebRTC protection
- Third-party cookie blocking
- No Google services

For more information: https://github.com/your-repo/securevault-browser
EOF

# Create tarball
cd package
tar -czf ../securevault-browser-linux-x64.tar.gz securevault-browser/

cd ..
echo ""
echo "=================================================="
echo "Linux package created!"
echo "=================================================="
echo "Output: securevault-browser-linux-x64.tar.gz"
echo ""
