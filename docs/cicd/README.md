# Mirror Repository - CI/CD and K3s Deployment

> This page describes the pipeline of the original deployment of the project. Its GitHub Actions workflow lived
> in the school repository and is not part of this copy; the deployment script is kept in `scripts/deploy.sh`.

This workflow automates building, mirroring, and deploying a Dockerized microservice application to a Kubernetes (K3s) cluster using GitHub Actions.

## CI/CD Pipeline Overview

### 1. **Build and Cache Docker Images**
- **Triggers**: On push to the `main` branch.
- **Steps**:
  - Checkout the repository code.
  - Set up Docker Buildx for multi-platform builds.
  - Install Docker Compose to manage multi-container Docker applications.
  - Build Docker images using `docker-compose`.

### 2. **Mirror Repository to Another Git Remote**
- **Condition**: Only runs on the `main` branch.
- **Steps**:
  - Mirrors the repository to a target repo URL using SSH credentials (via GitHub Secrets).

### 3. **Deploy to K3s**
- **Condition**: Runs after repository mirroring.
- **Steps**:
  - Deploys the application to a K3s cluster via SSH, executing a deployment script (`deploy.sh`).

## Deployment Script Overview

The deployment script handles:
- **Docker Image Management**: Builds and pushes microservice images to Docker Hub.
- **Kubernetes Resource Management**:
  - Generates Horizontal Pod Autoscaler (HPA) and Service YAML files for each service.
  - Applies Kubernetes deployments, services, HPAs, and ingress configurations.
  - Cleans up old Kubernetes resources.
  - Restarts deployments to pull the latest Docker images.

## Usage

1. Push changes to the `main` branch.
2. The pipeline builds Docker images, mirrors the repository, and triggers the deployment to your K3s cluster.
3. Your services are updated and deployed automatically on the cluster.

## Required Secrets

- `MIRROR_URL`: The URL of the repository to mirror to.
- `GIT_SSH_PRIVATE_KEY`: SSH private key for accessing the mirror repository.
- `SSH_PRIVATE_KEY`: SSH key for accessing the K3s server.
- `DOCKER_USERNAME` and `DOCKER_PASSWORD`: Credentials for pushing Docker images.
