#!/bin/bash

# Setup script for OCR Chrome Extension
# This script downloads the required Tesseract.js library files

echo "Setting up OCR Chrome Extension..."
echo ""

# Create lib directory if it doesn't exist
mkdir -p lib

# Download Tesseract.js
echo "Downloading Tesseract.js..."
curl -L -o lib/tesseract.min.js https://cdn.jsdelivr.net/npm/tesseract.js@5.0.4/dist/tesseract.min.js || \
wget -O lib/tesseract.min.js https://cdn.jsdelivr.net/npm/tesseract.js@5.0.4/dist/tesseract.min.js

if [ -f lib/tesseract.min.js ]; then
    echo "✓ Tesseract.js downloaded successfully"
else
    echo "✗ Failed to download Tesseract.js"
    echo "Please download manually from: https://cdn.jsdelivr.net/npm/tesseract.js@5.0.4/dist/tesseract.min.js"
    echo "Save it to: lib/tesseract.min.js"
    exit 1
fi

echo ""
echo "Setup complete! You can now load the extension in Chrome:"
echo "1. Open Chrome and navigate to chrome://extensions/"
echo "2. Enable 'Developer mode' in the top right"
echo "3. Click 'Load unpacked'"
echo "4. Select the ocr-chrome-extension directory"
echo ""
echo "Note: The extension will download language data files on first use."
echo "      This may take a few moments."
