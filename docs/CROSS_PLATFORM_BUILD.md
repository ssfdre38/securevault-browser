# Cross-Platform Build Guide

## Automated Builds (GitHub Actions)

SecureVault Browser includes GitHub Actions workflows for automated building on all major platforms.

### Workflows

1. **build-linux.yml** - Builds for Linux (Ubuntu 22.04)
2. **build-windows.yml** - Builds for Windows (Windows Server 2022)
3. **build-macos.yml** - Builds for macOS (macOS 13)
4. **release.yml** - Creates releases with all platform builds

### Triggering Builds

Builds are automatically triggered on:
- Push to `main` or `master` branch
- Pull requests
- Manual workflow dispatch

### Manual Build Trigger

1. Go to **Actions** tab in GitHub
2. Select the workflow (Linux/Windows/macOS)
3. Click **Run workflow**
4. Select branch and run

### Creating a Release

To create a release with all platform builds:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Or use GitHub's workflow dispatch:
1. Go to **Actions** tab
2. Select **Create Release** workflow
3. Click **Run workflow**
4. Enter version (e.g., v1.0.0)
5. Run workflow

### Build Artifacts

After builds complete:
- Linux: `securevault-browser-linux-x64.tar.gz`
- Windows: `securevault-browser-windows-x64.zip`
- macOS: `securevault-browser-macos-x64.tar.gz`

Artifacts are available in:
- **Actions** → Select workflow run → **Artifacts** section
- **Releases** section (for tagged releases)

---

## Manual Local Builds

### Linux

#### Requirements
- Ubuntu 20.04 or newer
- 100GB+ disk space
- 16GB+ RAM
- Multi-core CPU

#### Build Steps
```bash
cd ~/securevault-browser
./setup.sh          # 30-60 minutes
./build.sh          # 1-3 hours
./package-linux.sh  # Create distributable package
```

#### Output
`securevault-browser-linux-x64.tar.gz`

---

### Windows

#### Requirements
- Windows 10/11 or Windows Server 2019+
- Visual Studio 2022 with C++ tools
- 100GB+ disk space
- 16GB+ RAM
- Multi-core CPU

#### Build Steps

1. Install Visual Studio 2022 with "Desktop development with C++"
2. Install Windows SDK 10.0.22621.0
3. Open Git Bash or Command Prompt

```bash
cd ~/securevault-browser
./setup.sh              # 30-60 minutes
./build-windows.sh      # 1-3 hours
./package-windows.sh    # Create distributable package
```

#### Output
`securevault-browser-windows-x64.zip`

---

### macOS

#### Requirements
- macOS 11 (Big Sur) or newer
- Xcode 13 or newer
- 100GB+ disk space
- 16GB+ RAM
- Multi-core CPU

#### Build Steps

1. Install Xcode from App Store
2. Install Xcode Command Line Tools:
   ```bash
   xcode-select --install
   ```
3. Build:
   ```bash
   cd ~/securevault-browser
   ./setup.sh            # 30-60 minutes
   ./build-macos.sh      # 1-3 hours
   ./package-macos.sh    # Create distributable package
   ```

#### Output
`securevault-browser-macos-x64.dmg`

---

## Platform-Specific Notes

### Linux

**Supported Distributions:**
- Ubuntu 20.04+
- Debian 11+
- Fedora 36+
- Arch Linux

**Installation:**
```bash
tar -xzf securevault-browser-linux-x64.tar.gz
cd securevault-browser
./securevault-browser
```

**System-wide Installation:**
```bash
sudo mv securevault-browser /opt/
sudo ln -s /opt/securevault-browser/securevault-browser /usr/local/bin/
sudo cp /opt/securevault-browser/securevault-browser.desktop /usr/share/applications/
```

---

### Windows

**Supported Versions:**
- Windows 10 (1903+)
- Windows 11
- Windows Server 2019+

**Installation:**
1. Extract `securevault-browser-windows-x64.zip`
2. Double-click `SecureVault.exe`

**Portable Mode:**
Browser runs in portable mode - all data stored in same directory.

---

### macOS

**Supported Versions:**
- macOS 11 (Big Sur)
- macOS 12 (Monterey)
- macOS 13 (Ventura)
- macOS 14 (Sonoma)

