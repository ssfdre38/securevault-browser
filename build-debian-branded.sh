#!/bin/bash
set -e

VERSION="6.0.0"
BUILD_DATE="20251028"
WORK_DIR="/tmp/securevault-deb-branded"

echo "[*] Building branded Debian package..."

# Download if needed
if [ ! -f /tmp/securevault-build-linux.tar.xz ]; then
    wget -q --show-progress \
        "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.69-1/ungoogled-chromium_131.0.6778.69-1_linux.tar.xz" \
        -O /tmp/securevault-build-linux.tar.xz
fi

# Setup
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{DEBIAN,opt/securevault-browser,usr/{bin,share/applications}}

# Extract chromium
tar -xf /tmp/securevault-build-linux.tar.xz -C /tmp/
CHROMIUM_SRC=$(find /tmp/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Copy files
cp -r "$CHROMIUM_SRC"/* "$WORK_DIR/opt/securevault-browser/"

# Add Barrer Software branding files
if [ -f "branding/first-run-page.html" ]; then
    cp branding/first-run-page.html "$WORK_DIR/opt/securevault-browser/"
fi

# Create branded README
cat > "$WORK_DIR/opt/securevault-browser/README.txt" << 'README'
SecureVault Browser v6.0.0
Developed by Barrer Software
https://barrersoftware.com

Privacy and Security First, Always

SECURITY FEATURES:
✓ DNS-over-HTTPS (Cloudflare 1.1.1.1)
✓ WebRTC IP Leak Protection
✓ Fingerprinting Protection
✓ Third-Party Cookie Blocking
✓ HTTPS-Only Mode
✓ No Telemetry or Tracking

SUPPORT:
Website: https://barrersoftware.com
Email: security@barrersoftware.com
GitHub: https://github.com/barrersoftware/securevault-browser

© 2025 Barrer Software. All rights reserved.
README

# Branded launcher
cat > "$WORK_DIR/usr/bin/securevault-browser" << 'LAUNCHER'
#!/bin/bash
FIRST_RUN_FLAG="$HOME/.config/securevault-browser/first-run-done"
if [ ! -f "$FIRST_RUN_FLAG" ]; then
    mkdir -p "$(dirname "$FIRST_RUN_FLAG")"
    touch "$FIRST_RUN_FLAG"
    FIRST_RUN_PAGE="file:///opt/securevault-browser/first-run-page.html"
else
    FIRST_RUN_PAGE=""
fi

exec /opt/securevault-browser/chrome \
    --disable-background-networking \
    --disable-sync \
    --dns-over-https-mode=secure \
    --dns-over-https-server=https://1.1.1.1/dns-query \
    --enable-features=WebRTCHideLocalIpsWithMdns \
    --https-only-mode \
    --no-pings \
    ${FIRST_RUN_PAGE:+"$FIRST_RUN_PAGE"} "$@"
LAUNCHER
chmod +x "$WORK_DIR/usr/bin/securevault-browser"

# Desktop file
cat > "$WORK_DIR/usr/share/applications/securevault-browser.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Name=SecureVault Browser
GenericName=Secure Web Browser
Comment=Privacy and security-focused browser by Barrer Software
Exec=securevault-browser %U
Terminal=false
Type=Application
Icon=securevault-browser
Categories=Network;WebBrowser;Security;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
DESKTOP

# Control file
cat > "$WORK_DIR/DEBIAN/control" << CONTROL
Package: securevault-browser
Version: $VERSION-$BUILD_DATE
Section: web
Priority: optional
Architecture: amd64
Maintainer: Barrer Software <security@barrersoftware.com>
Homepage: https://barrersoftware.com
Description: Privacy and security-focused web browser
 SecureVault Browser is a privacy and security-focused web browser
 developed by Barrer Software, based on Ungoogled-Chromium.
 .
 Enhanced security features:
  * DNS-over-HTTPS encryption
  * WebRTC IP leak protection
  * Fingerprinting protection
  * Third-party cookie blocking
  * HTTPS-only mode
  * No telemetry or tracking
CONTROL

# Build package
dpkg-deb --build "$WORK_DIR" "builds/securevault-browser_${VERSION}-${BUILD_DATE}_amd64.deb"

echo "✅ Branded Debian package created"
ls -lh "builds/securevault-browser_${VERSION}-${BUILD_DATE}_amd64.deb"
