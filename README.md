# Spring Boot Application with CI/CD, Helm, and Terraform

This repository contains a production-ready deployment setup for a Java Spring Boot application using modern DevOps practices. The application resides in the `JavaApp/` directory and is containerized, deployed via Helm on an EKS cluster, and fully automated through GitHub Actions CI/CD pipelines and Terraform infrastructure as code.

---

## Table of Contents

- [Project Structure](#project-structure)  
- [Technologies Used](#technologies-used)  
- [Containerization Strategy](#containerization-strategy)  
- [Kubernetes Deployment via Helm](#kubernetes-deployment-via-helm)  
- [Infrastructure as Code with Terraform](#infrastructure-as-code-with-terraform)
- [Makefile for Terraform Workflows](#makefile-for-terraform-workflows)  
- [CI/CD with GitHub Actions](#cicd-with-github-actions)  
- [Why This Architecture?](#why-this-architecture)  
- [Getting Started](#getting-started)
- [Note on Future Improvements](#note-on-future-improvements)

---

## Project Structure

```
├── JavaApp/                     # Spring Boot application
│   └── Dockerfile              # Multi-stage Dockerfile for optimized builds
│
├── helm-charts/
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   └── values.yaml
│
├── Environments/
│   ├── Dev/                    # Dev environment Terraform code
│   └── Modules/                # Reusable Terraform modules
│
├── .github/
│   └── workflows/
│       ├── build-image.yml     # Reusable workflow for Docker build & ECR push
│       ├── deploy-image.yml    # Reusable workflow for Helm deployment
│       └── cicd.yml            # Triggers reusable workflows on push events
```

---

## Technologies Used

- **Spring Boot** - Java-based microservices framework
- **Docker** - Containerization
- **Helm** - Kubernetes package manager for deployment
- **Terraform** - Infrastructure provisioning
- **GitHub Actions** - CI/CD automation
- **Trivy** - Container vulnerability scanning
- **SonarQube** - Code quality and static analysis
- **AWS VPC** - Custom VPC for EKS networking
- **AWS EKS** - Kubernetes cluster
- **AWS ALB Ingress** - Load balancer
- Other related AWS resources

---

## Containerization Strategy

A **multi-stage Dockerfile** is used within the `JavaApp/` folder.  
### Why Multi-Stage?
- Keeps final image lightweight and secure by separating build and runtime stages.
- Reduces the attack surface and unnecessary dependencies.
- Speeds up deployment time with smaller images.

---

## Kubernetes Deployment via Helm

The application is deployed using a **Helm chart** that includes:
- `deployment.yaml`: Manages pod templates and replica strategies.
- `service.yaml`: Exposes the application internally within the cluster.

### Where is Ingress?
- The ingress (AWS ALB) configuration is defined in the **Terraform code** instead of Helm to ensure full control over AWS-native resources and maintain separation of concerns between infrastructure and application logic.

---

## Infrastructure as Code with Terraform

A **modular and environment-segregated** structure is followed instead of using workspaces.

### Why Not Workspaces?
- Workspaces can be limiting when per-environment resource customization is needed.
- Directory-based segregation offers:
  - Greater flexibility
  - Clear separation of state and configurations
  - Easier collaboration and scaling in large teams

### Features:
- Separate directories for `dev` and `prod`
- Reusable modules for ALB, VPC, EKS, etc.
- Secure and scalable architecture following AWS best practices

---
## Makefile for Terraform Workflows

Each environment (`dev/`) includes a **customizable Makefile** that simplifies Terraform operations.

### Why Use a Makefile?
- Reduces complexity and human error by abstracting frequently used Terraform commands.
- Provides consistent execution across environments.
- Enables quick modifications to common actions like `init`, `plan`, `apply`, `destroy`, or even `fmt` and `validate`.

### Example Commands
```bash
make init
make plan
make apply
make destroy
```

This approach streamlines day-to-day workflows, especially in teams, and encourages infrastructure management as code best practices.

---

## CI/CD with GitHub Actions

CI/CD is implemented using **GitHub Actions with Reusable Workflows**.

### Why Reusable Workflows?
- Centralizes and reuses logic across multiple pipelines
- Reduces duplication and simplifies pipeline maintenance
- Enhances consistency and compliance across environments

### Pipeline Features:
- Code scan via **SonarQube**
- Docker image build & push to **AWS ECR**
- Image vulnerability scan with **Trivy**
- Helm-based deployment to **EKS**
- Triggered automatically on changes to `JavaApp/` or `helm-charts/`

---

## Why This Architecture?

This architecture is designed to be:
- **Modular** – Easily extend or replace components without major rewrites.
- **Production-Ready** – Covers CI/CD, infrastructure, security scanning, and environment isolation.
- **Cost-Efficient** – Uses multi-stage builds and scalable infrastructure.
- **Scalable** – Easily supports additional microservices or environments.

---

## Getting Started

### Prerequisites
- AWS CLI configured with access credentials
- Terraform >= 1.0
- Helm >= 3.x
- kubectl configured for EKS
- Docker
- GitHub repository with required secrets

### Steps
1. **Provision Infrastructure**
   ```bash
   cd terraform/dev   # or terraform/prod
   make init
   make plan
   make apply
   ```

2. **Deploy via GitHub Actions**
   - Push changes to `JavaApp/` or `helm-charts/` and the pipeline will be triggered automatically.
  
---

## Note on Future Improvements

While this project delivers a complete and functional pipeline and infrastructure setup, **there are areas where both the Terraform code and GitHub Actions workflows can be further optimized** for scalability, modularity, and performance. Due to **time constraints**, the current implementation focuses on delivering a working, production-grade MVP that adheres to best practices as much as possible.  

Improvements such as:
- Enhanced Terraform module reusability
- More granular IAM role separation
- Pipeline step caching and matrix builds
- Dynamic Helm value handling per environment

...are all possible and can be planned as part of future iterations.

---
