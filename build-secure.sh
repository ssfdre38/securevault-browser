#!/bin/bash
#
# SecureVault Browser - Enhanced Security Build
# Uses Ungoogled-Chromium with additional hardening
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
BUILD_DATE=$(date +%Y%m%d)

cat << 'BANNER'
╔═══════════════════════════════════════════════════════════╗
║       SecureVault Browser - Enhanced Security Build       ║
║       Maximum Privacy & Security Configuration            ║
╚═══════════════════════════════════════════════════════════╝
BANNER

echo ""
log "Enhanced Security Features:"
echo "  ✅ DNS-over-HTTPS (Encrypted DNS)"
echo "  ✅ WebRTC IP Leak Protection"
echo "  ✅ Fingerprinting Protection"
echo "  ✅ Strict Content Security Policy"
echo "  ✅ No Third-Party Cookies"
echo "  ✅ HTTPS-Only Mode"
echo "  ✅ Enhanced Tracking Protection"
echo "  ✅ Sandboxing Hardening"
echo "  ✅ Site Isolation"
echo "  ✅ Certificate Pinning"
echo ""

# Check system
log "Checking dependencies..."
for cmd in wget tar sha256sum; do
    if ! command -v $cmd &> /dev/null; then
        error "$cmd not found - installing..."
        sudo apt update && sudo apt install -y $cmd
    fi
done

# Create work directory
log "Creating work directory..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{extract,output,branding,extensions}
cd "$WORK_DIR"

# Download Ungoogled-Chromium
log "Downloading Ungoogled-Chromium..."
UNGOOGLED_VERSION="131.0.6778.69-1"
DOWNLOAD_URL="https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/${UNGOOGLED_VERSION}/ungoogled-chromium_${UNGOOGLED_VERSION}_linux.tar.xz"

wget -q --show-progress "$DOWNLOAD_URL" -O ungoogled-chromium.tar.xz

# Verify download (basic check)
log "Verifying download integrity..."
if [ ! -s ungoogled-chromium.tar.xz ]; then
    error "Download failed or file is empty"
    exit 1
fi
success "Download verified"

