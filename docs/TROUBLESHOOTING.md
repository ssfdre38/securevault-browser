# SecureVault Browser - Troubleshooting Guide

## Common Issues and Solutions

### Setup Issues

#### Problem: setup.sh fails with "depot_tools not found"
**Solution:**
```bash
export PATH="$PWD/depot_tools:$PATH"
./setup.sh
```

#### Problem: "Not enough disk space"
**Solution:**
```bash
# Check available space
df -h .

# Need at least 100GB free
# Clean up if necessary
```

#### Problem: gclient sync takes forever or fails
**Solution:**
```bash
# Use shallow clone
cd src
git fetch --depth=1
gclient sync --no-history
```

#### Problem: Dependencies installation fails
**Solution:**
```bash
cd src
sudo ./build/install-build-deps.sh --no-prompt
```

### Build Issues

#### Problem: Build fails with "Out of memory"
**Solution:**
```bash
# Limit parallel jobs
cd ~/securevault-browser/src
ninja -C out/SecureVault -j4 chrome
```

#### Problem: "gn: command not found"
**Solution:**
```bash
export PATH="$PWD/depot_tools:$PATH"
./build.sh
```

#### Problem: Compilation errors in Chromium source
**Solution:**
```bash
# Update to latest stable
cd src
git fetch origin
git checkout -b stable origin/stable
gclient sync
cd ..
./build.sh
```

#### Problem: Build stops at linking stage
**Solution:**
```bash
# Increase swap space
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Then retry build
./build.sh
```

### Runtime Issues

#### Problem: Browser won't launch - "chrome: command not found"
**Solution:**
```bash
# Build first
./build.sh

# Then run
./run.sh
```

#### Problem: "error while loading shared libraries"
**Solution:**
```bash
# Install missing libraries
cd src
ldd out/SecureVault/chrome | grep "not found"
sudo apt-get install -f

# Common missing libraries
sudo apt-get install libatk1.0-0 libgtk-3-0 libglib2.0-0
```

#### Problem: Browser crashes on startup
**Solution:**
```bash
# Disable GPU acceleration
./src/out/SecureVault/chrome --disable-gpu

# Or disable sandboxing (less secure)
./src/out/SecureVault/chrome --no-sandbox
```

#### Problem: "Failed to create data directory"
**Solution:**
```bash
# Create directory manually
mkdir -p ~/.config/securevault-browser
chmod 700 ~/.config/securevault-browser
./run.sh
```

### Performance Issues

#### Problem: Browser is very slow
**Solution:**
```bash
# Enable hardware acceleration
# Remove --disable-gpu from run.sh if present

# Or reduce memory usage
./run.sh --process-per-site
```

#### Problem: High memory usage
**Solution:**
```bash
# Enable tab discarding
# Visit chrome://flags/#automatic-tab-discarding
# Set to Enabled
```

### Network Issues

#### Problem: DNS-over-HTTPS not working
**Solution:**
```bash
# Check DoH status
# Visit chrome://net-internals/#dns

# Manually configure
# chrome://settings/security
# Use secure DNS: On
```

#### Problem: Can't access any websites
**Solution:**
```bash
# Remove proxy settings
./run.sh --no-proxy-server

# Or check system proxy
env | grep -i proxy
```

#### Problem: WebRTC still leaking IP
**Solution:**
```bash
# Test at browserleaks.com/webrtc
# Should show only public IP

# If leaking, add to run.sh:
--force-webrtc-ip-handling-policy=disable_non_proxied_udp
```

### Extension Issues

#### Problem: Can't install extensions
**Solution:**
```bash
# Enable developer mode
# Visit chrome://extensions
# Enable "Developer mode"
# Then drag and drop .crx files
```

#### Problem: Extensions won't load
**Solution:**
```bash
# Check permissions
chmod -R 755 ~/.config/securevault-browser/Extensions/

# Or reset extension directory
rm -rf ~/.config/securevault-browser/Extensions/
```

### Icon Issues

#### Problem: generate-icons.sh fails
**Solution:**
```bash
# Install inkscape
sudo apt-get install inkscape

# Or use imagemagick
sudo apt-get install imagemagick
```

#### Problem: Icons not showing in launcher
**Solution:**
```bash
# Copy to system icons directory
sudo cp icons/png/securevault-256.png /usr/share/icons/hicolor/256x256/apps/
sudo gtk-update-icon-cache /usr/share/icons/hicolor/
```

