# Cloud Native Online Book Store

A cloud-native online bookstore platform built on Alibaba Cloud and Kubernetes.

## Architecture

The application uses a multi-tier architecture:

User
→ Load Balancer
→ Kubernetes Ingress
→ Frontend
→ Backend API
→ Alibaba Cloud OSS

## Platform

- Alibaba Cloud
- Elastic Compute Service (ECS)
- Virtual Private Cloud (VPC)
- Kubernetes
- K3s
- Object Storage Service (OSS)

## Infrastructure as Code

- Terraform modules for VPC, ECS/K3s, OSS, and optional ALB
- Pull-request formatting, validation, and mocked infrastructure tests
- Cost-safe defaults that do not apply cloud resources from CI

See [Terraform Foundation](terraform/README.md) for the module layout, free-trial
constraints, and the staged deployment workflow.

## CI/CD

- GitHub Actions
- Trunk-based development with short-lived feature branches
- Immutable image promotion between environments

## Container

- Docker
- GitHub Container Registry (GHCR)

## Security

- Gitleaks
- Trivy
- Open Policy Agent (OPA)

## Environments and Promotion

The platform provides five logical application environments organized into three
promotion stages:

1. **Non-production**
   - Development
   - Test
2. **Pre-production**
   - Performance
   - Staging
3. **Production**
   - Production

The environments share a K3s cluster and are isolated with Kubernetes namespaces.
A container image is built once and promoted between environments using the same
immutable commit SHA. Environment-specific branches and image rebuilds are not
used.

Staging and production deployments require approval. See
[Environment Strategy](docs/environment-strategy.md) for the namespace,
promotion, and branching model.
