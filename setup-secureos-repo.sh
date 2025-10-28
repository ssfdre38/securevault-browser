#!/bin/bash
#
# Setup SecureVault Browser in SecureOS Repository
#
set -e

REPO_DIR="/var/www/html/secureos"
DIST="noble"
COMPONENT="main"

echo "Setting up SecureVault Browser in SecureOS repository..."

# Install reprepro if needed
if ! command -v reprepro &> /dev/null; then
    sudo apt update && sudo apt install -y reprepro gnupg
fi

# Configure reprepro
sudo mkdir -p "$REPO_DIR/conf"

sudo tee "$REPO_DIR/conf/distributions" > /dev/null << DIST
Origin: SecureOS
Label: SecureOS
Codename: $DIST
Architectures: amd64 arm64 i386
Components: $COMPONENT security
Description: SecureOS Package Repository
SignWith: yes

DIST

# Add SecureVault Browser package
PACKAGE_FILE="/mnt/projects/repos/securevault-browser/builds/securevault-browser_6.0.0-20251028_amd64.deb"

if [ -f "$PACKAGE_FILE" ]; then
    echo "Adding SecureVault Browser to repository..."
    cd "$REPO_DIR"
    sudo reprepro includedeb $DIST "$PACKAGE_FILE"
    echo "✓ Package added to repository"
else
    echo "✗ Package not found: $PACKAGE_FILE"
    exit 1
fi

# Update repository permissions
sudo chown -R www-data:www-data "$REPO_DIR"

echo ""
echo "✓ SecureVault Browser added to SecureOS repository!"
echo ""
echo "Users can install with:"
echo "  sudo apt update"
echo "  sudo apt install securevault-browser"
echo ""
echo "Repository URL:"
echo "  https://repo.secureos.xyz"
