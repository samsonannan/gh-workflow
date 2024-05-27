#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
REPO_URL="https://github.com/your-org/deploy.git"
REPO_NAME="deploy"
BRANCH_NAME="update-values-$(date +%s)"
VALUES_FILE_PATH="path/to/values.yaml"
PAT="your_personal_access_token"  # Replace with your actual PAT
NEW_IMAGE_TAG="new-image-tag"  # Replace with the actual new image tag

# Clone the repository
git clone https://${PAT}@${REPO_URL} ${REPO_NAME}
cd ${REPO_NAME}

# Create and switch to a new branch
git checkout -b ${BRANCH_NAME}

# Update the values.yaml file
# Example of updating an image tag; adjust as needed for your file structure
yq eval '.image.tag = "'${NEW_IMAGE_TAG}'"' -i ${VALUES_FILE_PATH}

# Configure git
git config user.name "your-username"  # Replace with your GitHub username
git config user.email "your-email@example.com"  # Replace with your email

# Commit the changes
git add ${VALUES_FILE_PATH}
git commit -m "Update image tag to ${NEW_IMAGE_TAG}"

# Push the changes to the new branch
git push origin ${BRANCH_NAME}

# Go back to the parent directory and delete the cloned repository
cd ..
rm -rf ${REPO_NAME}

echo "Changes have been pushed to the branch ${BRANCH_NAME} in the repository."