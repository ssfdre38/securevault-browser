#!/bin/bash
set -e

echo "========================================="
echo "SecureVault Browser - Ungoogled Build"
echo "========================================="
echo ""

# Change to the project directory
cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"
BUILD_OUTPUT="/mnt/projects/builds/chromium"
PACKAGES_OUTPUT="/mnt/projects/builds/packages"

echo "Project Directory: $PROJECT_DIR"
echo "Build Output: $BUILD_OUTPUT"
echo "Packages Output: $PACKAGES_OUTPUT"
echo ""

# Create output directories
mkdir -p "$BUILD_OUTPUT"
mkdir -p "$PACKAGES_OUTPUT"

# Run the ungoogled-chromium build
echo "Starting ungoogled-chromium build..."
if [ -f "build-with-ungoogled.sh" ]; then
    bash build-with-ungoogled.sh
else
    echo "Error: build-with-ungoogled.sh not found!"
    exit 1
fi

# Build branded version if available
if [ -f "build-branded.sh" ]; then
    echo ""
    echo "Building branded version..."
    bash build-branded.sh
fi

# Build packages
echo ""
echo "========================================="
echo "Building Packages"
echo "========================================="
echo ""

# Build Debian package
if [ -f "build-debian-branded.sh" ]; then
    echo "Building Debian package (branded)..."
    bash build-debian-branded.sh
    cp builds/*.deb "$PACKAGES_OUTPUT/" 2>/dev/null || true
elif [ -f "build-debian-package.sh" ]; then
    echo "Building Debian package..."
    bash build-debian-package.sh
    cp builds/*.deb "$PACKAGES_OUTPUT/" 2>/dev/null || true
fi

# Build RPM package
if [ -f "build-rpm-branded.sh" ]; then
    echo "Building RPM package (branded)..."
    bash build-rpm-branded.sh
    cp builds/*.rpm "$PACKAGES_OUTPUT/" 2>/dev/null || true
elif [ -f "build-rpm-package.sh" ]; then
    echo "Building RPM package..."
    bash build-rpm-package.sh
    cp builds/*.rpm "$PACKAGES_OUTPUT/" 2>/dev/null || true
fi

# Build AppImage
if [ -f "build-appimage.sh" ]; then
    echo "Building AppImage..."
    bash build-appimage.sh
    cp builds/*.AppImage "$PACKAGES_OUTPUT/" 2>/dev/null || true
fi

# Build Windows MSI
if [ -f "build-windows-msi.sh" ]; then
    echo "Building Windows MSI..."
    bash build-windows-msi.sh
    cp builds/*.msi "$PACKAGES_OUTPUT/" 2>/dev/null || true
fi

echo ""
echo "========================================="
echo "Build Complete!"
echo "========================================="
echo ""
echo "Build artifacts in: $BUILD_OUTPUT"
echo "Packages in: $PACKAGES_OUTPUT"
echo ""
ls -lh "$PACKAGES_OUTPUT"/* 2>/dev/null || echo "No packages built yet"
echo ""
echo "Build finished at: $(date)"