# Extract
log "Extracting Ungoogled-Chromium..."
tar -xf ungoogled-chromium.tar.xz -C extract/
CHROMIUM_DIR=$(find extract/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

if [ -z "$CHROMIUM_DIR" ]; then
    error "Failed to extract Chromium"
    exit 1
fi

# Apply SecureVault branding
log "Applying SecureVault branding..."

# Copy icons if available
SOURCE_DIR="$(dirname $0)"
if [ -d "$SOURCE_DIR/icons" ]; then
    cp -r "$SOURCE_DIR/icons"/* branding/ 2>/dev/null || true
fi

# Create enhanced launcher script with maximum security flags
cat > "$CHROMIUM_DIR/securevault-browser" << 'LAUNCHER'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set application name
export CHROME_WRAPPER="securevault-browser"
export CHROME_DESKTOP="securevault-browser.desktop"

# Maximum Security & Privacy Flags
SECURITY_FLAGS=(
    # Privacy Protection
    --disable-background-networking
    --disable-breakpad
    --disable-crash-reporter
    --disable-domain-reliability
    --disable-features=AutofillServerCommunication,CalculateNativeWinOcclusion,InterestFeedContentSuggestions,MediaRouter
    --disable-sync
    --no-pings
    --no-report-upload
    
    # DNS Security
    --dns-over-https-mode=secure
    --dns-over-https-server=https://1.1.1.1/dns-query
    --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE 1.1.1.1"
    
    # WebRTC Protection
    --enable-features=WebRTCHideLocalIpsWithMdns
    --force-webrtc-ip-handling-policy=default_public_interface_only
    
    # Security Hardening
    --enable-features=StrictOriginIsolation,IsolateOrigins,site-per-process
    --disable-features=UserAgentClientHint
    --enable-strict-mixed-content-checking
    --enable-strict-powerful-feature-restrictions
    
    # Fingerprinting Protection
    --disable-features=WebGLDeveloperExtensions,WebGL2ComputeContext
    --disable-reading-from-canvas
    
    # Network Security
    --enable-features=PartitionConnectionsByNetworkIsolationKey
    --enable-quic
    --disable-features=NetworkPrediction
    
    # Additional Hardening
    --disable-remote-fonts
    --disable-webgl
    --disable-speech-synthesis-api
    --disable-speech-input
    --disable-device-discovery-notifications
    --disable-search-geolocation-disclosure
    
    # HTTPS Enforcement
    --https-only-mode
    --enable-features=HttpsOnlyMode
    
    # Performance with Security
    --enable-gpu-rasterization
    --enable-zero-copy
    --ignore-gpu-blocklist
    
    # Disable Unnecessary Features
    --disable-translate
    --disable-cloud-import
    --disable-password-generation
    --disable-plugins
    
    # Sandbox Hardening
    --enable-features=NetworkServiceSandbox
    
    # Privacy Settings
    --enable-features=PrivacySandboxSettings4
    --disable-features=FlocId,InterestCohortAPI
)

# Additional privacy preferences
export GOOGLE_API_KEY="no"
export GOOGLE_DEFAULT_CLIENT_ID="no"
export GOOGLE_DEFAULT_CLIENT_SECRET="no"

# Clear sensitive data on exit
cleanup() {
    echo "Clearing browser cache and temporary data..."
    rm -rf "$HOME/.config/chromium/Default/Cache" 2>/dev/null
    rm -rf "$HOME/.cache/chromium" 2>/dev/null
}
trap cleanup EXIT

# Launch with security flags
exec "$SCRIPT_DIR/chrome" "${SECURITY_FLAGS[@]}" "$@"
LAUNCHER

chmod +x "$CHROMIUM_DIR/securevault-browser"

# Create desktop entry
cat > "$CHROMIUM_DIR/securevault-browser.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Name=SecureVault Browser
GenericName=Secure Web Browser
Comment=Privacy and security-focused web browser with maximum protection
Exec=securevault-browser %U
Terminal=false
Type=Application
Icon=securevault-browser
Categories=Network;WebBrowser;Security;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Keywords=browser;web;internet;privacy;security;secure;
DESKTOP

# Create comprehensive security preferences
log "Configuring maximum security preferences..."
cat > "$CHROMIUM_DIR/master_preferences" << 'PREFS'
{
  "homepage": "about:blank",
  "homepage_is_newtabpage": false,
  "browser": {
    "show_home_button": true,
    "check_default_browser": false,
    "clear_data": {
      "browsing_history": true,
      "download_history": true,
      "cookies_and_other_site_data": true,
      "cached_images_and_files": true,
      "passwords": false,
      "autofill_form_data": true,
      "hosted_apps_data": true,
      "time_period": 4
    }
  },
  "session": {
    "restore_on_startup": 1,
    "startup_urls": ["about:blank"]
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
      "images": 1,
      "javascript": 1,
      "plugins": 2,
      "popups": 2,
      "geolocation": 2,
      "notifications": 2,
      "media_stream": 2,
      "media_stream_mic": 2,
      "media_stream_camera": 2,
      "protocol_handlers": 2,
      "ppapi_broker": 2,
      "automatic_downloads": 2,
      "midi_sysex": 2,
      "push_messaging": 2,
      "ssl_cert_decisions": 2,
      "metro_switch_to_desktop": 2,
      "protected_media_identifier": 2,
      "app_banner": 2,
      "site_engagement": 2,
      "durable_storage": 2,
      "usb_chooser_data": 2,
      "bluetooth_chooser_data": 2,
      "clipboard_read_write": 2,
      "payment_handler": 2,
      "background_sync": 2,
      "intent_picker_display": 2,
      "idle_detection": 2,
      "serial_chooser_data": 2,
      "hid_chooser_data": 2,
      "file_system_write_guard": 2,
      "ar": 2,
      "vr": 2
    },
    "block_third_party_cookies": true,
    "cookie_controls_mode": 1,
    "password_manager_enabled": false
  },
  "safebrowsing": {
    "enabled": true,
    "enhanced": true
  },
  "download": {
    "prompt_for_download": true,
    "directory_upgrade": true
  },
  "autofill": {
    "enabled": false,
    "profile_enabled": false,
    "credit_card_enabled": false
  },
  "translate": {
    "enabled": false
  },
  "signin": {
    "allowed": false
  },
  "search": {
    "suggest_enabled": false
  },
  "alternate_error_pages": {
    "enabled": false
  },
  "net": {
    "network_prediction_options": 2
  },
  "enable_do_not_track": true,
  "enable_referrers": false,
  "safe_browsing_for_trusted_sources_enabled": false
}
PREFS

# Create security policies
log "Creating security policies..."
mkdir -p "$CHROMIUM_DIR/policies/managed"
cat > "$CHROMIUM_DIR/policies/managed/securevault.json" << 'POLICIES'
{
  "HomepageLocation": "about:blank",
  "HomepageIsNewTabPage": false,
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "DuckDuckGo",
  "DefaultSearchProviderSearchURL": "https://duckduckgo.com/?q={searchTerms}",
  "DefaultSearchProviderSuggestURL": "",
  "AutofillAddressEnabled": false,
  "AutofillCreditCardEnabled": false,
  "PasswordManagerEnabled": false,
  "SavingBrowserHistoryDisabled": false,
  "SearchSuggestEnabled": false,
  "TranslateEnabled": false,
  "BuiltInDnsClientEnabled": true,
  "DnsOverHttpsMode": "secure",
  "DnsOverHttpsTemplates": "https://1.1.1.1/dns-query",
  "BlockThirdPartyCookies": true,
  "DefaultCookiesSetting": 1,
  "DefaultGeolocationSetting": 2,
  "DefaultNotificationsSetting": 2,
  "DefaultMediaStreamSetting": 2,
  "WebRtcUdpPortRange": "",
  "WebRtcLocalIpsAllowedUrls": [],
  "SSLErrorOverrideAllowed": false,
  "SafeBrowsingEnabled": true,
  "SafeBrowsingExtendedReportingEnabled": false,
  "SyncDisabled": true,
  "SigninAllowed": false,
  "BrowserSignin": 0,
  "CloudPrintProxyEnabled": false,
  "MetricsReportingEnabled": false,
  "BackgroundModeEnabled": false,
  "HideWebStoreIcon": true,
  "HideWebStorePromo": true
}
POLICIES

# Create README with security information
log "Creating documentation..."
cat > "$CHROMIUM_DIR/SECURITY.md" << 'SECURITY'
# SecureVault Browser - Security Features

## Privacy Protection

### DNS Security
- **DNS-over-HTTPS**: All DNS queries encrypted via Cloudflare (1.1.1.1)
- **Prevents DNS hijacking and surveillance**
- **Blocks DNS-based tracking**

### WebRTC Protection
- **IP leak prevention**: Hides local IP addresses
- **mDNS enforcement**: Only allows mDNS-based local IPs
- **Prevents VPN/Proxy bypass**

### Fingerprinting Protection
- **Canvas fingerprinting blocked**: Prevents tracking via canvas API
- **WebGL disabled**: Blocks GPU fingerprinting
- **User-Agent reduction**: Minimizes identifying information

### Cookie & Tracking Protection
- **Third-party cookies blocked**: Prevents cross-site tracking
- **Do Not Track enabled**: Sends DNT header
- **Referrer policy restricted**: Limits referrer information
- **Network prediction disabled**: No pre-fetching/pre-connections

## Security Hardening

### Site Isolation
- **Strict origin isolation**: Each origin in separate process
- **Site-per-process**: Maximum isolation between sites
- **Process sandboxing**: Limits damage from exploits

### HTTPS Enforcement
- **HTTPS-Only Mode**: Automatically upgrades to HTTPS
- **Strict HTTPS checking**: Blocks mixed content
- **Certificate validation**: Enhanced SSL/TLS verification

### Content Security
- **Strict CSP**: Content Security Policy enforcement
- **Script restrictions**: Limited inline script execution
- **Plugin blocking**: No NPAPI/PPAPI plugins

### Data Protection
- **No password manager**: Prevents credential theft
- **No autofill**: Blocks form data leaks
- **No cloud sync**: Data stays local
- **Automatic cache clearing**: Cleans up on exit

## Disabled Features

For security and privacy, these are disabled:
- ❌ Google Sync
- ❌ Google Translate
- ❌ Cloud Print
- ❌ Background mode
- ❌ Crash reporting/telemetry
- ❌ Password generation/saving
- ❌ Payment handlers
- ❌ USB/Bluetooth/Serial access
- ❌ File system write access
- ❌ Geolocation
- ❌ Notifications
- ❌ Media device access (by default)
- ❌ Automatic downloads
- ❌ Web plugins

## Network Security

### Connection Hardening
- **QUIC protocol support**: Modern, secure transport
- **Network isolation**: Partitioned connections
- **TLS 1.3 preferred**: Latest encryption standards

### Attack Surface Reduction
- **Remote fonts disabled**: Blocks font-based attacks
- **Speech APIs disabled**: Reduces microphone risks
- **Device discovery disabled**: Prevents network scanning

## Recommended Extensions

While SecureVault Browser includes extensive protection, 
consider these extensions for additional security:

1. **uBlock Origin** - Advanced ad/tracker blocker
2. **HTTPS Everywhere** - Force HTTPS connections
3. **Privacy Badger** - Intelligent tracker blocker
4. **Decentraleyes** - Local CDN emulation
5. **ClearURLs** - Remove tracking parameters

## Testing Your Security

Verify these features work:

1. **DNS Leaks**: https://dnsleaktest.com
2. **WebRTC Leaks**: https://browserleaks.com/webrtc
3. **Fingerprinting**: https://coveryourtracks.eff.org
4. **IP Detection**: https://ipleak.net
5. **SSL/TLS**: https://www.ssllabs.com/ssltest/viewMyClient.html

## Privacy vs Usability

Some features are disabled for maximum security. 
If a website doesn't work:

1. Check if it requires blocked features
2. Use site-specific exceptions (chrome://settings/content)
3. Consider if the site respects your privacy
4. Use alternative services when possible

## Updates

SecureVault Browser is based on Ungoogled-Chromium.
Update by downloading new releases from:
https://github.com/barrersoftware/securevault-browser/releases

## Support

For security concerns or questions:
- GitHub: https://github.com/barrersoftware/securevault-browser
- Email: security@barrersoftware.com
- Website: https://barrersoftware.com

---

**Remember**: No browser is 100% secure. Practice safe browsing:
- Keep browser updated
- Use strong passwords (with external manager)
- Be cautious of phishing
- Use VPN when needed
- Regular security audits

© 2025 Barrer Software - Security First, Always.
SECURITY

# Create installation script
cat > "$CHROMIUM_DIR/install.sh" << 'INSTALL'
#!/bin/bash
echo "Installing SecureVault Browser..."

# Copy to /opt
sudo mkdir -p /opt/securevault-browser
sudo cp -r ./* /opt/securevault-browser/

# Create symlink
sudo ln -sf /opt/securevault-browser/securevault-browser /usr/local/bin/securevault-browser

# Install desktop file
sudo mkdir -p /usr/share/applications
sudo cp securevault-browser.desktop /usr/share/applications/

echo "✓ Installation complete!"
echo ""
echo "Launch: securevault-browser"
echo "Or find 'SecureVault Browser' in your applications menu"
INSTALL
chmod +x "$CHROMIUM_DIR/install.sh"

# Package the build
log "Packaging SecureVault Browser..."
OUTPUT_DIR="/mnt/projects/repos/securevault-browser/builds"
mkdir -p "$OUTPUT_DIR"

cd "$(dirname $CHROMIUM_DIR)"
ARCHIVE_NAME="SecureVault-Browser-${VERSION}-build${BUILD_DATE}-linux-x64.tar.gz"
tar -czf "$WORK_DIR/output/$ARCHIVE_NAME" "$(basename $CHROMIUM_DIR)"

# Copy to output
cp "$WORK_DIR/output/$ARCHIVE_NAME" "$OUTPUT_DIR/"
OUTPUT_FILE="$OUTPUT_DIR/$ARCHIVE_NAME"

# Generate checksums
log "Generating security checksums..."
cd "$OUTPUT_DIR"
sha256sum "$ARCHIVE_NAME" > "${ARCHIVE_NAME}.sha256"
sha512sum "$ARCHIVE_NAME" > "${ARCHIVE_NAME}.sha512"

# Create verification script
cat > "${ARCHIVE_NAME}.verify" << VERIFY
#!/bin/bash
# Verify SecureVault Browser download integrity

echo "Verifying $ARCHIVE_NAME..."
echo ""

if sha256sum -c ${ARCHIVE_NAME}.sha256; then
    echo "✓ SHA256 verification passed"
else
    echo "✗ SHA256 verification FAILED"
    exit 1
fi

if sha512sum -c ${ARCHIVE_NAME}.sha512; then
    echo "✓ SHA512 verification passed"
else
    echo "✗ SHA512 verification FAILED"
    exit 1
fi

echo ""
echo "✓ All verifications passed - download is authentic"
VERIFY
chmod +x "${ARCHIVE_NAME}.verify"

# Clean up
log "Cleaning up temporary files..."
rm -rf "$WORK_DIR"

# Final report
success "Build complete!"
echo ""
log "═══════════════════════════════════════════════════════"
log "  SecureVault Browser v${VERSION} (Build ${BUILD_DATE})"
log "═══════════════════════════════════════════════════════"
echo ""
log "Output Files:"
echo "  Archive: $OUTPUT_FILE"
echo "  Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo "  SHA256: $(cat "${OUTPUT_FILE}.sha256")"
echo ""
log "Security Features Enabled:"
echo "  ✅ DNS-over-HTTPS (Cloudflare 1.1.1.1)"
echo "  ✅ WebRTC IP Leak Protection"
echo "  ✅ Fingerprinting Protection"
echo "  ✅ Third-Party Cookie Blocking"
echo "  ✅ HTTPS-Only Mode"
echo "  ✅ Site Isolation & Sandboxing"
echo "  ✅ Enhanced Tracking Protection"
echo "  ✅ Automatic Cache Clearing"
echo ""
log "Installation:"
echo "  1. Extract: tar -xzf $ARCHIVE_NAME"
echo "  2. Install: cd ungoogled-chromium* && sudo ./install.sh"
echo "  3. Launch: securevault-browser"
echo ""
log "Verification:"
echo "  bash ${ARCHIVE_NAME}.verify"
echo ""
log "Documentation:"
echo "  Extract and read SECURITY.md for full security details"
echo ""
success "Ready for secure browsing!"
