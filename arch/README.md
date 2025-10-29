# SecureVault Browser - Arch Linux Package

## Installation from AUR (Future)

Once published to AUR:
```bash
yay -S securevault-browser
# or
paru -S securevault-browser
```

## Manual Installation

1. Clone this directory
2. Run makepkg:
```bash
cd arch/
makepkg -si
```

## Building Package

```bash
makepkg -s
```

This creates: `securevault-browser-6.0.0-1-x86_64.pkg.tar.zst`

## Publishing to AUR

1. Create AUR account: https://aur.archlinux.org
2. Setup SSH keys
3. Clone AUR repository:
```bash
git clone ssh://aur@aur.archlinux.org/securevault-browser.git
```
4. Add PKGBUILD and .SRCINFO
5. Push to AUR

## Generate .SRCINFO

```bash
makepkg --printsrcinfo > .SRCINFO
```
