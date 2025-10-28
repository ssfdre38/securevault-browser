# SecureVault Browser Configuration Guide

## User Configuration

### Settings Location

- **Linux**: `~/.config/securevault-browser/`
- **macOS**: `~/Library/Application Support/SecureVault Browser/`
- **Windows**: `%LOCALAPPDATA%\SecureVault Browser\`

## Privacy Settings

### DNS-over-HTTPS Configuration

Default providers (in order of priority):
1. Cloudflare: `https://cloudflare-dns.com/dns-query`
2. Quad9: `https://dns.quad9.net/dns-query`

To change:
```
chrome://settings/security
→ Use secure DNS
→ Custom provider
```

### Cookie Settings

Default: Block third-party cookies

To customize:
```
chrome://settings/cookies
```

Options:
- Block all cookies
- Block third-party
- Allow all (not recommended)

### Site Isolation

Default: Enabled for all sites

To verify:
```
chrome://process-internals
```

### WebRTC Settings

Default: Hide local IP

To change:
```
chrome://flags/#webrtc-ip-handling-policy
```

## Search Engine Configuration

### Default Search Engines

SecureVault includes privacy-focused search engines:

1. **DuckDuckGo** (Default)
   - URL: `https://duckduckgo.com/?q=%s`
   - Privacy: Excellent
   - Results: Good

2. **Startpage**
   - URL: `https://www.startpage.com/do/search?q=%s`
   - Privacy: Excellent
   - Results: Google results, anonymized

3. **Brave Search**
   - URL: `https://search.brave.com/search?q=%s`
   - Privacy: Excellent
   - Results: Independent index

4. **Qwant**
   - URL: `https://www.qwant.com/?q=%s`
   - Privacy: Excellent
   - Results: European focus

To add custom search:
```
chrome://settings/searchEngines
```

## Extension Management

### Recommended Privacy Extensions

1. **uBlock Origin**
   - Purpose: Ad/tracker blocking
   - Install: Manual from GitHub releases
   - Config: Default settings are good

2. **Privacy Badger**
   - Purpose: Tracker learning/blocking
   - Install: Manual from EFF
   - Config: Automatic learning

3. **HTTPS Everywhere**
   - Purpose: Force HTTPS
   - Note: Built into SecureVault, extension optional

4. **Decentraleyes**
   - Purpose: Block CDN tracking
   - Install: Manual
   - Config: Default

5. **ClearURLs**
   - Purpose: Remove tracking parameters
   - Install: Manual
   - Config: Default

### Installing Extensions

Since Chrome Web Store is removed:

```bash
# Download .crx file
# Then drag and drop into chrome://extensions/
# Or use developer mode to load unpacked
```

## Content Settings

### JavaScript

Default: Enabled

To block by default:
```
chrome://settings/content/javascript
→ Don't allow sites to use JavaScript
```

Add exceptions for trusted sites.

### Location

Default: Ask before accessing

To block completely:
```
chrome://settings/content/location
→ Don't allow sites to see your location
```

### Camera & Microphone

Default: Ask before accessing

Recommended: Block by default
```
chrome://settings/content/camera
chrome://settings/content/microphone
```

### Notifications

Default: Blocked

To allow for specific sites:
```
chrome://settings/content/notifications
```

### Popups

Default: Blocked

Configuration:
```
chrome://settings/content/popups
```

## Advanced Configuration

### Flags (chrome://flags)

Recommended privacy flags:

```
#enable-parallel-downloading
Enabled - Faster downloads

#smooth-scrolling
Enabled - Better UX

#enable-quic
Disabled - Potential fingerprinting

#dns-over-https
Enabled - Secure DNS (default)

#reduce-user-agent-minor-version
Enabled - Reduced fingerprinting
```

### Command Line Flags

Edit `run.sh` to add more flags:

```bash
# Disable features
--disable-features=AudioServiceOutOfProcess,IsolateOrigins

# Enable features
--enable-features=VaapiVideoDecoder

# Network settings
--host-resolver-rules="MAP * ~NOTFOUND"

# Proxy
--proxy-server="socks5://127.0.0.1:9050"
```

## Profile Management

### Multiple Profiles

Create separate profiles:
```bash
./run.sh --user-data-dir="~/.config/securevault-profile2"
```

Use cases:
- Work vs Personal
- Different privacy levels
- Testing

### Profile Isolation

Each profile has separate:
- Cookies
- Extensions
- History
- Settings

## Sync Alternative

Since Chrome Sync is removed, use:

### Manual Sync
- Export/import bookmarks
- Copy profile directory

