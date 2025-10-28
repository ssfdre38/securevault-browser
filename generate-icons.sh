#!/bin/bash

echo "==============================================="
echo "SecureVault Browser Icon Generator"
echo "==============================================="
echo ""
echo "Generating PNG icons from SVG sources..."
echo ""

# Check if inkscape or ImageMagick is available
if command -v inkscape &> /dev/null; then
    CONVERTER="inkscape"
    echo "Using Inkscape for conversion"
elif command -v convert &> /dev/null; then
    CONVERTER="imagemagick"
    echo "Using ImageMagick for conversion"
else
    echo "Error: Neither Inkscape nor ImageMagick found"
    echo "Install one of them to generate PNG icons:"
    echo "  sudo apt-get install inkscape"
    echo "  sudo apt-get install imagemagick"
    exit 1
fi

# Create output directory
mkdir -p icons/png

# Icon sizes needed for various platforms
SIZES=(16 24 32 48 64 128 256 512)

echo ""
echo "Generating icons in multiple sizes..."

for size in "${SIZES[@]}"; do
    if [ "$CONVERTER" == "inkscape" ]; then
        inkscape icons/securevault-icon.svg \
            --export-type=png \
            --export-filename=icons/png/securevault-${size}.png \
            --export-width=$size \
            --export-height=$size \
            2>/dev/null
    else
        convert icons/securevault-icon.svg \
            -resize ${size}x${size} \
            icons/png/securevault-${size}.png
    fi
    echo "  ✓ Generated ${size}x${size} icon"
done

echo ""
echo "Generating ICO file for Windows..."
if [ "$CONVERTER" == "imagemagick" ]; then
    convert icons/png/securevault-{16,24,32,48,64,128,256}.png \
        icons/securevault.ico
    echo "  ✓ Generated securevault.ico"
else
    echo "  ⚠ ICO generation requires ImageMagick"
fi

echo ""
echo "Generating ICNS file for macOS..."
if command -v png2icns &> /dev/null; then
    png2icns icons/securevault.icns \
        icons/png/securevault-{16,32,128,256,512}.png
    echo "  ✓ Generated securevault.icns"
else
    echo "  ⚠ ICNS generation requires png2icns (libicns)"
    echo "    Install with: sudo apt-get install icnsutils"
fi

echo ""
echo "==============================================="
echo "Icon generation complete!"
echo "==============================================="
echo ""
echo "Generated icons:"
ls -lh icons/png/
if [ -f "icons/securevault.ico" ]; then
    ls -lh icons/securevault.ico
fi
if [ -f "icons/securevault.icns" ]; then
    ls -lh icons/securevault.icns
fi
echo ""
