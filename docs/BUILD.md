# SecureVault Browser - Build Guide

## Prerequisites

### Hardware Requirements
- **CPU**: Multi-core processor (8+ cores recommended)
- **RAM**: 16GB minimum, 32GB recommended
- **Disk**: 100GB+ free space
- **OS**: Linux, macOS, or Windows

### Time Requirements
- Initial setup: 30-60 minutes
- Full build: 1-3 hours (depends on hardware)
- Incremental builds: 5-20 minutes

## Operating System Setup

### Ubuntu/Debian Linux

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install basic tools
sudo apt-get install -y git curl python3 python3-pip lsb-release sudo

# The setup script will install the rest
```

### Arch Linux

```bash
sudo pacman -Syu
sudo pacman -S git python python-pip curl base-devel
```

### macOS

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git python3
```

### Windows (WSL2)

```bash
# Use Ubuntu on WSL2
# Then follow Ubuntu instructions above
```

## Quick Build

```bash
# Clone this repository (or download it)
cd ~/securevault-browser

# Make scripts executable
chmod +x setup.sh build.sh run.sh

# Run setup (downloads Chromium source)
./setup.sh

# Build the browser
./build.sh

# Run SecureVault Browser
./run.sh
```

## Detailed Build Process

### Step 1: Initial Setup

```bash
cd ~/securevault-browser
./setup.sh
```

This script will:
1. Install depot_tools (Chromium build tools)
2. Install system dependencies
3. Download Chromium source (~20GB)
4. Apply SecureVault patches
5. Copy branding files

**Note**: The initial `gclient sync` can take 30-60 minutes.

### Step 2: Build Configuration

The build configuration is in `build.sh` and generates `src/out/SecureVault/args.gn`:

```gn
is_debug = false
is_official_build = true
google_api_key = ""
enable_crash_reporter = false
safe_browsing_mode = 0
# ... more privacy settings
```

You can edit these settings before building.

### Step 3: Build

```bash
./build.sh
```

This will:
1. Generate ninja build files with `gn gen`
2. Compile with `ninja` using all CPU cores
3. Output binary to `src/out/SecureVault/chrome`

**Build time**: 1-3 hours for first build, 5-20 minutes for incremental.

### Step 4: Run

```bash
./run.sh
```

Launches SecureVault Browser with privacy flags.

## Advanced Build Options

### Debug Build

Edit `build.sh` and change in `args.gn`:
```gn
is_debug = true
symbol_level = 2
```

Debug builds are slower but helpful for development.

### Component Build

For faster incremental builds during development:
```gn
is_component_build = true
```

**Note**: Not for distribution, only development.

### Target Different Architectures

In `args.gn`, change:
```gn
target_cpu = "arm64"  # For ARM processors
# or
target_cpu = "x86"    # For 32-bit
```

### Custom Branding

Edit files in `branding/`:
- `securevault.gni` - Configuration
- Update icons in `icons/`
- Modify patches in `patches/`

## Troubleshooting

### Build Failures

#### Out of Memory
```bash
# Limit parallel jobs
ninja -C out/SecureVault -j4 chrome
```

#### Out of Disk Space
```bash
# Clean build artifacts
cd src
gn clean out/SecureVault
```

#### Dependency Issues (Linux)
```bash
cd src
./build/install-build-deps.sh --no-prompt
```

### Runtime Issues

#### Missing Libraries (Linux)
```bash
# Check dependencies
ldd src/out/SecureVault/chrome

# Install missing libraries
sudo apt-get install -f
```

#### GPU Issues
```bash
# Disable GPU acceleration
./src/out/SecureVault/chrome --disable-gpu
```

## Incremental Builds

After making code changes:

```bash
cd ~/securevault-browser/src
ninja -C out/SecureVault chrome
```

Only changed files will be recompiled.

## Clean Builds

To start fresh:

```bash
cd ~/securevault-browser/src
rm -rf out/SecureVault
```

Then run `./build.sh` again.

## Build Optimization

### Use ccache (Linux)

```bash
sudo apt-get install ccache
export PATH="/usr/lib/ccache:$PATH"
export CCACHE_DIR="$HOME/.ccache"
export CCACHE_MAXSIZE=50G
```

Add to `args.gn`:
```gn
cc_wrapper = "ccache"
```

Can reduce rebuild times by 50%+.

### Use Ramdisk for Build

If you have 64GB+ RAM:

```bash
sudo mkdir /mnt/ramdisk
sudo mount -t tmpfs -o size=40G tmpfs /mnt/ramdisk
cd /mnt/ramdisk
# Clone and build here
```

Significantly faster builds.

## Packaging

### Linux AppImage

```bash
cd ~/securevault-browser
./package-appimage.sh
```

### Linux .deb Package

```bash
cd ~/securevault-browser
./package-deb.sh
```

### Windows Installer

Build on Windows or use Wine:
```bash
# Build setup.exe
```

### macOS DMG

On macOS:
```bash
./package-dmg.sh
```

## Updating Chromium Base

To update to newer Chromium version:

```bash
cd ~/securevault-browser/src
git fetch origin
git checkout tags/VERSION_NUMBER
gclient sync
cd ..
./build.sh
```

**Note**: May require updating patches.

## CI/CD

For automated builds, see `.github/workflows/build.yml` (if using GitHub).

Example GitHub Actions workflow:

```yaml
name: Build SecureVault
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup
        run: ./setup.sh
      - name: Build
        run: ./build.sh
      - name: Upload
        uses: actions/upload-artifact@v2
        with:
          name: securevault-browser
          path: src/out/SecureVault/chrome
```

## Development Workflow

1. Make changes to patches or branding
2. Apply changes: `cd src && git apply ../patches/*.patch`
3. Build: `ninja -C out/SecureVault chrome`
4. Test: `./run.sh`
5. Iterate

## Testing

Run Chromium tests:

```bash
cd ~/securevault-browser/src
ninja -C out/SecureVault browser_tests
./out/SecureVault/browser_tests
```

## Performance Profiling

### CPU Profiling
```bash
./src/out/SecureVault/chrome --no-sandbox --trace-startup
```

### Memory Profiling
```bash
./src/out/SecureVault/chrome --enable-heap-profiling
```

## Contributing

When contributing:
1. Make changes in `patches/` or `branding/`
2. Test thoroughly
3. Document changes
4. Submit PR with description

## Resources

- [Chromium Build Documentation](https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md)
- [GN Reference](https://gn.googlesource.com/gn/+/main/docs/reference.md)
- [Ninja Build](https://ninja-build.org/)

## Support

For build issues:
1. Check this guide
2. Check Chromium build docs
3. Review error messages carefully
4. Ensure all dependencies installed

## Build Artifacts

After successful build:
- Binary: `src/out/SecureVault/chrome`
- Resources: `src/out/SecureVault/*.pak`
- Libraries: `src/out/SecureVault/*.so` (Linux)
- Size: ~200MB for binary + resources

## Cross-Compilation

To build for different platform:
```gn
target_os = "android"  # For Android
# or
target_os = "mac"      # For macOS
```

Requires appropriate SDK installed.
