const form = document.getElementById("form");
const submitButton = document.getElementById("submit-button");

form.addEventListener("submit", function(event) {
  // Prevent the default form submission behavior
  event.preventDefault();

  // Get the values of the tech stack and years of experience fields
  const techStack = document.getElementById("tech-stack").value;
  const yearsOfExperience = document.getElementById("years-of-experience").value;

  // Make an HTTP POST request to the Flask app
  fetch("http://127.0.0.1:5000", {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
        "keywords": techStack,
        "years_of_experience": yearsOfExperience
      })
    })
    .then(response => response.json())
    .then(function(response) {
      // Handle the response from the Flask app
      if (response.message) {
        // If the response contains a message field, display the message
        document.getElementById("results").innerHTML = response.message;
      } else {
        // Otherwise, display the list of matching jobs
        let html = "";
        for (const job of response) {
          html += `<div>${job.client} - ${job.title}</div>`;
        }
        document.getElementById("results").innerHTML = html;
      }
    });
});
