// Set up a listener that listens for messages from the background script
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    // Check if the message is a response containing the matching jobs
    if (request.type === 'matching_jobs') {
      // Clear any existing matching jobs
      clearMatchingJobs();
  
      // Loop through each matching job
      for (const job of request.data) {
        // Create a new element to display the job
        const jobElement = createJobElement(job);
  
        // Add the job element to the page
        document.body.appendChild(jobElement);
      }
    }
  });
  
  // Send a message to the background script to request the matching jobs
  function getMatchingJobs(keywords, yearsOfExperience) {
    // Send a message to the background script
    chrome.runtime.sendMessage({
      type: 'get_matching_jobs',
      data: { keywords, yearsOfExperience }
    }, (response) => {
      // Send a message to the content script with the matching jobs
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        chrome.tabs.sendMessage(tabs[0].id, {
          type: 'matching_jobs',
          data: response
        });
      });
    });
  }
  
  // Clear any existing matching jobs
  function clearMatchingJobs() {
    // Find all elements with the 'matching-job' class
    const matchingJobs = document.querySelectorAll('.matching-job');
  
    // Loop through each matching job
    for (const job of matchingJobs) {
      // Remove the job from the page
      job.remove();
    }
  }
  
  // Create a new element to display the job
  function createJobElement(job) {
    // Create a new div element
    const jobElement = document.createElement('div');
  
    // Add the 'matching-job' class to the element
    jobElement.classList.add('matching-job');
  
    // Set the inner HTML of the element to display the job's details
    jobElement.innerHTML = `
      <h2>${job.title}</h2>
      <p>Client: ${job.client}</p>
      <p>Skills: ${job['skills'].join(', ')}</p>
      <p>Years of experience: ${job['years of experience']}</p>
    `;
  
    // Return the job element
    return jobElement;
  }
  