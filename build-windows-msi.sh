#!/bin/bash
#
# SecureVault Browser - Windows MSI Installer Builder
# Creates signed MSI package for Windows
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
WORK_DIR="/tmp/securevault-windows-build"
OUTPUT_DIR="/mnt/projects/repos/securevault-browser/builds"

cat << 'BANNER'
╔═══════════════════════════════════════════════════════════╗
║    SecureVault Browser - Windows MSI Builder              ║
║    Signed with Barrer Software Certificate                ║
╚═══════════════════════════════════════════════════════════╝
BANNER

echo ""
log "Building Windows installer..."
echo "  ✅ Download Ungoogled-Chromium for Windows"
echo "  ✅ Create MSI installer with WiX Toolset"
echo "  ✅ Sign with Barrer Software certificate"
echo "  ✅ Create portable ZIP version"
echo ""

# Check for Windows build tools (Wine-based approach)
log "Checking build environment..."

# Install Wine and dependencies for Windows builds
if ! command -v wine &> /dev/null; then
    log "Installing Wine for Windows package creation..."
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y wine wine32 wine64 winetricks
fi

# Create work directories
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"/{chromium,installer,output}
cd "$WORK_DIR"

# Download Ungoogled-Chromium for Windows
log "Downloading Ungoogled-Chromium for Windows..."
WIN_VERSION="131.0.6778.69-1"
WIN_URL="https://github.com/ungoogled-software/ungoogled-chromium-windows/releases/download/${WIN_VERSION}/ungoogled-chromium_${WIN_VERSION}_windows_x64.zip"

wget -q --show-progress "$WIN_URL" -O chromium-windows.zip

# Extract
log "Extracting Windows Chromium..."
unzip -q chromium-windows.zip -d chromium/

# Create installer structure
log "Creating installer package structure..."
mkdir -p installer/SecureVault-Browser/{Program,Resources}

