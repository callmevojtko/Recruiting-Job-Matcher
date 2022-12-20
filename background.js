// Set up a listener that listens for messages from the content script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  // Check if the message is a request for matching jobs
  if (request.type === 'get_matching_jobs') {
    // Get the URL of the Flask app
    const url = chrome.runtime.getURL('/');
    
    // Send a request to the Flask app
    fetch(url, {
      method: 'POST',
      body: JSON.stringify(request.data)
    })
      .then((response) => response.json())
      .then((data) => {
        // Send a response with the matching jobs to the content script
        sendResponse(data);

        // Send a message to the popup page with the matching jobs data
        chrome.runtime.sendMessage({
          type: 'matching_jobs',
          data
        });
      });

    // Return true to indicate that a response will be sent asynchronously
    return true;
  }
});
