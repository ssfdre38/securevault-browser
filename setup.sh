#!/bin/bash
set -e

echo "=================================================="
echo "SecureVault Browser Setup"
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Checking system requirements...${NC}"

# Check disk space (need at least 100GB)
AVAILABLE=$(df . | tail -1 | awk '{print $4}')
if [ "$AVAILABLE" -lt 104857600 ]; then
    echo -e "${RED}Error: Need at least 100GB free disk space${NC}"
    exit 1
fi

echo -e "${GREEN}Installing dependencies...${NC}"

# Install depot_tools
if [ ! -d "depot_tools" ]; then
    echo "Cloning depot_tools..."
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
fi

export PATH="$PWD/depot_tools:$PATH"

# Install build dependencies on Linux
if [ "$(uname)" == "Linux" ]; then
    echo "Installing Linux dependencies..."
    sudo apt-get update
    sudo apt-get install -y \
        git curl python3 python3-pip lsb-release sudo \
        build-essential gperf bison flex ninja-build \
        pkg-config libnss3-dev libglib2.0-dev libgtk-3-dev \
        libdbus-1-dev libatk1.0-dev libatk-bridge2.0-dev \
        libcups2-dev libdrm-dev libxkbcommon-dev \
        libxcomposite-dev libxdamage-dev libxrandr-dev \
        libgbm-dev libpam0g-dev libpango1.0-dev \
        libpci-dev libpulse-dev libasound2-dev \
        nodejs npm
fi

echo -e "${GREEN}Fetching Chromium source...${NC}"
echo -e "${YELLOW}This will take a while (30-60 minutes depending on connection)${NC}"

# Create .gclient config
if [ ! -f ".gclient" ]; then
    cat > .gclient << 'EOF'
solutions = [
  {
    "name": "src",
    "url": "https://chromium.googlesource.com/chromium/src.git",
    "managed": False,
    "custom_deps": {},
    "custom_vars": {},
  },
]
target_os = ["linux"]
EOF
fi

# Fetch Chromium source
if [ ! -d "src" ]; then
    fetch --nohooks chromium
    cd src
    git checkout -b securevault main
    cd ..
fi

cd src

# Run hooks to pull dependencies
echo -e "${GREEN}Running gclient sync (this takes 30+ minutes)...${NC}"
gclient sync --no-history

# Install additional build dependencies
if [ "$(uname)" == "Linux" ]; then
    ./build/install-build-deps.sh --no-prompt
fi

cd ..

echo -e "${GREEN}Applying SecureVault patches...${NC}"

# Apply our privacy and security patches
if [ -d "patches" ]; then
    cd src
    for patch in ../patches/*.patch; do
        if [ -f "$patch" ]; then
            echo "Applying $(basename $patch)..."
            git apply "$patch" || echo "Patch already applied or failed: $patch"
        fi
    done
    cd ..
fi

# Copy branding files
echo -e "${GREEN}Installing branding...${NC}"
if [ -d "branding" ]; then
    cp -r branding/* src/chrome/app/theme/
fi

echo ""
echo -e "${GREEN}=================================================="
echo -e "Setup complete!"
echo -e "==================================================${NC}"
echo ""
echo "Next steps:"
echo "  1. Review configuration in branding/"
echo "  2. Run ./build.sh to build the browser"
echo "  3. Run ./run.sh to launch SecureVault Browser"
echo ""
