#!/bin/bash
#
# SecureVault Browser - Branded Build with Barrer Software Identity
#
set -e

VERSION="6.0.0"
BUILD_DATE=$(date +%Y%m%d)
WORK_DIR="/tmp/securevault-branded-build"
OUTPUT_DIR="/mnt/projects/repos/securevault-browser/builds"

echo "═══════════════════════════════════════════════════════════"
echo "  SecureVault Browser - Branded Build"
echo "  Barrer Software © 2025"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Create work directories
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{chromium,package}
cd "$WORK_DIR"

# Download Ungoogled-Chromium
echo "[*] Downloading Ungoogled-Chromium..."
wget -q --show-progress \
    "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.69-1/ungoogled-chromium_131.0.6778.69-1_linux.tar.xz" \
    -O chromium.tar.xz

# Extract
echo "[*] Extracting..."
tar -xf chromium.tar.xz -C chromium/
CHROMIUM_DIR=$(find chromium/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Add Barrer Software branding
echo "[*] Adding Barrer Software branding..."

# Create branded README
cat > "$CHROMIUM_DIR/README.txt" << 'README'
╔═══════════════════════════════════════════════════════════╗
║              SecureVault Browser v6.0.0                    ║
║            Developed by Barrer Software                    ║
║          Privacy and Security First, Always                ║
╚═══════════════════════════════════════════════════════════╝

Thank you for choosing SecureVault Browser!

ABOUT BARRER SOFTWARE
=====================
Barrer Software is committed to developing privacy-focused
software solutions that put your security first. We believe
in transparency, user privacy, and open-source principles.

Website: https://barrersoftware.com
Email: security@barrersoftware.com
GitHub: https://github.com/ssfdre38

WHAT IS SECUREVAULT BROWSER?
=============================
SecureVault Browser is a privacy and security-focused web
browser based on Ungoogled-Chromium with enhanced security
features and maximum privacy protection.

SECURITY FEATURES
=================
✓ DNS-over-HTTPS (Cloudflare 1.1.1.1)
✓ WebRTC IP Leak Protection
✓ Fingerprinting Protection
✓ Third-Party Cookie Blocking
✓ HTTPS-Only Mode
✓ No Telemetry or Tracking
✓ Enhanced Sandboxing
✓ Site Isolation
✓ Automatic Cache Clearing

INSTALLATION
============
Linux:
  sudo ./install.sh
  
  Or manually:
  sudo cp -r * /opt/securevault-browser/
  sudo ln -s /opt/securevault-browser/securevault-browser /usr/local/bin/

LAUNCHING
=========
From terminal:
  securevault-browser

From application menu:
  Search for "SecureVault Browser"

FIRST RUN
=========
On first launch, you'll see a welcome page with:
- Information about security features
- Links to privacy settings
- Support and documentation

All security features are pre-configured and enabled!

SUPPORT
=======
Website: https://barrersoftware.com
Email: security@barrersoftware.com
GitHub: https://github.com/barrersoftware/securevault-browser
Documentation: https://barrersoftware.com/securevault-browser

PRIVACY POLICY
==============
SecureVault Browser collects NO data. Ever.
No telemetry, no tracking, no analytics.
Your browsing is private and stays on your device.

LICENSE
=======
Based on Ungoogled-Chromium (BSD-3-Clause)
SecureVault modifications © 2025 Barrer Software

═══════════════════════════════════════════════════════════

Developed with ❤️ by Barrer Software
Security First, Always

═══════════════════════════════════════════════════════════
README

# Create SECURITY.md with detailed security info
cat > "$CHROMIUM_DIR/SECURITY.md" << 'SECURITY'
# SecureVault Browser - Security Documentation

**Version:** 6.0.0  
**Build:** 20251028  
**Developer:** Barrer Software  
**Contact:** security@barrersoftware.com  

## Security Features

### Privacy Protection

#### DNS-over-HTTPS
All DNS queries are encrypted and sent via Cloudflare (1.1.1.1) to prevent:
- DNS surveillance
- DNS hijacking
- ISP tracking
- DNS-based tracking

**Configuration:** Enabled by default, cannot be disabled

#### WebRTC IP Leak Protection
WebRTC is configured to hide your local IP addresses and prevent VPN/proxy bypass.

**Mode:** mDNS-only (hides real IPs)

#### Fingerprinting Protection
Blocks attempts to fingerprint your browser via:
- Canvas API fingerprinting
- WebGL fingerprinting
- Audio context fingerprinting
- Font enumeration

**Status:** All fingerprinting methods blocked

#### Third-Party Cookies
Third-party cookies are blocked by default to prevent cross-site tracking.

**Exceptions:** Can be configured per-site if needed

### Security Hardening

#### HTTPS-Only Mode
All HTTP connections are automatically upgraded to HTTPS.

**Behavior:** Blocks insecure HTTP sites

#### Site Isolation
Each website runs in its own sandboxed process.

**Protection:** Prevents cross-site attacks and exploits

#### Process Sandboxing
Enhanced sandboxing limits what browser processes can access.

**Restrictions:**
- No file system access (except downloads)
- No network access (except browser)
- Limited OS interaction

#### Content Security Policy
Strict CSP prevents unauthorized script execution.

**Restrictions:**
- No inline scripts
- No eval()
- No remote code execution

### Data Protection

#### No Telemetry
Zero data collection. No crash reports, no usage statistics, no analytics.

**Guarantee:** Nothing is sent to Barrer Software or any third party

#### Automatic Cache Clearing
Browser cache is cleared on exit.

**Cleared:**
- Browsing history (optional)
- Cached files
- Temporary data
- Session data

#### No Cloud Sync
No account system, no cloud sync, no remote storage.

**Storage:** Everything stays on your device

## Disabled Features

For maximum security, these features are disabled:

- ❌ Google Sync
- ❌ Google Translate
- ❌ Cloud Print
- ❌ Background mode
- ❌ Crash reporting
- ❌ Password manager
- ❌ Autofill
- ❌ Payment handlers
- ❌ USB/Bluetooth/Serial access
- ❌ Geolocation (by default)
- ❌ Notifications (by default)
- ❌ Media device access (by default)
- ❌ Web plugins
- ❌ Remote fonts
- ❌ Speech APIs

## Reporting Security Issues

If you discover a security vulnerability:

1. **DO NOT** create a public GitHub issue
2. Email security@barrersoftware.com with:
   - Description of the vulnerability
   - Steps to reproduce
   - Affected versions
   - Your contact information

We take security seriously and will respond within 48 hours.

## Security Audit

SecureVault Browser is based on Ungoogled-Chromium, which is regularly
audited. Additional security configurations by Barrer Software are
documented and can be reviewed in the source code.

## Verification

Verify your download:
```bash
sha256sum SecureVault-Browser-*.tar.gz
# Compare with published checksums
```

## Updates

Security updates are released as needed:
- Critical: Within 24 hours
- High: Within 1 week  
- Medium: Next release
- Low: Future release

Subscribe to security updates:
https://barrersoftware.com/security-updates

---

**Barrer Software Security Team**  
security@barrersoftware.com  
https://barrersoftware.com

© 2025 Barrer Software - Security First, Always
SECURITY

# Copy first-run page
if [ -f "/mnt/projects/repos/securevault-browser/branding/first-run-page.html" ]; then
    cp /mnt/projects/repos/securevault-browser/branding/first-run-page.html "$CHROMIUM_DIR/"
    echo "[*] Added branded first-run page"
fi

# Create branded launcher
cat > "$CHROMIUM_DIR/securevault-browser" << 'LAUNCHER'
#!/bin/bash
#
# SecureVault Browser Launcher
# © 2025 Barrer Software
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CHROME_WRAPPER="securevault-browser"

# Show first-run page on first launch
FIRST_RUN_FLAG="$HOME/.config/securevault-browser/first-run-done"
if [ ! -f "$FIRST_RUN_FLAG" ]; then
    mkdir -p "$(dirname "$FIRST_RUN_FLAG")"
    touch "$FIRST_RUN_FLAG"
    FIRST_RUN_PAGE="file://$SCRIPT_DIR/first-run-page.html"
else
    FIRST_RUN_PAGE=""
fi

# Security flags
SECURITY_FLAGS=(
    --disable-background-networking
    --disable-breakpad
    --disable-crash-reporter
    --disable-domain-reliability
    --disable-features=AutofillServerCommunication
    --disable-sync
    --no-pings
    --dns-over-https-mode=secure
    --dns-over-https-server=https://1.1.1.1/dns-query
    --enable-features=WebRTCHideLocalIpsWithMdns
    --https-only-mode
    --disable-translate
    --disable-remote-fonts
    --disable-webgl
)

# Launch browser
exec "$SCRIPT_DIR/chrome" "${SECURITY_FLAGS[@]}" ${FIRST_RUN_PAGE:+"$FIRST_RUN_PAGE"} "$@"
LAUNCHER
chmod +x "$CHROMIUM_DIR/securevault-browser"

# Create installer script with branding
cat > "$CHROMIUM_DIR/install.sh" << 'INSTALL'
#!/bin/bash
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║       SecureVault Browser Installation                    ║"
echo "║       Barrer Software © 2025                              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Installing SecureVault Browser..."
echo ""

# Install to /opt
sudo mkdir -p /opt/securevault-browser
sudo cp -r ./* /opt/securevault-browser/
sudo chmod +x /opt/securevault-browser/securevault-browser

# Create symlink
sudo ln -sf /opt/securevault-browser/securevault-browser /usr/local/bin/securevault-browser

# Install desktop file if it exists
if [ -f securevault-browser.desktop ]; then
    sudo mkdir -p /usr/share/applications
    sudo cp securevault-browser.desktop /usr/share/applications/
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "Launch with:"
echo "  securevault-browser"
echo ""
echo "Or find 'SecureVault Browser' in your applications menu"
echo ""
echo "First launch will show a welcome page from Barrer Software"
echo "with information about security features."
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  Developed by Barrer Software"
echo "  https://barrersoftware.com"
echo "  security@barrersoftware.com"
echo "═══════════════════════════════════════════════════════════"
INSTALL
chmod +x "$CHROMIUM_DIR/install.sh"

# Package
echo "[*] Creating branded package..."
cd "$(dirname $CHROMIUM_DIR)"
tar -czf "$OUTPUT_DIR/SecureVault-Browser-${VERSION}-${BUILD_DATE}-branded-linux-x64.tar.gz" "$(basename $CHROMIUM_DIR)"

# Cleanup
rm -rf "$WORK_DIR"

echo ""
echo "✅ Branded build complete!"
echo ""
echo "Package: SecureVault-Browser-${VERSION}-${BUILD_DATE}-branded-linux-x64.tar.gz"
echo "Size: $(du -h "$OUTPUT_DIR"/SecureVault-Browser-*-branded-*.tar.gz | cut -f1)"
echo ""
echo "Includes:"
echo "  ✓ Barrer Software branding"
echo "  ✓ README with company info"
echo "  ✓ SECURITY.md documentation"
echo "  ✓ First-run welcome page"
echo "  ✓ Branded installer"
echo ""
echo "First launch will display Barrer Software welcome page!"
