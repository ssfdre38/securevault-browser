#!/bin/bash

echo "=================================================="
echo "Launching SecureVault Browser"
echo "=================================================="

# Check if binary exists
if [ ! -f "src/out/SecureVault/chrome" ]; then
    echo "Error: SecureVault Browser not built yet. Run ./build.sh first"
    exit 1
fi

cd src/out/SecureVault

# Launch with privacy-focused flags
./chrome \
    --user-data-dir="$HOME/.config/securevault-browser" \
    --disable-background-networking \
    --disable-breakpad \
    --disable-crash-reporter \
    --disable-sync \
    --disable-translate \
    --disable-domain-reliability \
    --disable-component-update \
    --disable-client-side-phishing-detection \
    --disable-default-apps \
    --no-first-run \
    --no-default-browser-check \
    --no-service-autorun \
    --no-pings \
    --dns-over-https-mode=secure \
    --enable-features=WebRTCHideLocalIpsWithMdns,PartitionedCookies,EnhancedProtectionPromoCard \
    --force-webrtc-ip-handling-policy=default_public_interface_only \
    --disable-features=MediaRouter,OptimizationHints,PrivacySandboxSettings4 \
    "$@"
