# Dev Container - Helm/Helmfile

A Dev Containers compatible Docker image based on Alpine Linux 3.19, featuring Helm and Helmfile for Kubernetes deployments.

## 🚀 Features

- **Base Image**: Alpine Linux 3.19 (lightweight and secure)
- **Helm**: Latest stable version for Kubernetes package management
- **Helmfile**: Declarative spec for deploying Helm charts
- **kubectl**: Kubernetes command-line tool
- **Dev Containers Compatible**: Ready to use with VS Code Dev Containers

## 📦 What's Included

- Helm 3.14.0
- Helmfile 0.162.0
- kubectl 1.29.1
- Git, curl, bash, and CA certificates
- Non-root user (`vscode`) for security

## 🐳 Docker Hub

The image is automatically built and pushed to Docker Hub:

```bash
docker pull charbo/devcontainer:latest
```

Available tags:
- `latest` - Latest build from the main branch
- `main` - Main branch builds
- `v*` - Semantic version tags (e.g., `v1.0.0`)

## 🛠️ Usage

### Using with VS Code Dev Containers

This repository includes a `.devcontainer` configuration. Simply:

1. Open this repository in VS Code
2. Install the "Dev Containers" extension
3. Click "Reopen in Container" when prompted

### Using the Docker Image Directly

```bash
# Run interactively
docker run -it charbo/devcontainer:latest

# Run with mounted Kubernetes config
docker run -it -v ~/.kube:/home/vscode/.kube charbo/devcontainer:latest

# Run a specific command
docker run --rm charbo/devcontainer:latest helm version
```

### Example Helmfile Usage

```bash
# Inside the container
helmfile sync
helmfile apply
helmfile status
```

## 🏗️ Building Locally

```bash
# Build the image
docker build -t charbo/devcontainer:local .

# Test the build
docker run --rm charbo/devcontainer:local helm version
docker run --rm charbo/devcontainer:local helmfile version
docker run --rm charbo/devcontainer:local kubectl version --client
```

## 🔧 GitHub Actions

The repository includes a GitHub Actions workflow that automatically:

1. Builds the Docker image on push to main/master
2. Pushes to Docker Hub as `charbo/devcontainer`
3. Tags images based on Git tags and branches

### Required Secrets

To enable automatic pushing to Docker Hub, configure these secrets in your GitHub repository:

- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Your Docker Hub access token

## 📝 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.