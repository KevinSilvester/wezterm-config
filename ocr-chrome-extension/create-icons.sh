#!/bin/bash

# Script to create icon files from SVG
# Requires: rsvg-convert (from librsvg) or ImageMagick

echo "Creating icon files..."

if command -v rsvg-convert &> /dev/null; then
    echo "Using rsvg-convert..."
    rsvg-convert -w 16 -h 16 icons/icon.svg > icons/icon16.png
    rsvg-convert -w 48 -h 48 icons/icon.svg > icons/icon48.png
    rsvg-convert -w 128 -h 128 icons/icon.svg > icons/icon128.png
    echo "✓ Icons created successfully"
elif command -v convert &> /dev/null; then
    echo "Using ImageMagick..."
    convert -background none -resize 16x16 icons/icon.svg icons/icon16.png
    convert -background none -resize 48x48 icons/icon.svg icons/icon48.png
    convert -background none -resize 128x128 icons/icon.svg icons/icon128.png
    echo "✓ Icons created successfully"
else
    echo "⚠ Neither rsvg-convert nor ImageMagick found."
    echo "Please install one of the following:"
    echo "  - librsvg2-bin (for rsvg-convert)"
    echo "  - imagemagick (for convert)"
    echo ""
    echo "Or create icons manually:"
    echo "  - icon16.png (16x16)"
    echo "  - icon48.png (48x48)"
    echo "  - icon128.png (128x128)"
    echo ""
    echo "You can also use an online SVG to PNG converter:"
    echo "  https://cloudconvert.com/svg-to-png"
    exit 1
fi
