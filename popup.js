// Get the input fields and the results div
const techStackInput = document.getElementById('tech-stack');
const yearsOfExperienceInput = document.getElementById('years-of-experience');
const resultsDiv = document.getElementById('results');

// Get the submit button and add a click event listener
const submitButton = document.getElementById('submit-button');
submitButton.addEventListener('click', (event) => {
  // Prevent the default form submission behavior
  event.preventDefault();

  // Get the values of the input fields
  const techStack = techStackInput.value;
  const yearsOfExperience = yearsOfExperienceInput.value;

  // Send a message to the background script with the user's input
  chrome.runtime.sendMessage(
    {
      type: 'get_matching_jobs',
      data: { techStack, yearsOfExperience }
    },
    (response) => {
      // Clear the results div
      resultsDiv.innerHTML = '';

      // Loop through each matching job
      response.forEach((job) => {
        // Create a new div to display the job
        const jobDiv = document.createElement('div');
        jobDiv.innerHTML = `
          <h2>${job.title}</h2>
          <p>${job.client}</p>
          <p>${job['years of experience']} years of experience</p>
          <ul>
            ${job.skills.map((skill) => `<li>${skill}</li>`).join('')}
          </ul>
        `;

        // Append the job div to the results div
        resultsDiv.appendChild(jobDiv);
      });
    }
  );
});
