# Setup Instructions

This document provides instructions for setting up the repository to automatically build and push Docker images to Docker Hub.

## Prerequisites

1. A Docker Hub account
2. Access to the GitHub repository settings

## Configure Docker Hub Secrets

To enable automatic pushing to Docker Hub, you need to configure two secrets in your GitHub repository:

### 1. Create a Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Click on your username in the top right corner
3. Select "Account Settings"
4. Go to "Security" → "Access Tokens"
5. Click "New Access Token"
6. Give it a descriptive name (e.g., "GitHub Actions - devcontainer")
7. Set the permissions (Read & Write recommended)
8. Click "Generate"
9. **Important**: Copy the token immediately - you won't be able to see it again!

### 2. Add Secrets to GitHub Repository

1. Go to your GitHub repository: `https://github.com/pchar/devcontainer`
2. Click on "Settings" tab
3. In the left sidebar, click "Secrets and variables" → "Actions"
4. Click "New repository secret"

Add the following two secrets:

**Secret 1: DOCKERHUB_USERNAME**
- Name: `DOCKERHUB_USERNAME`
- Value: Your Docker Hub username (e.g., `charbo`)

**Secret 2: DOCKERHUB_TOKEN**
- Name: `DOCKERHUB_TOKEN`
- Value: The access token you generated in step 1

## How the Workflow Works

Once the secrets are configured, the GitHub Actions workflow will automatically:

1. **On push to main/master branch**: Build and push as `charbo/devcontainer:latest` and `charbo/devcontainer:main`
2. **On version tags (e.g., v1.0.0)**: Build and push with semantic versioning tags
3. **On pull requests**: Build only (no push) to verify the Dockerfile works

## Triggering the First Build

You can trigger the workflow in several ways:

### Option 1: Push to Main Branch
```bash
# Merge this PR to the main/master branch
# The workflow will run automatically
```

### Option 2: Create a Version Tag
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Option 3: Manual Trigger
1. Go to the "Actions" tab in your repository
2. Select "Build and Push Docker Image"
3. Click "Run workflow"
4. Select the branch and click "Run workflow"

## Verifying the Build

After the workflow runs:

1. Check the "Actions" tab in GitHub to see the workflow status
2. Once successful, verify on Docker Hub:
   - Visit: `https://hub.docker.com/r/charbo/devcontainer`
   - You should see your image with the appropriate tags

## Using the Image

Once published, anyone can pull and use your image:

```bash
# Pull the latest version
docker pull charbo/devcontainer:latest

# Run interactively
docker run -it charbo/devcontainer:latest

# Check installed tools
docker run --rm charbo/devcontainer:latest helm version
docker run --rm charbo/devcontainer:latest helmfile version
docker run --rm charbo/devcontainer:latest kubectl version --client
```

## Troubleshooting

### Build Fails with Authentication Error
- Verify that `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets are correctly set
- Ensure the Docker Hub access token has appropriate permissions

### Image Not Appearing on Docker Hub
- Check that the repository `charbo/devcontainer` exists on Docker Hub
- If it doesn't exist, Docker Hub will create it automatically on first push
- Ensure your Docker Hub account has permission to create repositories

### Workflow Not Running
- Verify the workflow file is in `.github/workflows/docker-build-push.yml`
- Check that you're pushing to the `main` or `master` branch
- Look at the "Actions" tab for any error messages