### Third-Party Sync
- Firefox Sync (with manual bookmark conversion)
- Syncthing (sync profile directory)
- Git (for bookmarks file)

## Bookmarks Management

Location: `~/.config/securevault-browser/Default/Bookmarks`

Backup:
```bash
cp ~/.config/securevault-browser/Default/Bookmarks ~/bookmarks-backup.json
```

Restore:
```bash
cp ~/bookmarks-backup.json ~/.config/securevault-browser/Default/Bookmarks
```

## Password Manager Configuration

SecureVault uses OS credential storage:

### Linux (libsecret)
```bash
sudo apt-get install libsecret-1-0
```

### KeePassXC Integration

For external password manager:
```bash
# Install KeePassXC browser extension
# Configure native messaging
```

## Clear Browsing Data

### On Exit (Automatic)

```
chrome://settings/clearBrowserData
→ Advanced
→ Choose items
→ Time range: All time
```

### Keyboard Shortcut

`Ctrl+Shift+Del` - Opens clear data dialog

## Network Configuration

### Proxy Settings

```
chrome://settings/
→ System
→ Open proxy settings
```

Or command line:
```bash
./run.sh --proxy-server="127.0.0.1:8080"
```

### Tor Integration

```bash
# Run Tor
sudo systemctl start tor

# Launch with Tor proxy
./run.sh --proxy-server="socks5://127.0.0.1:9050"
```

### VPN

SecureVault respects system VPN settings automatically.

## Performance Tuning

### Hardware Acceleration

Default: Enabled

To disable (privacy over performance):
```
chrome://settings/
→ Advanced
→ System
→ Use hardware acceleration when available: OFF
```

### Preloading

Default: Disabled

To enable (performance over privacy):
```
chrome://settings/
→ Privacy and security
→ Preload pages: ON
```

### Memory Management

Reduce memory usage:
```
chrome://flags/#tab-freezing
Enabled
```

## Appearance Customization

### Themes

Install custom themes:
1. Download theme
2. Drag to `chrome://extensions/`

### Dark Mode

```
chrome://settings/appearance
→ Theme: Dark
```

Or force:
```bash
./run.sh --force-dark-mode
```

## Update Configuration

Since auto-update is disabled:

### Manual Update Check

```bash
cd ~/securevault-browser/src
git fetch origin
git log HEAD..origin/main
```

### Update Process

```bash
cd ~/securevault-browser
git pull
./setup.sh
./build.sh
```

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New tab | Ctrl+T |
| New window | Ctrl+N |
| New incognito | Ctrl+Shift+N |
| Close tab | Ctrl+W |
| Reopen closed tab | Ctrl+Shift+T |
| Clear data | Ctrl+Shift+Del |
| Downloads | Ctrl+J |
| History | Ctrl+H |
| Bookmarks | Ctrl+Shift+O |

## Developer Tools

Enable:
```
F12 or Ctrl+Shift+I
```

Privacy note: Developer tools can leak information.

## Enterprise Configuration

For organizations, use policy file:

Linux: `/etc/opt/chrome/policies/managed/securevault.json`

```json
{
  "DefaultSearchProviderEnabled": true,
  "DefaultSearchProviderName": "DuckDuckGo",
  "DnsOverHttpsMode": "secure",
  "BlockThirdPartyCookies": true,
  "SitePerProcess": true
}
```

## Import from Other Browsers

### Import Bookmarks

```
chrome://settings/importData
```

Supports:
- Chrome/Chromium
- Firefox
- Edge
- Safari

### Import Passwords

Use CSV import:
```
chrome://settings/passwords
→ Import
```

## Troubleshooting

### Reset Settings

```bash
rm -rf ~/.config/securevault-browser/
```

### Check Configuration

```
chrome://version
chrome://gpu
chrome://net-internals
```

### Safe Mode

Launch without extensions:
```bash
./run.sh --disable-extensions
```

## Configuration Files

Key files:
- `Preferences` - User settings
- `Bookmarks` - Bookmark data
- `Cookies` - Cookie database
- `History` - Browsing history
- `Login Data` - Saved passwords

All in user data directory.

## Backup Configuration

Automated backup script:

```bash
#!/bin/bash
tar -czf securevault-backup-$(date +%Y%m%d).tar.gz \
  ~/.config/securevault-browser/
```

## Security Headers

SecureVault enforces strict security headers by default. No configuration needed.

## Remote Debugging

For development:
```bash
./run.sh --remote-debugging-port=9222
```

Access at `http://localhost:9222`

**Warning**: Security risk, only for development.
