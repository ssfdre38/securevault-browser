# SecureVault Browser - Privacy and Security Features Guide

## Overview

SecureVault Browser is a hardened Chromium-based browser designed for maximum privacy and security. This guide details all privacy and security features.

## Privacy Features

### 1. No Telemetry or Phone Home
- **Removed**: All Google telemetry and crash reporting
- **Result**: Zero data sent to Google or any third party
- **Implementation**: Compiled without metrics collection code

### 2. DNS-over-HTTPS (DoH)
- **Status**: Enabled by default
- **Benefit**: Encrypted DNS queries prevent ISP snooping
- **Providers**: Uses privacy-focused DNS providers
- **Configuration**: Can be customized in settings

### 3. WebRTC IP Leak Protection
- **Status**: Enabled by default
- **Protection**: Prevents real IP address leaks
- **Mode**: `default_public_interface_only`
- **Benefit**: Protects VPN/proxy users

### 4. Third-Party Cookie Blocking
- **Status**: Enabled by default
- **Impact**: Blocks cross-site tracking cookies
- **Exception**: User can allow per-site
- **Benefit**: Reduces tracking by advertisers

### 5. No Google Services Integration
- **Removed Services**:
  - Google Sync
  - Google Translate
  - Google Safe Browsing phone-home
  - Cloud Print
  - Hangouts
  - Google Now
- **Benefit**: Complete independence from Google ecosystem

### 6. Fingerprinting Protection
- **Canvas Fingerprinting**: Randomized
- **Font Fingerprinting**: Limited fonts exposed
- **WebGL Fingerprinting**: Restricted data
- **Benefit**: Makes tracking via fingerprinting difficult

### 7. Referrer Policy
- **Default**: Strict referrer policy
- **Benefit**: Doesn't leak browsing history to third parties
- **Mode**: `no-referrer-when-downgrade`

### 8. No Auto-Updates
- **Philosophy**: User-controlled updates
- **Benefit**: No silent background connections
- **Note**: User responsible for staying updated

## Security Features

### 1. Site Isolation
- **Status**: Enabled for all sites
- **Mode**: Strict site isolation
- **Benefit**: Prevents Spectre-style attacks
- **Performance**: Slight memory increase, major security gain

### 2. Enhanced Sandboxing
- **Level**: Maximum sandbox restrictions
- **Benefit**: Contains renderer process exploits
- **Platform**: OS-level sandboxing used

### 3. HTTPS-Only Mode
- **Status**: Automatic HTTPS upgrades
- **Behavior**: Attempts HTTPS before HTTP
- **Warning**: Shows warning for HTTP-only sites
- **Benefit**: Protects against MITM attacks

### 4. Content Security Policy (CSP)
- **Default**: Stricter CSP headers
- **Inline Scripts**: Restricted
- **Eval**: Disabled by default
- **Benefit**: Prevents XSS attacks

### 5. Memory Safety
- **Features**:
  - Bounds checking
  - Stack canaries
  - ASLR enabled
  - DEP enabled
- **Benefit**: Reduces exploit success rate

### 6. No Third-Party Extensions by Default
- **Policy**: Extensions must be manually approved
- **Source**: Only install from trusted sources
- **Benefit**: Prevents malicious extension installation

### 7. Secure Password Storage
- **Encryption**: OS-level credential storage
- **Linux**: libsecret/gnome-keyring
- **Benefit**: Encrypted password storage

## Default Settings

### Search Engine
- **Default**: DuckDuckGo
- **Reason**: Privacy-focused search
- **Customizable**: Yes, user can change

### New Tab Page
- **Content**: Blank page
- **No**: Suggested articles, ads, or tracking
- **Benefit**: No data leakage on new tab

### Location Services
- **Default**: Disabled
- **Permission**: Requires explicit user grant
- **Benefit**: No location tracking

### Notifications
- **Default**: Blocked for all sites
- **Permission**: Requires explicit user grant
- **Benefit**: Reduces fingerprinting and annoyance

### Microphone/Camera
- **Default**: Blocked
- **Permission**: Explicit grant per session
- **Indicator**: Always shows when in use

