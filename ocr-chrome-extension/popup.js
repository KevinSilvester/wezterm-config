// DOM elements
const captureBtn = document.getElementById('capture-btn');
const selectBtn = document.getElementById('select-btn');
const copyBtn = document.getElementById('copy-btn');
const statusDiv = document.getElementById('status');
const resultContainer = document.getElementById('result-container');
const resultText = document.getElementById('result-text');
const progressDiv = document.getElementById('progress');
const progressFill = document.getElementById('progress-fill');
const progressText = document.getElementById('progress-text');
const langEng = document.getElementById('lang-eng');
const langJpn = document.getElementById('lang-jpn');

// Show status message
function showStatus(message, type = 'info') {
  statusDiv.textContent = message;
  statusDiv.className = `status ${type}`;
  statusDiv.classList.remove('hidden');

  if (type === 'success') {
    setTimeout(() => {
      statusDiv.classList.add('hidden');
    }, 3000);
  }
}

// Show/hide progress
function showProgress(show = true, progress = 0, text = 'Processing...') {
  if (show) {
    progressDiv.classList.remove('hidden');
    progressFill.style.width = `${progress}%`;
    progressText.textContent = text;
  } else {
    progressDiv.classList.add('hidden');
  }
}

// Get selected languages
function getSelectedLanguages() {
  const langs = [];
  if (langEng.checked) langs.push('eng');
  if (langJpn.checked) langs.push('jpn');

  if (langs.length === 0) {
    showStatus('Please select at least one language', 'error');
    return null;
  }

  return langs.join('+');
}

// Perform OCR on image
async function performOCR(imageData) {
  const languages = getSelectedLanguages();
  if (!languages) return;

  try {
    showProgress(true, 0, 'Initializing OCR...');
    resultContainer.classList.add('hidden');
    statusDiv.classList.add('hidden');

    const worker = await Tesseract.createWorker(languages.split('+'), 1, {
      workerPath: 'lib/worker.min.js',
      corePath: 'lib/tesseract-core.wasm.js',
      logger: (m) => {
        if (m.status === 'recognizing text') {
          const progress = Math.round(m.progress * 100);
          showProgress(true, progress, `Recognizing text: ${progress}%`);
        }
      }
    });

    showProgress(true, 50, 'Processing image...');

    const { data } = await worker.recognize(imageData);

    await worker.terminate();

    showProgress(false);

    if (data.text.trim()) {
      resultText.textContent = data.text;
      resultContainer.classList.remove('hidden');
      showStatus('Text extracted successfully!', 'success');
    } else {
      showStatus('No text found in the image', 'info');
    }

  } catch (error) {
    console.error('OCR Error:', error);
    showProgress(false);
    showStatus(`Error: ${error.message}`, 'error');
  }
}

// Capture visible tab
async function captureVisibleTab() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

    const dataUrl = await chrome.tabs.captureVisibleTab(null, {
      format: 'png'
    });

    await performOCR(dataUrl);
  } catch (error) {
    console.error('Capture Error:', error);
    showStatus(`Capture failed: ${error.message}`, 'error');
  }
}

// Select area on page
async function selectArea() {
  try {
    const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });

    // Inject the selection overlay
    await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      function: initAreaSelection
    });

    window.close(); // Close popup to allow user to select area
  } catch (error) {
    console.error('Selection Error:', error);
    showStatus(`Selection failed: ${error.message}`, 'error');
  }
}

// Copy text to clipboard
function copyToClipboard() {
  const text = resultText.textContent;
  navigator.clipboard.writeText(text).then(() => {
    showStatus('Text copied to clipboard!', 'success');
  }).catch(err => {
    console.error('Copy failed:', err);
    showStatus('Failed to copy text', 'error');
  });
}

// Event listeners
captureBtn.addEventListener('click', captureVisibleTab);
selectBtn.addEventListener('click', selectArea);
copyBtn.addEventListener('click', copyToClipboard);

// Function injected into page for area selection
function initAreaSelection() {
  // Remove existing overlay if any
  const existingOverlay = document.getElementById('ocr-selection-overlay');
  if (existingOverlay) {
    existingOverlay.remove();
  }

  // Create overlay
  const overlay = document.createElement('div');
  overlay.id = 'ocr-selection-overlay';
  overlay.style.cssText = `
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.3);
    z-index: 999999;
    cursor: crosshair;
  `;

  const selectionBox = document.createElement('div');
  selectionBox.style.cssText = `
    position: fixed;
    border: 2px dashed #667eea;
    background: rgba(102, 126, 234, 0.1);
    pointer-events: none;
    z-index: 1000000;
  `;

  document.body.appendChild(overlay);
  document.body.appendChild(selectionBox);

  let startX, startY, isSelecting = false;

  overlay.addEventListener('mousedown', (e) => {
    isSelecting = true;
    startX = e.clientX;
    startY = e.clientY;
    selectionBox.style.left = startX + 'px';
    selectionBox.style.top = startY + 'px';
    selectionBox.style.width = '0px';
    selectionBox.style.height = '0px';
    selectionBox.style.display = 'block';
  });

  overlay.addEventListener('mousemove', (e) => {
    if (!isSelecting) return;

    const currentX = e.clientX;
    const currentY = e.clientY;
    const width = Math.abs(currentX - startX);
    const height = Math.abs(currentY - startY);
    const left = Math.min(currentX, startX);
    const top = Math.min(currentY, startY);

    selectionBox.style.left = left + 'px';
    selectionBox.style.top = top + 'px';
    selectionBox.style.width = width + 'px';
    selectionBox.style.height = height + 'px';
  });

  overlay.addEventListener('mouseup', async (e) => {
    if (!isSelecting) return;
    isSelecting = false;

    const endX = e.clientX;
    const endY = e.clientY;
    const width = Math.abs(endX - startX);
    const height = Math.abs(endY - startY);

    if (width > 10 && height > 10) {
      const rect = {
        x: Math.min(startX, endX),
        y: Math.min(startY, endY),
        width: width,
        height: height
      };

      // Capture the selected area
      await captureArea(rect);
    }

    overlay.remove();
    selectionBox.remove();
  });

  overlay.addEventListener('contextmenu', (e) => {
    e.preventDefault();
    overlay.remove();
    selectionBox.remove();
  });

  async function captureArea(rect) {
    try {
      // Use html2canvas or similar to capture specific area
      // For simplicity, we'll send a message to capture the whole page
      // and then crop it
      chrome.runtime.sendMessage({
        type: 'captureArea',
        rect: rect
      });
    } catch (error) {
      console.error('Area capture failed:', error);
    }
  }
}

// Listen for messages from content script
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'areaImage') {
    performOCR(message.imageData);
  }
});

// Initialize
showStatus('Select capture mode and language', 'info');
