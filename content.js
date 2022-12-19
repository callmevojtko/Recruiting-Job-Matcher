document.getElementById('form').addEventListener('submit', (event) => {
  event.preventDefault();

  const keywords = document.getElementById('keywords').value;
  const years_of_experience = document.getElementById('years_of_experience').value;

  // Send a message to the content script with the form data
  chrome.tabs.sendMessage(tab.id, {
    type: 'get_matching_jobs',
    data: { keywords, years_of_experience }
  });
});
