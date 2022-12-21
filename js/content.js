let tab;

document.getElementById('form').addEventListener('submit', (event) => {
  event.preventDefault();

  const keywords = document.getElementById('tech-stack').value;
  const years_of_experience = document.getElementById('years-of-experience').value;  

  // Send a message to the content script with the form data
  chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
    tab = tabs[0];
    chrome.tabs.sendMessage(tab.id, {
      type: 'get_matching_jobs',
      data: { keywords, years_of_experience }
    });
  });
});

function updateResults(data) {
  // Clear the existing results
  window.document.getElementById('results').innerHTML = '';

  // Loop through the matching jobs data and create a new element for each job
  data.forEach((job) => {
    const jobElement = window.document.createElement('div');
    jobElement.innerHTML = `<h2>${job.title}</h2><p>${job.client}</p>`;
    window.document.getElementById('results').appendChild(jobElement);
  });
}

// Set up a listener for messages from the background script
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === 'matching_jobs') {
    // Update the results with the matching jobs data
    updateResults(message.data);
  }
});
