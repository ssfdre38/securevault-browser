#!/bin/bash
#
# Build RPM package for Fedora/RHEL/Rocky/AlmaLinux
#
set -e

VERSION="6.0.0"
RELEASE="1"
BUILD_DATE=$(date +%Y%m%d)
ARCH="x86_64"
PACKAGE_NAME="securevault-browser"
BUILD_DIR="/tmp/securevault-rpm"

echo "Building RPM package..."

# Install RPM build tools
sudo apt-get install -y rpm

# Create RPM build structure
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Download source if not exists
if [ ! -f /tmp/securevault-build-linux.tar.xz ]; then
    wget -q --show-progress \
        "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.69-1/ungoogled-chromium_131.0.6778.69-1_linux.tar.xz" \
        -O /tmp/securevault-build-linux.tar.xz
fi

# Extract to SOURCES
tar -xf /tmp/securevault-build-linux.tar.xz -C /tmp/
CHROMIUM_SRC=$(find /tmp/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Create source tarball
cd /tmp
tar -czf "$BUILD_DIR/SOURCES/securevault-browser-${VERSION}.tar.gz" "$(basename $CHROMIUM_SRC)"

# Create RPM spec file
cat > "$BUILD_DIR/SPECS/securevault-browser.spec" << 'SPEC'
Name:           securevault-browser
Version:        6.0.0
Release:        1%{?dist}
Summary:        Privacy and security-focused web browser
License:        BSD-3-Clause
URL:            https://barrersoftware.com
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       glibc gtk3 nspr nss libX11 libXcomposite libXdamage libXext libXfixes libXrandr

%description
SecureVault Browser is a privacy-first web browser based on
Ungoogled-Chromium with enhanced security features including:
- DNS-over-HTTPS encryption
- WebRTC leak protection
- Fingerprinting protection
- No telemetry or tracking
- HTTPS-only mode
- Site isolation and sandboxing

%prep
%setup -q -n ungoogled-chromium_131.0.6778.69-1_linux

%build
# No build needed - using pre-built binaries

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/securevault-browser
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/128x128/apps

# Copy all files
cp -r * %{buildroot}/opt/securevault-browser/

# Create launcher script
cat > %{buildroot}/usr/bin/securevault-browser << 'LAUNCHER'
#!/bin/bash
exec /opt/securevault-browser/chrome \
    --disable-background-networking \
    --disable-sync \
    --dns-over-https-mode=secure \
    --dns-over-https-server=https://1.1.1.1/dns-query \
    --enable-features=WebRTCHideLocalIpsWithMdns \
    --https-only-mode \
    --no-pings \
    "$@"
LAUNCHER
chmod +x %{buildroot}/usr/bin/securevault-browser

# Create desktop file
cat > %{buildroot}/usr/share/applications/securevault-browser.desktop << 'DESKTOP'
[Desktop Entry]
Version=1.0
Name=SecureVault Browser
GenericName=Secure Web Browser
Comment=Privacy and security-focused web browser
Exec=securevault-browser %U
Terminal=false
Type=Application
Icon=securevault-browser
Categories=Network;WebBrowser;Security;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
DESKTOP

%files
/opt/securevault-browser/*
/usr/bin/securevault-browser
/usr/share/applications/securevault-browser.desktop

%post
# Update desktop database
if [ -x /usr/bin/update-desktop-database ]; then
    /usr/bin/update-desktop-database -q
fi

%postun
if [ -x /usr/bin/update-desktop-database ]; then
    /usr/bin/update-desktop-database -q
fi

%changelog
* Mon Oct 28 2025 Barrer Software <security@barrersoftware.com> - 6.0.0-1
- Initial RPM release
- Enhanced security features
- DNS-over-HTTPS enabled by default
SPEC

# Build RPM
cd "$BUILD_DIR"
rpmbuild --define "_topdir $BUILD_DIR" -ba SPECS/securevault-browser.spec

# Copy to output
OUTPUT="/mnt/projects/repos/securevault-browser/builds"
mkdir -p "$OUTPUT"
cp RPMS/${ARCH}/${PACKAGE_NAME}-${VERSION}-${RELEASE}.*.${ARCH}.rpm "$OUTPUT/${PACKAGE_NAME}-${VERSION}-${RELEASE}.${ARCH}.rpm" 2>/dev/null || \
cp RPMS/${ARCH}/${PACKAGE_NAME}-${VERSION}-${RELEASE}.${ARCH}.rpm "$OUTPUT/" 2>/dev/null || true

if [ -f "$OUTPUT/${PACKAGE_NAME}-${VERSION}-${RELEASE}.${ARCH}.rpm" ]; then
    echo "✓ RPM package created: ${PACKAGE_NAME}-${VERSION}-${RELEASE}.${ARCH}.rpm"
    
    # Create YUM repo config
    cat > "$OUTPUT/${PACKAGE_NAME}.repo" << YUMREPO
[securevault-browser]
name=SecureVault Browser Repository
baseurl=https://repo.secureos.xyz/rpm/
enabled=1
gpgcheck=0
YUMREPO
    echo "✓ YUM repository configuration created"
else
    echo "⚠ RPM build may have failed - check logs"
fi
