# Japanese/English OCR Chrome Extension

A powerful Chrome extension for extracting Japanese and English text from images on web pages using Optical Character Recognition (OCR).

## Features

- **Dual Language Support**: Recognizes both Japanese (including Kanji, Hiragana, Katakana) and English text
- **Two Capture Modes**:
  - **Capture & OCR**: Instantly capture and analyze the entire visible page
  - **Select Area**: Choose a specific region of the page for precise text extraction
- **Real-time Progress**: Visual progress bar showing OCR processing status
- **Copy to Clipboard**: One-click copy of extracted text
- **Modern UI**: Clean, gradient-based interface with smooth animations

## Prerequisites

Before installation, you need to download the required Tesseract.js library.

## Installation

### Step 1: Download Required Library

Run the setup script to download Tesseract.js:

```bash
cd ocr-chrome-extension
./setup.sh
```

If the script doesn't work due to network restrictions, manually download:
1. Visit: https://cdn.jsdelivr.net/npm/tesseract.js@5.0.4/dist/tesseract.min.js
2. Save the file as `lib/tesseract.min.js` in the extension directory

### Step 2: Create Icon Files

Generate PNG icons from the SVG source:

```bash
./create-icons.sh
```

If you don't have the required tools (rsvg-convert or ImageMagick):
1. Install librsvg2-bin: `sudo apt-get install librsvg2-bin` (Linux)
2. Or use an online converter: https://cloudconvert.com/svg-to-png
3. Create three PNG files from `icons/icon.svg`:
   - `icons/icon16.png` (16x16 pixels)
   - `icons/icon48.png` (48x48 pixels)
   - `icons/icon128.png` (128x128 pixels)

### Step 3: Load Extension in Chrome

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable **Developer mode** (toggle in top right corner)
3. Click **Load unpacked**
4. Select the `ocr-chrome-extension` directory
5. The extension icon should appear in your toolbar

## Usage

### Method 1: Capture Entire Page

1. Navigate to any web page with text you want to extract
2. Click the extension icon in your toolbar
3. Select your desired languages (English and/or Japanese)
4. Click **Capture & OCR** button
5. Wait for processing (progress bar will show status)
6. View extracted text in the results panel
7. Click **Copy** to copy text to clipboard

### Method 2: Select Specific Area

1. Click the extension icon
2. Select your desired languages
3. Click **Select Area** button
4. The page will dim with a selection overlay
5. Click and drag to select the area containing text
6. Release mouse to start OCR processing
7. Right-click to cancel selection

## Language Support

The extension supports:
- **English** (eng): All Latin characters
- **Japanese** (jpn): Kanji, Hiragana, Katakana, and Romaji

You can select one or both languages for recognition. Using both languages may increase processing time but improves accuracy for mixed-language content.

## How It Works

1. **Tesseract.js**: Uses the JavaScript port of the Tesseract OCR engine
2. **Language Models**: Downloads language training data on first use (~2-4 MB per language)
3. **Processing**: Analyzes captured images using neural networks trained on millions of text samples
4. **Output**: Extracts text with position and confidence information

## File Structure

```
ocr-chrome-extension/
├── manifest.json           # Extension configuration
├── popup.html             # Extension popup UI
├── popup.css              # Popup styling
├── popup.js               # Main OCR logic
├── content.js             # Content script for page interaction
├── content.css            # Content script styles
├── setup.sh               # Setup script for dependencies
├── create-icons.sh        # Icon generation script
├── README.md              # This file
├── icons/
│   ├── icon.svg          # Source SVG icon
│   ├── icon16.png        # 16x16 icon (generated)
│   ├── icon48.png        # 48x48 icon (generated)
│   └── icon128.png       # 128x128 icon (generated)
└── lib/
    └── tesseract.min.js  # Tesseract.js library (downloaded)
```

## Troubleshooting

### Extension won't load
- Ensure all icon files (PNG) are present in the `icons/` directory
- Check that `lib/tesseract.min.js` exists and is not empty
- Look for errors in Chrome's extension management page

### OCR is slow
- First-time use downloads language data files (normal delay)
- Large images take longer to process
- Try using "Select Area" for smaller regions

### No text detected
- Ensure text in image is clear and readable
- Verify correct language(s) are selected
- Try increasing image quality/size
- Some stylized fonts may not be recognized

### Language data download fails
- Check internet connection
- Try reloading the extension
- Clear browser cache and retry

## Privacy & Permissions

This extension requires:
- **activeTab**: To capture screenshots of the current page
- **scripting**: To inject selection overlay into pages

**Privacy Note**: All OCR processing happens locally in your browser. No images or text are sent to external servers (except for downloading language data files from Tesseract's CDN on first use).

## Development

### Tech Stack
- Tesseract.js v5.0.4
- Chrome Extension Manifest V3
- Vanilla JavaScript (no frameworks)

### Customization

To modify OCR settings, edit `popup.js`:

```javascript
const worker = await Tesseract.createWorker(languages.split('+'), 1, {
  // Add custom configuration here
  // Example: tessedit_char_whitelist: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
});
```

## Known Limitations

- Cannot process text in iframes from different origins
- May struggle with highly stylized or handwritten text
- Performance depends on device capabilities
- Requires internet connection for initial language data download

## Credits

- **Tesseract OCR Engine**: Originally developed by HP, now maintained by Google
- **Tesseract.js**: JavaScript port by naptha and contributors
- **Extension**: Created as a demonstration of browser-based OCR capabilities

## License

This extension is provided as-is for educational and personal use. Tesseract.js is licensed under Apache 2.0.

## Future Enhancements

Potential improvements:
- Support for more languages (Chinese, Korean, etc.)
- Batch processing of multiple images
- Export to various formats (TXT, PDF, etc.)
- OCR history/cache
- Adjustable image preprocessing
- Custom dictionary/word lists

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Chrome extension console for errors
3. Verify all setup steps were completed correctly

---

**Version**: 1.0.0
**Last Updated**: November 2025
