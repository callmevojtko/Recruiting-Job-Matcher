// Set up a listener that listens for requests from the background script
self.addEventListener('message', (event) => {
    // Check if the request is a request to perform an update check
    if (event.data.type === 'perform_update_check') {
      // Perform the update check
      checkForUpdates().then((updateAvailable) => {
        // If an update is available, send a message to the background script
        if (updateAvailable) {
          self.postMessage({ type: 'update_available' });
        }
      });
    }
  });
  