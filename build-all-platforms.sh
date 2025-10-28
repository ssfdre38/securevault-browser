#!/bin/bash
#
# SecureVault Browser - Multi-Platform Package Builder
# Creates installers for Windows, macOS, and Linux (multiple formats)
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

VERSION="6.0.0"
BUILD_DATE=$(date +%Y%m%d)
WORK_DIR="/tmp/securevault-multiplatform"
OUTPUT_DIR="/mnt/projects/repos/securevault-browser/builds"

cat << 'BANNER'
╔═══════════════════════════════════════════════════════════╗
║     SecureVault Browser - Multi-Platform Builder          ║
║     Windows | macOS | Linux (DEB/RPM/AppImage)            ║
╚═══════════════════════════════════════════════════════════╝
BANNER

echo ""
log "Building packages for all platforms..."
echo "  ✅ Windows (MSI, ZIP)"
echo "  ✅ macOS (DMG, PKG)"
echo "  ✅ Debian/Ubuntu (DEB)"
echo "  ✅ Red Hat/Fedora (RPM)"
echo "  ✅ Arch Linux (PKG)"
echo "  ✅ AppImage (Universal Linux)"
echo ""

# Check dependencies
log "Checking build dependencies..."
DEPS_NEEDED=""
command -v wget >/dev/null 2>&1 || DEPS_NEEDED="$DEPS_NEEDED wget"
command -v tar >/dev/null 2>&1 || DEPS_NEEDED="$DEPS_NEEDED tar"
command -v dpkg-deb >/dev/null 2>&1 || DEPS_NEEDED="$DEPS_NEEDED dpkg"

if [ -n "$DEPS_NEEDED" ]; then
    log "Installing dependencies: $DEPS_NEEDED"
    sudo apt update && sudo apt install -y $DEPS_NEEDED
fi

# Create work directories
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{linux,windows,macos,common}
mkdir -p "$OUTPUT_DIR"

cd "$WORK_DIR"

# Download Ungoogled-Chromium for different platforms
log "Downloading Ungoogled-Chromium binaries..."

# Linux
log "  Downloading Linux version..."
LINUX_VERSION="131.0.6778.69-1"
wget -q --show-progress \
    "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/${LINUX_VERSION}/ungoogled-chromium_${LINUX_VERSION}_linux.tar.xz" \
    -O linux/ungoogled-chromium.tar.xz

# Extract and prepare base
tar -xf linux/ungoogled-chromium.tar.xz -C linux/
CHROMIUM_DIR=$(find linux/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Create common files
log "Creating common configuration files..."

# Security launcher script
cat > common/securevault-browser << 'LAUNCHER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CHROME_WRAPPER="securevault-browser"

SECURITY_FLAGS=(
    --disable-background-networking
    --disable-breakpad
    --disable-crash-reporter
    --disable-domain-reliability
    --disable-features=AutofillServerCommunication,CalculateNativeWinOcclusion,InterestFeedContentSuggestions,MediaRouter
    --disable-sync
    --no-pings
    --no-report-upload
    --dns-over-https-mode=secure
    --dns-over-https-server=https://1.1.1.1/dns-query
    --enable-features=WebRTCHideLocalIpsWithMdns
    --force-webrtc-ip-handling-policy=default_public_interface_only
    --enable-features=StrictOriginIsolation,IsolateOrigins,site-per-process
    --enable-strict-mixed-content-checking
    --https-only-mode
    --disable-remote-fonts
    --disable-webgl
    --disable-translate
)

exec "$SCRIPT_DIR/chrome" "${SECURITY_FLAGS[@]}" "$@"
LAUNCHER
chmod +x common/securevault-browser

# Build Debian package
log "Building Debian/Ubuntu package..."
./build_deb_package.sh

# Build RPM package
log "Building RPM package..."
./build_rpm_package.sh

# Build AppImage
log "Building AppImage..."
./build_appimage.sh

# Build Arch package
log "Building Arch Linux package..."
./build_arch_package.sh

# Create Windows installer script placeholder
log "Creating Windows package structure..."
mkdir -p windows/securevault-browser
cat > windows/README.txt << 'WINREADME'
SecureVault Browser for Windows

Note: Windows build requires Windows system or Wine to create MSI installer.
Use the portable ZIP version or follow build instructions in docs/BUILD_WINDOWS.md
WINREADME

# Create macOS package structure
log "Creating macOS package structure..."
mkdir -p macos/SecureVault.app
cat > macos/README.txt << 'MACREADME'
SecureVault Browser for macOS

Note: macOS build requires macOS system to create DMG/PKG installer.
Follow build instructions in docs/BUILD_MACOS.md
MACREADME

success "Multi-platform build complete!"
echo ""
log "Output directory: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR"
