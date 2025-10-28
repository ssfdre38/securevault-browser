#!/bin/bash
#
# Build Debian/Ubuntu package for SecureVault Browser
#
set -e

VERSION="6.0.0"
BUILD_DATE=$(date +%Y%m%d)
ARCH="amd64"
PACKAGE_NAME="securevault-browser"
BUILD_DIR="/tmp/securevault-deb"

echo "Building Debian package..."

# Create package structure
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/${PACKAGE_NAME}_${VERSION}"/{DEBIAN,opt/securevault-browser,usr/{bin,share/{applications,icons/hicolor/128x128/apps}}}

cd "$BUILD_DIR/${PACKAGE_NAME}_${VERSION}"

# Extract Ungoogled-Chromium
if [ ! -f /tmp/securevault-build-linux.tar.xz ]; then
    wget -q --show-progress \
        "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.69-1/ungoogled-chromium_131.0.6778.69-1_linux.tar.xz" \
        -O /tmp/securevault-build-linux.tar.xz
fi

tar -xf /tmp/securevault-build-linux.tar.xz -C /tmp/
CHROMIUM_SRC=$(find /tmp/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Copy Chromium files
cp -r "$CHROMIUM_SRC"/* opt/securevault-browser/

# Create control file
cat > DEBIAN/control << CONTROL
Package: $PACKAGE_NAME
Version: $VERSION-$BUILD_DATE
Section: web
Priority: optional
Architecture: $ARCH
Depends: libc6, libgtk-3-0, libnspr4, libnss3, libx11-6, libxcomposite1, libxdamage1, libxext6, libxfixes3, libxrandr2
Maintainer: Barrer Software <security@barrersoftware.com>
Description: Privacy and security-focused web browser
 SecureVault Browser is a privacy-first web browser based on
 Ungoogled-Chromium with enhanced security features including:
 .
  - DNS-over-HTTPS encryption
  - WebRTC leak protection  
  - Fingerprinting protection
  - No telemetry or tracking
  - HTTPS-only mode
  - Site isolation and sandboxing
 .
 Perfect for users who value privacy and security.
Homepage: https://barrersoftware.com
CONTROL

# Create launcher
cat > usr/bin/securevault-browser << 'LAUNCHER'
#!/bin/bash
exec /opt/securevault-browser/chrome \
    --disable-background-networking \
    --disable-sync \
    --dns-over-https-mode=secure \
    --dns-over-https-server=https://1.1.1.1/dns-query \
    --enable-features=WebRTCHideLocalIpsWithMdns \
    --https-only-mode \
    --no-pings \
    "$@"
LAUNCHER
chmod +x usr/bin/securevault-browser

# Create desktop file
cat > usr/share/applications/securevault-browser.desktop << 'DESKTOP'
[Desktop Entry]
Version=1.0
Name=SecureVault Browser
GenericName=Secure Web Browser
Comment=Privacy and security-focused web browser
Exec=securevault-browser %U
Terminal=false
Type=Application
Icon=securevault-browser
Categories=Network;WebBrowser;Security;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
DESKTOP

# Create postinst script
cat > DEBIAN/postinst << 'POSTINST'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database -q
fi

# Update MIME database
if command -v update-mime-database >/dev/null 2>&1; then
    update-mime-database /usr/share/mime
fi

echo "SecureVault Browser installed successfully!"
echo "Launch from applications menu or run: securevault-browser"
POSTINST
chmod +x DEBIAN/postinst

# Create prerm script  
cat > DEBIAN/prerm << 'PRERM'
#!/bin/bash
set -e
exit 0
PRERM
chmod +x DEBIAN/prerm

# Build package
cd "$BUILD_DIR"
dpkg-deb --build "${PACKAGE_NAME}_${VERSION}"

# Move to output
OUTPUT="/mnt/projects/repos/securevault-browser/builds"
mkdir -p "$OUTPUT"
mv "${PACKAGE_NAME}_${VERSION}.deb" "$OUTPUT/${PACKAGE_NAME}_${VERSION}-${BUILD_DATE}_${ARCH}.deb"

echo "✓ Debian package created: ${PACKAGE_NAME}_${VERSION}-${BUILD_DATE}_${ARCH}.deb"

# Create APT repository entry
cat > "$OUTPUT/${PACKAGE_NAME}.list" << APTREPO
# SecureVault Browser Repository
deb https://repo.secureos.xyz noble main security
APTREPO

echo "✓ APT repository configuration created"
