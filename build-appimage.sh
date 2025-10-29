#!/bin/bash
#
# Build AppImage for universal Linux compatibility
#
set -e

VERSION="6.0.0"
BUILD_DATE=$(date +%Y%m%d)
WORK_DIR="/tmp/securevault-appimage"
OUTPUT_DIR="/mnt/projects/repos/securevault-browser/builds"

echo "Building AppImage..."

# Install AppImage tools
if ! command -v appimagetool &> /dev/null; then
    echo "Installing AppImage tools..."
    wget -q "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O /tmp/appimagetool
    chmod +x /tmp/appimagetool
    sudo mv /tmp/appimagetool /usr/local/bin/appimagetool
fi

# Create AppDir structure
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/AppDir"/{usr/{bin,lib,share/{applications,icons/hicolor/128x128/apps}},opt/securevault-browser}

# Download source if not exists
if [ ! -f /tmp/securevault-build-linux.tar.xz ]; then
    wget -q --show-progress \
        "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.69-1/ungoogled-chromium_131.0.6778.69-1_linux.tar.xz" \
        -O /tmp/securevault-build-linux.tar.xz
fi

# Extract
tar -xf /tmp/securevault-build-linux.tar.xz -C /tmp/
CHROMIUM_SRC=$(find /tmp/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Copy files
cp -r "$CHROMIUM_SRC"/* "$WORK_DIR/AppDir/opt/securevault-browser/"

# Create AppRun
cat > "$WORK_DIR/AppDir/AppRun" << 'APPRUN'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"

exec "${HERE}/opt/securevault-browser/chrome" \
    --disable-background-networking \
    --disable-sync \
    --dns-over-https-mode=secure \
    --dns-over-https-server=https://1.1.1.1/dns-query \
    --enable-features=WebRTCHideLocalIpsWithMdns \
    --https-only-mode \
    --no-pings \
    "$@"
APPRUN
chmod +x "$WORK_DIR/AppDir/AppRun"

# Create desktop file
cat > "$WORK_DIR/AppDir/securevault-browser.desktop" << 'DESKTOP'
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

# Copy icon (use chrome icon for now)
cp "$WORK_DIR/AppDir/opt/securevault-browser/product_logo_48.png" "$WORK_DIR/AppDir/securevault-browser.png" 2>/dev/null || \
echo "No icon found, skipping"

# Build AppImage
cd "$WORK_DIR"
ARCH=x86_64 appimagetool AppDir "$OUTPUT_DIR/SecureVault-Browser-${VERSION}-${BUILD_DATE}-x86_64.AppImage"

if [ -f "$OUTPUT_DIR/SecureVault-Browser-${VERSION}-${BUILD_DATE}-x86_64.AppImage" ]; then
    chmod +x "$OUTPUT_DIR/SecureVault-Browser-${VERSION}-${BUILD_DATE}-x86_64.AppImage"
    echo "✓ AppImage created: SecureVault-Browser-${VERSION}-${BUILD_DATE}-x86_64.AppImage"
    
    # Generate checksum
    cd "$OUTPUT_DIR"
    sha256sum "SecureVault-Browser-${VERSION}-${BUILD_DATE}-x86_64.AppImage" > "SecureVault-Browser-${VERSION}-${BUILD_DATE}-x86_64.AppImage.sha256"
else
    echo "⚠ AppImage build failed"
fi