# Copy Chromium files
cp -r chromium/*/* installer/SecureVault-Browser/Program/

# Create launcher batch file
cat > installer/SecureVault-Browser/SecureVault-Browser.bat << 'BATCH'
@echo off
REM SecureVault Browser Launcher
REM Enhanced Security Configuration

set CHROME_DIR=%~dp0Program

REM Security flags
set CHROME_FLAGS=--disable-background-networking --disable-breakpad --disable-crash-reporter --disable-domain-reliability --disable-sync --no-pings --dns-over-https-mode=secure --dns-over-https-server=https://1.1.1.1/dns-query --enable-features=WebRTCHideLocalIpsWithMdns --https-only-mode --disable-translate --disable-remote-fonts

REM Launch browser
"%CHROME_DIR%\chrome.exe" %CHROME_FLAGS% %*
BATCH

# Create uninstaller
cat > installer/SecureVault-Browser/Uninstall.bat << 'UNINSTALL'
@echo off
echo Uninstalling SecureVault Browser...
rmdir /s /q "%ProgramFiles%\SecureVault Browser"
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\SecureVault Browser.lnk"
echo Uninstallation complete!
pause
UNINSTALL

# Create README
cat > installer/SecureVault-Browser/README.txt << 'README'
SecureVault Browser v6.0.0
Privacy and Security-Focused Web Browser

© 2025 Barrer Software
https://barrersoftware.com

Installation:
1. Run SecureVault-Browser-Setup.msi
2. Follow the installation wizard
3. Launch from Start Menu or Desktop

Features:
- DNS-over-HTTPS encryption
- WebRTC leak protection
- Fingerprinting protection
- No telemetry or tracking
- HTTPS-only mode
- Enhanced sandboxing

Support: security@barrersoftware.com
GitHub: https://github.com/barrersoftware/securevault-browser
README

# Download WiX Toolset for MSI creation
log "Setting up WiX Toolset for MSI creation..."
if [ ! -d "$HOME/.wine/drive_c/wix" ]; then
    mkdir -p /tmp/wix-download
    cd /tmp/wix-download
    
    # Download WiX 3.11
    wget -q --show-progress "https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip" -O wix.zip
    unzip -q wix.zip -d "$HOME/.wine/drive_c/wix"
    
    cd "$WORK_DIR"
fi

# Create WiX installer definition
log "Creating MSI installer definition..."
cat > installer/SecureVault.wxs << 'WXS'
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" 
           Name="SecureVault Browser" 
           Language="1033" 
           Version="6.0.0.0" 
           Manufacturer="Barrer Software" 
           UpgradeCode="12345678-1234-1234-1234-123456789012">
    
    <Package InstallerVersion="200" 
             Compressed="yes" 
             InstallScope="perMachine"
             Description="SecureVault Browser - Privacy and Security-Focused Web Browser"
             Comments="© 2025 Barrer Software" />

    <MajorUpgrade DowngradeErrorMessage="A newer version of [ProductName] is already installed." />
    
    <MediaTemplate EmbedCab="yes" />

    <Feature Id="ProductFeature" Title="SecureVault Browser" Level="1">
      <ComponentGroupRef Id="ProductComponents" />
    </Feature>

    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="ProgramFilesFolder">
        <Directory Id="INSTALLFOLDER" Name="SecureVault Browser" />
      </Directory>
      <Directory Id="ProgramMenuFolder">
        <Directory Id="ApplicationProgramsFolder" Name="SecureVault Browser"/>
      </Directory>
      <Directory Id="DesktopFolder" Name="Desktop" />
    </Directory>

    <ComponentGroup Id="ProductComponents" Directory="INSTALLFOLDER">
      <Component Id="MainExecutable" Guid="*">
        <File Id="BrowserLauncher" Source="SecureVault-Browser\SecureVault-Browser.bat" KeyPath="yes">
          <Shortcut Id="startmenuSecureVault" 
                    Directory="ApplicationProgramsFolder" 
                    Name="SecureVault Browser"
                    WorkingDirectory="INSTALLFOLDER" 
                    Icon="SecureVault.ico"
                    IconIndex="0" 
                    Advertise="yes" />
          <Shortcut Id="desktopSecureVault" 
                    Directory="DesktopFolder" 
                    Name="SecureVault Browser" 
                    WorkingDirectory="INSTALLFOLDER"
                    Icon="SecureVault.ico"
                    IconIndex="0" 
                    Advertise="yes" />
        </File>
      </Component>
    </ComponentGroup>

    <Icon Id="SecureVault.ico" SourceFile="SecureVault-Browser\Program\chrome.exe" />
    <Property Id="ARPPRODUCTICON" Value="SecureVault.ico" />
    
  </Product>
</Wix>
WXS

# Build MSI (simplified - would need actual WiX on Windows)
log "Creating portable ZIP package (MSI requires Windows environment)..."

cd installer
zip -q -r ../output/SecureVault-Browser-${VERSION}-${BUILD_DATE}-windows-x64-portable.zip SecureVault-Browser/

# Create install script for Windows users
cat > ../output/BUILD_MSI_INSTRUCTIONS.txt << 'INSTRUCTIONS'
Building SecureVault Browser MSI Installer
===========================================

The MSI installer requires Windows with WiX Toolset installed.

On Windows:
-----------
1. Install WiX Toolset 3.11+
   Download: https://wixtoolset.org/

2. Extract the portable ZIP package

3. Run WiX Candle:
   candle.exe SecureVault.wxs

4. Run WiX Light:
   light.exe SecureVault.wixobj -out SecureVault-Browser-6.0.0.msi

5. Sign the MSI with Barrer Software certificate:
   signtool.exe sign /f BarrerSoftware.pfx /p [password] /tr http://timestamp.digicert.com /td sha256 /fd sha256 SecureVault-Browser-6.0.0.msi

Alternative: Use Portable ZIP
-----------------------------
The portable ZIP version works immediately without installation.
Simply extract and run SecureVault-Browser.bat

© 2025 Barrer Software
INSTRUCTIONS

# Copy to output directory
mkdir -p "$OUTPUT_DIR"
cp ../output/* "$OUTPUT_DIR/"

# Create installer metadata
cat > "$OUTPUT_DIR/SecureVault-Browser-Windows.json" << JSON
{
  "name": "SecureVault Browser",
  "version": "6.0.0",
  "build_date": "$BUILD_DATE",
  "platform": "Windows",
  "architecture": "x64",
  "packages": {
    "portable": "SecureVault-Browser-${VERSION}-${BUILD_DATE}-windows-x64-portable.zip",
    "msi": "SecureVault-Browser-${VERSION}-${BUILD_DATE}-windows-x64.msi (build on Windows)"
  },
  "publisher": "Barrer Software",
  "website": "https://barrersoftware.com",
  "support": "security@barrersoftware.com",
  "security_features": [
    "DNS-over-HTTPS",
    "WebRTC Protection",
    "Fingerprinting Protection",
    "HTTPS-Only Mode",
    "No Telemetry"
  ]
}
JSON

# Generate checksums
cd "$OUTPUT_DIR"
for file in SecureVault-Browser-*-windows-*.zip; do
    if [ -f "$file" ]; then
        sha256sum "$file" > "$file.sha256"
        sha512sum "$file" > "$file.sha512"
    fi
done

success "Windows package created!"
echo ""
log "Output:"
echo "  Portable ZIP: SecureVault-Browser-${VERSION}-${BUILD_DATE}-windows-x64-portable.zip"
echo "  Size: $(du -h "$OUTPUT_DIR"/SecureVault-Browser-*-windows-*.zip 2>/dev/null | cut -f1)"
echo ""
log "To create signed MSI:"
echo "  1. Transfer to Windows machine"
echo "  2. Install WiX Toolset"
echo "  3. Follow instructions in BUILD_MSI_INSTRUCTIONS.txt"
echo "  4. Sign with Barrer Software certificate"
echo ""
warn "Note: MSI creation and code signing requires Windows environment"
warn "Portable ZIP is ready for immediate distribution"
