# SecureVault Browser

**Version:** 6.0.0 (Build 20251028)  
**Developer:** Barrer Software  
**Website:** https://barrersoftware.com  
**Support:** security@barrersoftware.com  

## About

SecureVault Browser is a privacy and security-focused web browser developed by Barrer Software. Based on Ungoogled-Chromium, it provides maximum privacy protection with enhanced security features.

## Features

### Privacy Protection
- ✅ **DNS-over-HTTPS** - All DNS queries encrypted via Cloudflare (1.1.1.1)
- ✅ **WebRTC IP Leak Protection** - Hides your real IP address
- ✅ **Fingerprinting Protection** - Blocks canvas/WebGL fingerprinting
- ✅ **Third-Party Cookie Blocking** - Prevents cross-site tracking
- ✅ **Do Not Track** - Sends DNT header to all websites

### Security Hardening
- ✅ **HTTPS-Only Mode** - Automatically upgrades to HTTPS
- ✅ **Site Isolation** - Each site runs in separate process
- ✅ **Process Sandboxing** - Limits damage from exploits
- ✅ **Strict Content Security Policy** - Prevents code injection

### No Tracking
- ✅ **No Google Services** - Completely de-Googled
- ✅ **No Telemetry** - Zero data collection
- ✅ **No Background Networking** - No hidden connections
- ✅ **Automatic Cache Clearing** - Cleans up on exit

## Installation

### Linux
```bash
# Debian/Ubuntu (from repository)
echo "deb https://repo.secureos.xyz noble main security" | sudo tee /etc/apt/sources.list.d/secureos.list
sudo apt update
sudo apt install securevault-browser

# Universal (from tarball)
tar -xzf SecureVault-Browser-6.0.0-build20251028-linux-x64.tar.gz
cd ungoogled-chromium*
sudo ./install.sh
```

### Windows
1. Extract ZIP file
2. Run `SecureVault-Browser.bat`
3. No installation required!

## First Run

When you first launch SecureVault Browser, you'll see a welcome page with:
- Information about Barrer Software
- List of security features enabled
- Links to privacy settings
- Support and documentation

All security features are pre-configured and enabled by default!

## Support

- **Website:** https://barrersoftware.com
- **Email:** security@barrersoftware.com
- **GitHub:** https://github.com/barrersoftware/securevault-browser
- **Documentation:** https://barrersoftware.com/securevault-browser/docs

## License

Based on Ungoogled-Chromium (BSD-3-Clause)  
SecureVault modifications © 2025 Barrer Software

---

**Developed with ❤️ by Barrer Software**  
*Security First, Always*