## Advanced Privacy Settings

### 1. Disable JavaScript (Optional)
```
chrome://settings/content/javascript
```
Disables all JavaScript for maximum privacy.

### 2. Disable Images (Optional)
```
chrome://settings/content/images
```
Faster browsing and reduced tracking.

### 3. Clear Data on Exit
Configure to automatically clear:
- Browsing history
- Cookies
- Cache
- Download history

### 4. Private Mode
Enhanced private mode with:
- No disk cache
- No history
- No cookies persistence
- WebRTC disabled

## Command-Line Flags

SecureVault runs with these privacy flags by default:

```bash
--disable-background-networking
--disable-breakpad
--disable-crash-reporter
--disable-sync
--disable-translate
--disable-domain-reliability
--disable-component-update
--disable-client-side-phishing-detection
--disable-default-apps
--no-first-run
--no-default-browser-check
--no-service-autorun
--no-pings
--dns-over-https-mode=secure
--enable-features=WebRTCHideLocalIpsWithMdns
--force-webrtc-ip-handling-policy=default_public_interface_only
```

## Removed Features

The following Chromium features are completely removed:

1. **Google API Keys**: No Google API access
2. **RLZ Tracking**: Google promotional tracking removed
3. **Google Cloud Messaging**: Push notification service removed
4. **Chrome Web Store**: Extensions must be manually installed
5. **Chrome Sync**: No account sync
6. **Safe Browsing Phone-Home**: Uses local lists only
7. **Usage Statistics**: No UMA/metrics collection
8. **Crash Reporting**: No crash dumps sent

## Network Privacy

### What SecureVault Never Sends:
- Usage statistics
- Crash reports
- Search suggestions (unless explicitly enabled)
- Page prefetching
- DNS prefetching (optional)
- Omnibox predictions
- Safe Browsing data (except local checks)

### Connection Monitoring
All network connections can be monitored in:
```
chrome://net-internals
```

## Recommendations

### For Maximum Privacy:
1. Use VPN or Tor
2. Clear cookies on exit
3. Use private browsing mode
4. Install privacy-focused extensions (uBlock Origin, Privacy Badger)
5. Disable JavaScript for untrusted sites

### For Maximum Security:
1. Keep browser updated
2. Use strong, unique passwords
3. Enable site isolation (default)
4. Don't install untrusted extensions
5. Verify HTTPS on sensitive sites

## Threat Model

### Protected Against:
- Mass surveillance and tracking
- ISP monitoring (with DoH/VPN)
- Advertiser tracking
- Browser fingerprinting
- WebRTC leaks
- Cross-site tracking

### Not Protected Against:
- Nation-state level targeting (use Tor)
- Physical access to computer
- Keyloggers or malware
- Social engineering
- Website-level tracking (login-based)

## Verification

### Verify Privacy Settings:
1. Check DNS: https://dnsleaktest.com
2. Check IP: https://ipleak.net
3. Check WebRTC: https://browserleaks.com/webrtc
4. Check Fingerprint: https://amiunique.org

## Comparison with Other Browsers

### vs. Chrome:
- ✅ No Google tracking
- ✅ No telemetry
- ✅ Privacy by default
- ✅ No Google services

### vs. Brave:
- ✅ Simpler, less bloat
- ✅ No crypto features
- ✅ No BAT tokens
- ⚠️ Brave has built-in ad blocker (SecureVault requires extension)

### vs. Firefox:
- ⚠️ Chromium engine (better compatibility)
- ✅ Simpler privacy settings
- ⚠️ Firefox has more customization

### vs. Tor Browser:
- ⚠️ Not for anonymity (use Tor for that)
- ✅ Faster performance
- ✅ Better compatibility
- ✅ Daily driver suitable

## Building from Source

All privacy features can be verified by inspecting the source code and build configuration. See README.md for build instructions.

## Support

For privacy concerns or questions, review:
1. This documentation
2. Source code in `patches/`
3. Build configuration in `branding/`

## Updates

Check for updates manually:
```bash
cd ~/securevault-browser
git pull
./build.sh
```

## License

SecureVault Browser is open source under the same BSD-style license as Chromium.
