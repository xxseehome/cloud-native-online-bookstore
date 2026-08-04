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

- Terraform

## CI/CD

- GitHub Actions

## Container

- Docker
- GitHub Container Registry (GHCR)

## Security

- Gitleaks
- Trivy
- Open Policy Agent (OPA)

## Environments

- Development
- Test
- Performance
- Staging
- Production
