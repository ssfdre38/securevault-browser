#!/bin/bash
#
# SecureVault Browser - Complete Build System
# Builds packages for all major distributions
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

cat << 'BANNER'
╔═══════════════════════════════════════════════════════════╗
║     SecureVault Browser - Complete Build System           ║
║     Building packages for all major distributions         ║
╚═══════════════════════════════════════════════════════════╝
BANNER

echo ""
log "This will build:"
echo "  ✅ Debian/Ubuntu (.deb)"
echo "  ✅ Fedora/RHEL (.rpm)"
echo "  ✅ Arch Linux (PKGBUILD)"
echo "  ✅ AppImage (Universal)"
echo "  ✅ Windows (Portable ZIP)"
echo "  ✅ Tarball (Universal)"
echo ""

read -p "Build all packages? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

BUILD_DIR="$(dirname $0)"
cd "$BUILD_DIR"

# Track results
RESULTS=()

# 1. Debian/Ubuntu
log "Building Debian/Ubuntu package..."
if bash build-debian-package.sh 2>&1 | tee /tmp/build-deb.log | tail -5; then
    success "Debian package built"
    RESULTS+=("✅ Debian/Ubuntu (.deb)")
else
    error "Debian build failed"
    RESULTS+=("❌ Debian/Ubuntu (.deb)")
fi

# 2. Fedora/RHEL RPM
log "Building RPM package..."
if bash build-rpm-package.sh 2>&1 | tee /tmp/build-rpm.log | tail -5; then
    success "RPM package built"
    RESULTS+=("✅ Fedora/RHEL (.rpm)")
else
    warn "RPM build failed (may need Fedora/RHEL system)"
    RESULTS+=("⚠️  Fedora/RHEL (.rpm)")
fi

# 3. AppImage
log "Building AppImage..."
if bash build-appimage.sh 2>&1 | tee /tmp/build-appimage.log | tail -5; then
    success "AppImage built"
    RESULTS+=("✅ AppImage (Universal)")
else
    warn "AppImage build failed"
    RESULTS+=("⚠️  AppImage (Universal)")
fi

# 4. Windows Package
log "Building Windows package..."
if bash create-windows-package.sh 2>&1 | tee /tmp/build-windows.log | tail -5; then
    success "Windows package built"
    RESULTS+=("✅ Windows (Portable)")
else
    error "Windows build failed"
    RESULTS+=("❌ Windows (Portable)")
fi

# 5. Enhanced Security Build (Tarball)
log "Building enhanced security tarball..."
if bash build-secure.sh 2>&1 | tee /tmp/build-secure.log | tail -10; then
    success "Security-enhanced tarball built"
    RESULTS+=("✅ Linux Tarball (Enhanced)")
else
    error "Tarball build failed"
    RESULTS+=("❌ Linux Tarball (Enhanced)")
fi

# Generate checksums for all packages
log "Generating checksums..."
cd builds/
for file in *.deb *.rpm *.AppImage *.zip *.tar.gz; do
    if [ -f "$file" ] && [ ! -f "$file.sha256" ]; then
        sha256sum "$file" > "$file.sha256"
    fi
done

# Summary
echo ""
echo "═══════════════════════════════════════════════════════"
echo "           Build Summary"
echo "═══════════════════════════════════════════════════════"
echo ""
for result in "${RESULTS[@]}"; do
    echo "  $result"
done
echo ""

# Show output directory
log "Output directory: $(pwd)"
echo ""
log "Built packages:"
ls -lh *.deb *.rpm *.AppImage *.zip 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'

echo ""
success "Build system complete!"
echo ""
log "Next steps:"
echo "  1. Upload to GitHub releases: gh release upload ..."
echo "  2. Add to repositories: repo.secureos.xyz"
echo "  3. Publish to AUR (Arch Linux)"
echo "  4. Update website with download links"