**Installation:**
1. Open `securevault-browser-macos-x64.dmg`
2. Drag SecureVault.app to Applications
3. First launch: Right-click → Open (bypass Gatekeeper)

**Note:** App is not notarized. You'll need to allow it in System Preferences → Security & Privacy.

---

## Build Configuration

All platforms use the same privacy-focused configuration:

```gn
is_official_build = true
google_api_key = ""
enable_crash_reporter = false
safe_browsing_mode = 0
enable_google_now = false
enable_hangout_services_extension = false
enable_remoting = false
enable_nacl = false
proprietary_codecs = true
ffmpeg_branding = "Chrome"
use_thin_lto = true
```

---

## Customizing Builds

### Change Architecture

Edit `args.gn` in build scripts:

**For ARM64:**
```gn
target_cpu = "arm64"
```

**For 32-bit:**
```gn
target_cpu = "x86"
```

### Debug Builds

Change in `args.gn`:
```gn
is_debug = true
symbol_level = 2
```

### Component Builds (Faster Development)

```gn
is_component_build = true
```

**Note:** Not suitable for distribution.

---

## Optimization Tips

### Faster Builds

**Use ccache (Linux/macOS):**
```bash
sudo apt-get install ccache  # Linux
brew install ccache          # macOS

export CCACHE_DIR=~/.ccache
export CCACHE_MAXSIZE=50G
```

Add to `args.gn`:
```gn
cc_wrapper = "ccache"
```

**Limit Parallel Jobs (Low RAM):**
```bash
ninja -C out/SecureVault -j4 chrome
```

### Build on Ramdisk (64GB+ RAM)

**Linux:**
```bash
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=40G tmpfs /mnt/ramdisk
cd /mnt/ramdisk
# Clone and build here
```

---

## Troubleshooting

### Linux Issues

**Out of memory:**
```bash
ninja -C out/SecureVault -j2 chrome
```

**Missing dependencies:**
```bash
cd src
sudo ./build/install-build-deps.sh --no-prompt
```

### Windows Issues

**Visual Studio not found:**
- Set `DEPOT_TOOLS_WIN_TOOLCHAIN=0`
- Install Visual Studio 2022 with C++ tools

**Python errors:**
- Use Python 3.11 (not 3.12+)

### macOS Issues

**Xcode not found:**
```bash
sudo xcode-select --switch /Applications/Xcode.app
```

**Signing errors:**
- Add to `args.gn`: `is_component_build = false`

---

## CI/CD Resources

### GitHub Actions Limits

- **Linux runner**: 2 cores, 7GB RAM, 14GB disk
- **Windows runner**: 2 cores, 7GB RAM, 14GB disk
- **macOS runner**: 3 cores, 14GB RAM, 14GB disk

### Build Times (GitHub Actions)

- **Linux**: ~3-4 hours
- **Windows**: ~4-5 hours
- **macOS**: ~3-4 hours

### Optimizing CI/CD

1. **Use shallow clones**: `--no-history` flag
2. **Cache depot_tools**: Speed up subsequent runs
3. **Limit parallel jobs**: Prevent OOM errors
4. **Free disk space**: Remove unnecessary files

---

## Distribution

### Creating Installers

**Linux (DEB package):**
```bash
# Coming soon
```

**Windows (NSIS installer):**
```bash
# Coming soon
```

**macOS (signed DMG):**
```bash
# Requires Apple Developer account
```

---

## Release Process

1. **Update version** in `branding/securevault.gni`
2. **Commit changes**
3. **Create tag**: `git tag v1.0.0`
4. **Push tag**: `git push origin v1.0.0`
5. **GitHub Actions** automatically builds all platforms
6. **Release** created with artifacts attached

---

## Support

For build issues:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review [Chromium build docs](https://chromium.googlesource.com/chromium/src/+/main/docs/)
3. Check GitHub Actions logs
4. Open an issue with build logs

---

## Additional Resources

- [Chromium Build Instructions](https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GN Reference](https://gn.googlesource.com/gn/+/main/docs/reference.md)
- [Ninja Build](https://ninja-build.org/)
