#!/bin/bash
set -e

VERSION="6.0.0"
RELEASE="1"
BUILD_DIR="/tmp/securevault-rpm-branded"

echo "[*] Building branded RPM package..."

sudo apt-get install -y rpm >/dev/null 2>&1

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Download if needed
if [ ! -f /tmp/securevault-build-linux.tar.xz ]; then
    wget -q --show-progress \
        "https://github.com/ungoogled-software/ungoogled-chromium-portablelinux/releases/download/131.0.6778.69-1/ungoogled-chromium_131.0.6778.69-1_linux.tar.xz" \
        -O /tmp/securevault-build-linux.tar.xz
fi

# Extract
tar -xf /tmp/securevault-build-linux.tar.xz -C /tmp/
CHROMIUM_SRC=$(find /tmp/ -maxdepth 1 -type d -name "ungoogled-chromium*" | head -1)

# Add branding files
if [ -f "branding/first-run-page.html" ]; then
    cp branding/first-run-page.html "$CHROMIUM_SRC/"
fi

cat > "$CHROMIUM_SRC/README.txt" << 'README'
SecureVault Browser v6.0.0
Developed by Barrer Software
https://barrersoftware.com

Privacy and Security First, Always

© 2025 Barrer Software. All rights reserved.
README

# Create source tarball
cd /tmp
tar -czf "$BUILD_DIR/SOURCES/securevault-browser-${VERSION}.tar.gz" "$(basename $CHROMIUM_SRC)"

# RPM spec
cat > "$BUILD_DIR/SPECS/securevault-browser.spec" << 'SPEC'
Name:           securevault-browser
Version:        6.0.0
Release:        1%{?dist}
Summary:        Privacy and security-focused web browser by Barrer Software
License:        BSD-3-Clause
URL:            https://barrersoftware.com
Source0:        %{name}-%{version}.tar.gz
BuildArch:      x86_64
Requires:       glibc gtk3 nspr nss

%description
SecureVault Browser - developed by Barrer Software
Privacy and security-focused web browser with enhanced protection.

%prep
%setup -q -n ungoogled-chromium_131.0.6778.69-1_linux

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/opt/securevault-browser
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/share/applications

cp -r * %{buildroot}/opt/securevault-browser/

cat > %{buildroot}/usr/bin/securevault-browser << 'LAUNCHER'
#!/bin/bash
FIRST_RUN_FLAG="$HOME/.config/securevault-browser/first-run-done"
if [ ! -f "$FIRST_RUN_FLAG" ]; then
    mkdir -p "$(dirname "$FIRST_RUN_FLAG")"
    touch "$FIRST_RUN_FLAG"
    FIRST_RUN_PAGE="file:///opt/securevault-browser/first-run-page.html"
else
    FIRST_RUN_PAGE=""
fi
exec /opt/securevault-browser/chrome \
    --disable-background-networking \
    --disable-sync \
    --dns-over-https-mode=secure \
    --dns-over-https-server=https://1.1.1.1/dns-query \
    --enable-features=WebRTCHideLocalIpsWithMdns \
    --https-only-mode \
    --no-pings \
    ${FIRST_RUN_PAGE:+"$FIRST_RUN_PAGE"} "$@"
LAUNCHER
chmod +x %{buildroot}/usr/bin/securevault-browser

cat > %{buildroot}/usr/share/applications/securevault-browser.desktop << 'DESKTOP'
[Desktop Entry]
Name=SecureVault Browser
Comment=Privacy browser by Barrer Software
Exec=securevault-browser %U
Icon=securevault-browser
Type=Application
Categories=Network;WebBrowser;
DESKTOP

%files
/opt/securevault-browser/*
/usr/bin/securevault-browser
/usr/share/applications/securevault-browser.desktop

%changelog
* Mon Oct 28 2024 Barrer Software <security@barrersoftware.com> - 6.0.0-1
- Initial release with Barrer Software branding
SPEC

# Build
rpmbuild --define "_topdir $BUILD_DIR" -ba "$BUILD_DIR/SPECS/securevault-browser.spec" 2>&1 | tail -20

# Copy output
cp "$BUILD_DIR/RPMS/x86_64/securevault-browser-${VERSION}-${RELEASE}.x86_64.rpm" \
   "builds/securevault-browser-${VERSION}-${RELEASE}.x86_64.rpm" 2>/dev/null || true

echo "✅ Branded RPM package created"
ls -lh "builds/securevault-browser-${VERSION}-${RELEASE}.x86_64.rpm" 2>/dev/null
