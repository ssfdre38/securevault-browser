#!/bin/bash
#
# SecureVault Browser - Complete Release Build
# Builds all packages for all platforms
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
║     SecureVault Browser - Complete Release Build          ║
║     Barrer Software © 2025                                 ║
╚═══════════════════════════════════════════════════════════╝
BANNER

echo ""
log "Building packages for:"
echo "  📦 Debian/Ubuntu (.deb)"
echo "  📦 Fedora/RHEL (.rpm)"
echo "  📦 AppImage (Universal Linux)"
echo "  📦 Windows Portable (.zip)"
echo "  📦 Branded Linux Tarball"
echo ""

BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BUILD_DIR"

# Track what was built
BUILT_PACKAGES=()
FAILED_PACKAGES=()

# 1. Branded Linux Tarball (PRIMARY)
echo ""
log "═══════════════════════════════════════════════════════════"
log "Building Branded Linux Tarball..."
log "═══════════════════════════════════════════════════════════"
if bash build-branded.sh 2>&1 | tee /tmp/build-branded.log; then
    success "Branded tarball built"
    BUILT_PACKAGES+=("✅ Branded Linux Tarball (184 MB)")
else
    error "Branded build failed"
    FAILED_PACKAGES+=("❌ Branded Linux Tarball")
fi

# 2. Debian/Ubuntu Package
echo ""
log "═══════════════════════════════════════════════════════════"
log "Building Debian/Ubuntu Package..."
log "═══════════════════════════════════════════════════════════"
if bash build-debian-package.sh 2>&1 | tee /tmp/build-deb.log; then
    success "Debian package built"
    BUILT_PACKAGES+=("✅ Debian/Ubuntu Package (132 MB)")
else
    error "Debian build failed"
    FAILED_PACKAGES+=("❌ Debian/Ubuntu Package")
fi

# 3. RPM Package
echo ""
log "═══════════════════════════════════════════════════════════"
log "Building RPM Package..."
log "═══════════════════════════════════════════════════════════"
if bash build-rpm-package.sh 2>&1 | tee /tmp/build-rpm.log; then
    success "RPM package built"
    BUILT_PACKAGES+=("✅ RPM Package (Fedora/RHEL)")
else
    warn "RPM build failed (may need RPM tools)"
    FAILED_PACKAGES+=("⚠️  RPM Package")
fi

# 4. AppImage
echo ""
log "═══════════════════════════════════════════════════════════"
log "Building AppImage..."
log "═══════════════════════════════════════════════════════════"
if bash build-appimage.sh 2>&1 | tee /tmp/build-appimage.log; then
    success "AppImage built"
    BUILT_PACKAGES+=("✅ AppImage (Universal Linux)")
else
    warn "AppImage build failed"
    FAILED_PACKAGES+=("⚠️  AppImage")
fi

# 5. Windows Portable (already built, verify it exists)
echo ""
log "═══════════════════════════════════════════════════════════"
log "Checking Windows Portable Package..."
log "═══════════════════════════════════════════════════════════"
if [ -f "builds/SecureVault-Browser-6.0.0-20251028-windows-x64-portable.zip" ]; then
    success "Windows portable package exists"
    BUILT_PACKAGES+=("✅ Windows Portable (162 MB)")
else
    log "Building Windows portable package..."
    if bash create-windows-package.sh 2>&1 | tee /tmp/build-windows.log; then
        success "Windows package built"
        BUILT_PACKAGES+=("✅ Windows Portable (162 MB)")
    else
        error "Windows build failed"
        FAILED_PACKAGES+=("❌ Windows Portable")
    fi
fi

# Generate checksums for all packages
echo ""
log "═══════════════════════════════════════════════════════════"
log "Generating checksums..."
log "═══════════════════════════════════════════════════════════"
cd builds/
for file in *.deb *.rpm *.AppImage *.zip *branded*.tar.gz; do
    if [ -f "$file" ] && [ ! -f "$file.sha256" ]; then
        sha256sum "$file" > "$file.sha256"
        log "Generated checksum for $file"
    fi
done

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "           BUILD SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "SUCCESSFULLY BUILT:"
for pkg in "${BUILT_PACKAGES[@]}"; do
    echo "  $pkg"
done

if [ ${#FAILED_PACKAGES[@]} -gt 0 ]; then
    echo ""
    echo "FAILED BUILDS:"
    for pkg in "${FAILED_PACKAGES[@]}"; do
        echo "  $pkg"
    done
fi

# Show built files
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "           BUILT PACKAGES"
echo "═══════════════════════════════════════════════════════════"
echo ""
cd builds/
ls -lh *.deb *.rpm *.AppImage *.zip *branded*.tar.gz 2>/dev/null | awk '{printf "  %-50s %8s\n", $9, $5}' | grep -v "^$" || echo "  No packages found"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "Total packages: $(ls -1 *.deb *.rpm *.AppImage *.zip *branded*.tar.gz 2>/dev/null | wc -l)"
echo "Total size: $(du -ch *.deb *.rpm *.AppImage *.zip *branded*.tar.gz 2>/dev/null | tail -1 | awk '{print $1}')"
echo ""

if [ ${#BUILT_PACKAGES[@]} -ge 4 ]; then
    success "Release build complete! Ready to publish."
    echo ""
    log "Next steps:"
    echo "  1. Upload to GitHub: gh release upload v6.0.0-build20251028 builds/*"
    echo "  2. Update repositories: bash setup-all-repos.sh"
    echo "  3. Publish release notes"
    exit 0
else
    error "Some packages failed to build"
    exit 1
fi
