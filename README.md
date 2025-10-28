# SecureVault Browser

A privacy and security-focused web browser built on Chromium with enhanced protection features.

## Features

### Privacy Enhancements
- **No Telemetry**: All Google telemetry and tracking removed
- **No Safe Browsing Phone Home**: Uses local lists only
- **DNS-over-HTTPS by Default**: Encrypted DNS queries
- **WebRTC IP Leak Protection**: Prevents IP address leaks
- **Enhanced Tracking Protection**: Blocks third-party cookies by default
- **Fingerprinting Protection**: Randomizes browser fingerprints
- **No Google Services**: Completely de-Googled experience

### Security Features
- **Automatic HTTPS**: Upgrades all connections to HTTPS when possible
- **Site Isolation**: Enhanced site isolation enabled by default
- **Sandboxing**: Strong process sandboxing
- **No Third-Party Extensions by Default**: Only user-approved extensions
- **Enhanced CSP**: Stricter Content Security Policies
- **Memory Safety**: Additional bounds checking and hardening

### Additional Features
- **Built-in Ad Blocker**: Fast, efficient ad blocking
- **Private Mode by Default**: Enhanced private browsing
- **No Auto-Updates**: User-controlled updates only
- **Open Source**: Fully auditable codebase

## Build Requirements

### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y git python3 python3-pip curl lsb-release sudo
```

### System Requirements
- **Disk Space**: 100GB+ free
- **RAM**: 16GB+ recommended
- **CPU**: Multi-core processor recommended
- **OS**: Linux (Ubuntu 20.04+), macOS, or Windows

## Quick Start

### 1. Clone and Setup
```bash
cd ~/securevault-browser
./setup.sh
```

### 2. Build
```bash
./build.sh
```

### 3. Run
```bash
./run.sh
```

## Directory Structure

```
securevault-browser/
├── branding/          # Custom branding files
├── patches/           # Chromium patches for privacy/security
├── icons/             # Application icons
├── docs/              # Documentation
├── chromium/          # Chromium source (created during setup)
├── setup.sh           # Initial setup script
├── build.sh           # Build script
└── run.sh             # Run script
```

## Configuration

Edit `branding/securevault.gni` to customize:
- Browser name and version
- Default settings
- Feature flags
- Privacy settings

## Privacy Settings

The following privacy features are enabled by default:

1. **No Google API Keys**: No Google services integration
2. **No Crash Reporting**: No crash reports sent anywhere
3. **No Usage Statistics**: No usage data collected
4. **No RLZ Tracking**: Google RLZ tracking removed
5. **No Google URL Tracking**: All Google tracking URLs removed
6. **No Cloud Sync**: No data sync with Google servers
7. **WebRTC Leak Prevention**: IP addresses protected
8. **Canvas Fingerprinting Protection**: Randomized canvas data

## Security Settings

Enhanced security settings:

1. **Site Isolation**: Enabled for all sites
2. **Strict Site Isolation**: Maximum security mode
3. **Enhanced Sandboxing**: Additional sandbox layers
4. **HTTPS-Only Mode**: Automatic HTTPS upgrades
5. **DNS-over-HTTPS**: Encrypted DNS by default
6. **Third-Party Cookie Blocking**: Enabled by default
7. **Referrer Policy**: Strict referrer policies

## Contributing

This is a privacy-focused browser. All contributions should maintain or enhance privacy and security.

## License

Follows Chromium's BSD-style license. See LICENSE file for details.

## Credits

Built on the Chromium open-source project.
Privacy enhancements and security hardening by the SecureVault Browser team.

## Support

For issues and questions, see the docs/ directory or open an issue on the project repository.
