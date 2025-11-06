// Content script for handling area selection and image capture

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'captureArea' && message.rect) {
    captureSelectedArea(message.rect);
  }
});

// Capture a specific area of the page
async function captureSelectedArea(rect) {
  try {
    // Create a canvas to draw the captured area
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');

    // Set canvas size to match selection
    canvas.width = rect.width * window.devicePixelRatio;
    canvas.height = rect.height * window.devicePixelRatio;

    // Scale for high DPI displays
    ctx.scale(window.devicePixelRatio, window.devicePixelRatio);

    // Use html2canvas if available, otherwise use a different approach
    if (typeof html2canvas !== 'undefined') {
      const screenshot = await html2canvas(document.body, {
        x: rect.x,
        y: rect.y,
        width: rect.width,
        height: rect.height,
        scrollX: 0,
        scrollY: 0
      });

      const imageData = screenshot.toDataURL('image/png');

      // Send the image data back to the popup
      chrome.runtime.sendMessage({
        type: 'areaImage',
        imageData: imageData
      });
    } else {
      // Fallback: capture visible tab and crop
      console.log('html2canvas not available, requesting tab capture');
      chrome.runtime.sendMessage({
        type: 'requestTabCapture',
        rect: rect
      });
    }
  } catch (error) {
    console.error('Failed to capture area:', error);
  }
}

// Helper function to create and show a notification
function showNotification(message, type = 'info') {
  const notification = document.createElement('div');
  notification.style.cssText = `
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 20px;
    background: ${type === 'error' ? '#ff5252' : '#4caf50'};
    color: white;
    border-radius: 4px;
    z-index: 10000000;
    font-family: Arial, sans-serif;
    font-size: 14px;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.2);
    animation: slideIn 0.3s ease;
  `;
  notification.textContent = message;

  document.body.appendChild(notification);

  setTimeout(() => {
    notification.style.animation = 'slideOut 0.3s ease';
    setTimeout(() => notification.remove(), 300);
  }, 3000);
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
  @keyframes slideIn {
    from {
      transform: translateX(400px);
      opacity: 0;
    }
    to {
      transform: translateX(0);
      opacity: 1;
    }
  }

  @keyframes slideOut {
    from {
      transform: translateX(0);
      opacity: 1;
    }
    to {
      transform: translateX(400px);
      opacity: 0;
    }
  }
`;
document.head.appendChild(style);

console.log('OCR Extension content script loaded');