### Update Issues

#### Problem: Can't update Chromium source
**Solution:**
```bash
cd ~/securevault-browser/src
git fetch origin
git rebase origin/main
gclient sync
cd ..
./build.sh
```

#### Problem: Patches fail to apply after update
**Solution:**
```bash
cd ~/securevault-browser/src
# Unapply old patches
git checkout .

# Update patches for new version
# Edit patches/001-disable-tracking.patch
# Then reapply
git apply ../patches/*.patch
```

## Diagnostic Commands

### Check Build Status
```bash
cd ~/securevault-browser/src
ninja -C out/SecureVault -t query chrome
```

### Check Dependencies
```bash
cd ~/securevault-browser/src
./build/install-build-deps.sh --quick-check
```

### View Build Logs
```bash
cd ~/securevault-browser/src
ninja -C out/SecureVault -v chrome 2>&1 | tee build.log
```

### Check Binary
```bash
file src/out/SecureVault/chrome
ldd src/out/SecureVault/chrome
```

### Test Network
```bash
# Launch with network logging
./run.sh --log-net-log=netlog.json

# View at chrome://net-internals
```

### Memory Usage
```bash
# Monitor during build
watch -n 1 'free -h'

# Monitor during runtime
ps aux | grep chrome
```

## Reset Everything

### Clean Build
```bash
cd ~/securevault-browser/src
rm -rf out/SecureVault
cd ..
./build.sh
```

### Reset User Data
```bash
rm -rf ~/.config/securevault-browser
./run.sh
```

### Complete Reset
```bash
cd ~
rm -rf securevault-browser
# Start over with setup
```

## Getting Help

### Check Logs
```bash
# Browser logs
~/.config/securevault-browser/chrome_debug.log

# Build logs
~/securevault-browser/src/build.log
```

### Debug Mode
```bash
# Launch with debug output
./run.sh --enable-logging --v=1
```

### Chromium Documentation
- Build docs: https://chromium.googlesource.com/chromium/src/+/main/docs/
- Linux build: https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md

## Known Limitations

1. **No Chrome Sync** - Removed for privacy
2. **No Auto-Updates** - User must manually update
3. **No Web Store** - Install extensions manually
4. **Large Download** - Initial setup downloads ~20GB
5. **Long Build Time** - First build takes 1-3 hours
6. **High Memory Usage** - Build requires 16GB+ RAM

## Platform-Specific Issues

### Linux
- **Wayland**: May need `--enable-features=UseOzonePlatform --ozone-platform=wayland`
- **Nvidia**: May need `--disable-gpu-sandbox`

### macOS
- **Gatekeeper**: May need to allow in Security & Privacy settings
- **Notarization**: Not notarized, need to right-click and open

### Windows (WSL)
- **WSLg**: Use WSL2 with WSLg for GUI support
- **Performance**: Native Windows build recommended

## Performance Optimization

### Faster Builds
```bash
# Use ccache
sudo apt-get install ccache
export CCACHE_DIR=~/.ccache
export CCACHE_MAXSIZE=50G

# Add to args.gn:
cc_wrapper = "ccache"
```

### Faster Runtime
```bash
# Use profile-guided optimization (advanced)
# First build with profiling:
# is_official_build = true
# chrome_pgo_phase = 1

# Then rebuild with profile data:
# chrome_pgo_phase = 2
```

## Security Notes

### Safe Mode
```bash
# Launch without extensions
./run.sh --disable-extensions

# Launch without GPU
./run.sh --disable-gpu

# Launch with clean profile
./run.sh --user-data-dir=/tmp/test-profile
```

### Verify Privacy
1. **No telemetry**: Check chrome://net-internals/#events
2. **DNS encryption**: Test at dnsleaktest.com
3. **WebRTC**: Test at browserleaks.com/webrtc
4. **Fingerprint**: Test at amiunique.org

## Still Having Issues?

1. Check all documentation in `docs/` directory
2. Review Chromium build documentation
3. Ensure all dependencies are installed
4. Try a clean build
5. Check system resources (disk, RAM, CPU)
6. Test with minimal configuration
7. Review error messages carefully

Remember: Building Chromium is complex. Be patient and methodical when troubleshooting.
