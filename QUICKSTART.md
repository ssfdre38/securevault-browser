# SecureVault Browser - Quick Start Guide

## What is SecureVault Browser?

SecureVault Browser is a privacy and security-focused web browser based on Chromium. It removes all Google tracking, telemetry, and services while adding enhanced privacy protections.

## Key Features

✅ **Zero Telemetry** - No data sent to Google or anyone else
✅ **DNS-over-HTTPS** - Encrypted DNS queries by default  
✅ **WebRTC Protection** - Prevents IP leaks
✅ **No Third-Party Cookies** - Blocks cross-site tracking
✅ **Enhanced Security** - Site isolation, sandboxing, HTTPS-only
✅ **No Google Services** - Completely de-Googled
✅ **Privacy by Default** - All privacy features enabled out of the box
✅ **Open Source** - Fully auditable codebase

## Quick Start

### 1. Setup (One-Time)

```bash
cd ~/securevault-browser
./setup.sh
```

⏱️ Takes 30-60 minutes (downloads Chromium source)

### 2. Build

```bash
./build.sh
```

⏱️ Takes 1-3 hours (first build)

### 3. Run

```bash
./run.sh
```

🎉 SecureVault Browser launches!

## What Makes It Different?

### vs. Chrome
- ❌ No Google tracking or telemetry
- ❌ No Google services (sync, translate, etc.)
- ✅ Privacy features enabled by default
- ✅ Full control over your data

### vs. Brave
- ✅ Simpler, no crypto/token features
- ✅ No controversial business model
- ✅ Pure privacy focus

### vs. Firefox  
- ✅ Chromium engine (better site compatibility)
- ✅ Simpler privacy configuration
- ✅ Enhanced security features

### vs. Tor Browser
- ✅ Better performance (not for anonymity)
- ✅ Daily driver suitable
- ⚠️ Not for high-threat models (use Tor for that)

## Project Structure

```
securevault-browser/
├── README.md              # Project overview
├── setup.sh               # Initial setup script
├── build.sh               # Build script
├── run.sh                 # Launch browser
├── branding/              # Custom branding
│   └── securevault.gni    # Configuration
├── patches/               # Privacy/security patches
│   └── 001-disable-tracking.patch
├── icons/                 # Application icons
│   ├── securevault-icon.svg
│   └── securevault-icon-64.svg
├── docs/                  # Documentation
│   ├── PRIVACY.md         # Privacy features guide
│   ├── BUILD.md           # Build instructions
│   └── CONFIGURATION.md   # Configuration guide
└── src/                   # Chromium source (after setup)
```

## Requirements

### Minimum
- **Disk**: 100GB free space
- **RAM**: 16GB
- **CPU**: Multi-core processor
- **OS**: Linux (Ubuntu 20.04+)

### Recommended
- **Disk**: 200GB SSD
- **RAM**: 32GB
- **CPU**: 8+ cores
- **OS**: Ubuntu 22.04 LTS

## Documentation

- **[PRIVACY.md](docs/PRIVACY.md)** - Privacy features and protections
- **[BUILD.md](docs/BUILD.md)** - Detailed build instructions
- **[CONFIGURATION.md](docs/CONFIGURATION.md)** - Configuration guide

## Privacy Features

### Removed from Chromium:
- Google API keys
- Crash reporting
- Usage statistics
- RLZ tracking
- Google URL tracking
- Cloud sync
- Translation services
- Safe Browsing phone-home

### Added/Enhanced:
- DNS-over-HTTPS by default
- WebRTC IP leak protection
- Third-party cookie blocking
- Fingerprinting protection
- Strict referrer policies
- Site isolation for all sites
- HTTPS-only mode
- Enhanced sandboxing

## Security Features

1. **Site Isolation** - Prevents cross-site attacks
2. **Sandboxing** - Contains renderer exploits  
3. **HTTPS-Only** - Automatic secure connections
4. **CSP Hardening** - Prevents XSS attacks
5. **Memory Safety** - Bounds checking and ASLR
6. **Secure Storage** - Encrypted credential storage

## Default Settings

