#!/bin/bash
#
# SecureVault Browser - Binary-Based Build
# Uses Ungoogled-Chromium as base
#
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

WORK_DIR="/tmp/securevault-build"
VERSION="6.0.0"

cat << 'BANNER'
╔═══════════════════════════════════════════════════════════╗
║          SecureVault Browser Builder                      ║
║          Based on Ungoogled-Chromium                      ║
╚═══════════════════════════════════════════════════════════╝
BANNER

echo ""
log "This script will:"
echo "  1. Download Ungoogled-Chromium"
echo "  2. Apply SecureVault branding"
echo "  3. Add privacy configurations"
echo "  4. Package as AppImage (Linux)"
echo ""

# Check system
if ! command -v wget &> /dev/null; then
    error "wget not found"
    exit 1
fi

# Create work directory
log "Creating work directory..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{extract,output,branding}
cd "$WORK_DIR"

# Download Ungoogled-Chromium
log "Downloading Ungoogled-Chromium..."
UNGOOGLED_VERSION="131.0.6778.69-1"
DOWNLOAD_URL="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/${UNGOOGLED_VERSION}/ungoogled-chromium_${UNGOOGLED_VERSION}_linux.tar.xz"

wget -q --show-progress "$DOWNLOAD_URL" -O ungoogled-chromium.tar.xz

# Extract
log "Extracting Ungoogled-Chromium..."
tar -xf ungoogled-chromium.tar.xz -C extract/
CHROMIUM_DIR=$(find extract/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Apply SecureVault branding
log "Applying SecureVault branding..."

# Copy icons
if [ -d "$(dirname $0)/icons" ]; then
    cp -r "$(dirname $0)/icons"/* branding/ 2>/dev/null || true
fi

# Create launcher script
cat > "$CHROMIUM_DIR/securevault-browser" << 'LAUNCHER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set application name
export CHROME_WRAPPER="securevault-browser"

# Privacy flags
PRIVACY_FLAGS=(
    --disable-background-networking
    --disable-breakpad
    --disable-crash-reporter
    --disable-domain-reliability
    --disable-features=AutofillServerCommunication
    --disable-sync
    --dns-over-https-mode=secure
    --dns-over-https-server=https://1.1.1.1/dns-query
    --enable-features=WebRTCHideLocalIpsWithMdns
    --force-dark-mode
    --no-pings
    --no-report-upload
)

# Launch
exec "$SCRIPT_DIR/chrome" "${PRIVACY_FLAGS[@]}" "$@"
LAUNCHER

chmod +x "$CHROMIUM_DIR/securevault-browser"

# Create desktop entry
cat > "$CHROMIUM_DIR/securevault-browser.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Name=SecureVault Browser
GenericName=Web Browser
Comment=Privacy and security-focused web browser
Exec=securevault-browser %U
Terminal=false
Type=Application
Icon=securevault-browser
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
DESKTOP

# Create default preferences
log "Configuring privacy settings..."
cat > "$CHROMIUM_DIR/master_preferences" << 'PREFS'
{
  "homepage": "about:blank",
  "homepage_is_newtabpage": false,
  "browser": {
    "show_home_button": true,
    "check_default_browser": false
  },
  "session": {
    "restore_on_startup": 1
  },
  "bookmark_bar": {
    "show_on_all_tabs": true
  },
  "sync_promo": {
    "show_on_first_run_allowed": false
  },
  "distribution": {
    "skip_first_run_ui": true,
    "show_welcome_page": false,
    "import_history": false,
    "import_bookmarks": false,
    "import_home_page": false,
    "import_search_engine": false,
    "suppress_first_run_default_browser_prompt": true
  },
  "dns_over_https": {
    "mode": "secure",
    "templates": "https://1.1.1.1/dns-query"
  },
  "profile": {
    "default_content_setting_values": {
      "cookies": 1,
      "geolocation": 2,
      "notifications": 2,
      "media_stream": 2
    }
  }
}
PREFS

# Create AppImage (optional)
if command -v appimagetool &> /dev/null; then
    log "Creating AppImage..."
    appimagetool "$CHROMIUM_DIR" "output/SecureVault-Browser-${VERSION}-x86_64.AppImage"
else
    log "AppImage tool not found, creating tarball instead..."
    cd "$CHROMIUM_DIR"
    tar -czf "../output/SecureVault-Browser-${VERSION}-linux-x64.tar.gz" .
    cd ..
fi

# Copy to output
log "Copying to output directory..."
OUTPUT_DIR="$(dirname $0)/builds"
mkdir -p "$OUTPUT_DIR"

if [ -f "output/SecureVault-Browser-${VERSION}-x86_64.AppImage" ]; then
    cp "output/SecureVault-Browser-${VERSION}-x86_64.AppImage" "$OUTPUT_DIR/"
    OUTPUT_FILE="$OUTPUT_DIR/SecureVault-Browser-${VERSION}-x86_64.AppImage"
else
    cp "output/SecureVault-Browser-${VERSION}-linux-x64.tar.gz" "$OUTPUT_DIR/"
    OUTPUT_FILE="$OUTPUT_DIR/SecureVault-Browser-${VERSION}-linux-x64.tar.gz"
fi

# Generate checksum
log "Generating checksums..."
cd "$OUTPUT_DIR"
sha256sum "$(basename $OUTPUT_FILE)" > "$(basename $OUTPUT_FILE).sha256"

success "Build complete!"
echo ""
log "Output:"
echo "  File: $OUTPUT_FILE"
echo "  Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo "  SHA256: $(cat "$(basename $OUTPUT_FILE).sha256")"
echo ""
log "Test run:"
echo "  Extract and run: ./securevault-browser"
echo ""
log "Based on:"
echo "  Ungoogled-Chromium $UNGOOGLED_VERSION"
echo "  SecureVault Browser $VERSION"
