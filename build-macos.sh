#!/bin/bash
# macOS build script
set -e

echo "=================================================="
echo "SecureVault Browser - macOS Build Script"
echo "=================================================="

# Add depot_tools to PATH
export PATH="$PWD/depot_tools:$PATH"

# Check if source exists
if [ ! -d "src" ]; then
    echo "Error: Chromium source not found. Run setup script first"
    exit 1
fi

cd src

echo "Configuring macOS build..."
mkdir -p out/SecureVault

cat > out/SecureVault/args.gn << 'EOF'
# Build configuration for SecureVault Browser - macOS

is_debug = false
is_official_build = true
is_component_build = false
symbol_level = 0

chrome_pgo_phase = 0
is_chrome_branded = false

# Custom branding for Barrer Software
chrome_product_full_name = "SecureVault Browser"
chrome_product_name = "SecureVault"
chrome_copyright_owners = "Barrer Software"
chrome_company_name = "Barrer Software"
chrome_company_short_name = "Barrer Software"
chrome_company_url = "https://barrersoftware.com"

# Privacy: Disable Google services
google_api_key = ""
google_default_client_id = ""
google_default_client_secret = ""

# Disable features that phone home
enable_google_now = false
enable_hangout_services_extension = false
enable_remoting = false
enable_nacl = false

# Disable reporting
enable_crash_reporter = false
enable_error_dialogs = false

# Privacy features
enable_mdns = false
enable_service_discovery = false
enable_wifi_bootstrapping = false
enable_one_click_signin = false
safe_browsing_mode = 0

# macOS specific
use_cups = true
use_kerberos = false

# Performance
proprietary_codecs = true
ffmpeg_branding = "Chrome"

# Target architecture
target_cpu = "x64"
target_os = "mac"

# Additional privacy settings
fieldtrial_testing_like_official_build = true
enable_reporting = false
enable_js_protobuf = false

# Build optimizations
use_thin_lto = true
thin_lto_enable_optimizations = true
EOF

echo "Generating build files..."
gn gen out/SecureVault

echo "Starting build..."
echo "This will take 1-3 hours depending on your hardware"

# Build with all cores
ninja -C out/SecureVault chrome

echo ""
echo "=================================================="
echo "Build complete!"
echo "=================================================="
echo ""
echo "Application location: src/out/SecureVault/Chromium.app"
echo ""
echo "To create DMG, run: ./package-macos.sh"
echo ""