- Search: DuckDuckGo
- New Tab: Blank page
- Third-Party Cookies: Blocked
- DNS: Encrypted (DoH)
- WebRTC: IP hidden
- JavaScript: Enabled (can disable)
- Auto-updates: Disabled (user controlled)

## Recommended Extensions

1. **uBlock Origin** - Ad/tracker blocking
2. **Privacy Badger** - Intelligent tracker blocking
3. **Decentraleyes** - CDN tracking protection
4. **ClearURLs** - Remove tracking parameters

Install manually (Chrome Web Store removed for privacy).

## Use Cases

### ✅ Perfect For:
- Privacy-conscious daily browsing
- Avoiding corporate tracking
- Secure web development
- General browsing without surveillance
- Banking and sensitive transactions

### ⚠️ Not Ideal For:
- High-threat anonymity (use Tor Browser)
- Sites requiring Google accounts
- If you need Chrome sync

## Building Process

### What Happens:

1. **Setup Phase** (30-60 min)
   - Downloads depot_tools
   - Installs dependencies
   - Fetches Chromium source (~20GB)
   - Applies SecureVault patches

2. **Build Phase** (1-3 hours)
   - Configures with privacy settings
   - Compiles browser binary
   - Generates ~200MB output

3. **Run Phase** (instant)
   - Launches with privacy flags
   - Uses secure user data directory

### Incremental Builds:
After first build, changes compile in 5-20 minutes.

## Command Line Usage

### Basic Launch
```bash
./run.sh
```

### Open Specific URL
```bash
./run.sh https://duckduckgo.com
```

### With Tor Proxy
```bash
./run.sh --proxy-server="socks5://127.0.0.1:9050"
```

### Without GPU
```bash
./run.sh --disable-gpu
```

## Updating

### Check for Updates
```bash
cd ~/securevault-browser/src
git fetch origin
git log HEAD..origin/main
```

### Update and Rebuild
```bash
cd ~/securevault-browser
git pull
./setup.sh
./build.sh
```

## Verification

Test your privacy after installing:

1. **DNS Leak Test**: https://dnsleaktest.com
2. **WebRTC Leak**: https://browserleaks.com/webrtc  
3. **Fingerprint**: https://amiunique.org
4. **IP Check**: https://ipleak.net

## Common Issues

### Build Fails with Memory Error
```bash
# Limit parallel jobs
cd src
ninja -C out/SecureVault -j4 chrome
```

### Missing Dependencies (Linux)
```bash
cd src
./build/install-build-deps.sh --no-prompt
```

### Can't Launch - Missing Libraries
```bash
sudo apt-get install -f
ldd src/out/SecureVault/chrome
```

## Support

1. Check documentation in `docs/`
2. Review Chromium build documentation
3. Inspect source code and patches
4. Test in safe environment first

## Contributing

To contribute:
1. Make changes to patches or branding
2. Test thoroughly  
3. Document changes
4. Submit with detailed description

## License

SecureVault Browser follows Chromium's BSD-style license. See Chromium source for full license details.

## Philosophy

**Privacy by Default**: All privacy features enabled out of the box, not buried in settings.

**No Phone Home**: Zero network requests to Google or tracking services.

**User Control**: You decide when to update, what to enable, and what data to share (none by default).

**Open Source**: Everything is auditable. Trust through transparency.

## Credits

Built on the Chromium open-source project. Enhanced with privacy and security features by Barrer Software.

**Website**: https://barrersoftware.com

## Disclaimer

SecureVault Browser provides strong privacy protections for normal web browsing. For high-threat models or anonymity requirements, use Tor Browser. Always use VPN/Tor for additional protection.

---

## Quick Reference

| Task | Command |
|------|---------|
| Setup | `./setup.sh` |
| Build | `./build.sh` |
| Run | `./run.sh` |
| Update | `git pull && ./build.sh` |
| Clean | `rm -rf src/out/` |

## Next Steps

1. ✅ Run `./setup.sh` to download Chromium
2. ⏳ Wait 30-60 minutes for setup
3. ✅ Run `./build.sh` to compile  
4. ⏳ Wait 1-3 hours for build
5. ✅ Run `./run.sh` to launch
6. 🎉 Enjoy privacy-focused browsing!

---

**SecureVault Browser** - Privacy is not a feature, it's a fundamental right.
