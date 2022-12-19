import json
from flask import Flask, request, jsonify

# Define the jobs list
jobs = [
    {"title": "Senior Software Engineer", "client": "Aledade", "skills": ["Vue", "Python", "SQL", "healthcare"],"years of experience": 5},
    {"title": "Tech Lead", "client": "Aledade", "skills": ["Vue", "Python", "SQL","healthcare"],"years of experience": 7},
    {"title": "Software Engineer", "client": "Certipath", "skills": ["Vue", "C#", ".NET"],"years of experience": 4},
    {"title": "Full Stack Engineer", "client": "Grifin", "skills": ["React Native", "Node", "Mobile"],"years of experience": 3},
    {"title": "Lead Python Developer", "client": "SoundExchange", "skills": ["Python", "SQL", "AWS"],"years of experience": 8},
]

# Create a new Flask app
app = Flask(__name__)

# Define a route that listens for requests to the root URL
@app.route('/', methods=['GET', 'POST'])
def get_matching_jobs():
    # Check if the request method is POST
    if request.method == 'POST':
        # Get the keywords and years of experience from the request body
        keywords = request.form.get("keywords")
        years_of_experience = request.form.get("years_of_experience")

    # Check if the request method is GET
    elif request.method == 'GET':
        # Get the keywords and years of experience from the query string
        keywords = request.args.get("keywords")
        years_of_experience = request.args.get("years_of_experience")

    if years_of_experience is None:
        years_of_experience = 0
    else:
        try:
            years_of_experience = int(years_of_experience)
        except ValueError:
            years_of_experience = 0

    # Convert the keywords to lowercase and checks for error
    if keywords is None:
        keywords = ""
    keywords = keywords.lower()

    # Replace all occurrences of 'and' with a comma (',')
    keywords = keywords.replace("and", ",")

    # Split the keywords by the comma (',') character
    keywords = keywords.split(",")

    # Create a new list to store the matching jobs
    matching_jobs = []

    # Loop through each job in the jobs list
    for job in jobs:
        # Loop through each skill in the skills field of the job
        for skill in job["skills"]:
            # Loop through each keyword in the keywords list
            for keyword in keywords:
                # Check if the keyword is contained in the skill (converted to lowercase)
                if keyword.strip() in skill.lower():
                    # Check if the user's years of experience is greater than or equal to the required number of years of experience for the job
                    if years_of_experience >= job["years of experience"]:
                        #Check if job is already in list
                        if job not in matching_jobs:
                        # If both conditions are met, add the job to the matching_jobs list
                            matching_jobs.append(job)

    # Check if the matching_jobs list is empty
    if not matching_jobs:
        # If the list is empty, return an empty JSON object
        return jsonify({"message": "No jobs found"})
    else:
        # Otherwise, return the matching_jobs list as a JSON object
        return jsonify(matching_jobs)

# Run the app
if __name__ == '__main__':
    app.run(host='localhost', port=5000)