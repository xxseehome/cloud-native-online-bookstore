# Cloud Native Online Book Store

A cloud-native online bookstore platform built on Alibaba Cloud and Kubernetes.

## Architecture

The demonstration uses the existing Hangzhou CLB (the basic SLB-family product)
as its public HTTP entry point after state adoption. Traffic then reaches
Traefik Ingress, an Nginx frontend, and the FastAPI backend. Terraform also
provisions a private, encrypted, versioned OSS bucket as the storage
foundation. ALB and NLB trials are intentionally not activated because they
would add load-balancer/EIP resources without providing node failover for the
single ECS. See the complete
[platform architecture](docs/architecture.md).

## Platform

- Alibaba Cloud
- Elastic Compute Service (ECS)
- Virtual Private Cloud (VPC)
- Kubernetes
- K3s
- Object Storage Service (OSS)

## Infrastructure as Code

- Terraform modules for VPC, ECS/K3s, OSS, and the adopted CLB listener
- Pull-request formatting, validation, security gates, and mocked infrastructure tests
- Cost-safe defaults that do not apply cloud resources from CI

See [Terraform Foundation](terraform/README.md) for the module layout, free-trial
constraints, and the staged deployment workflow.

## CI/CD

- GitHub Actions
- Trunk-based development with short-lived feature branches
- Immutable image promotion between environments
- Terraform plan artifacts with protected-environment approval before apply
- Manual staging workload resilience check with Pod deletion and continuous HTTP probes

## Container

- Docker
- GitHub Container Registry (GHCR)

## Security

- Gitleaks secret detection, Trivy vulnerability/configuration scanning, and
  Open Policy Agent (OPA)/Conftest Kubernetes policy checks run in CI before
  images can be published.
- See [Security Controls](docs/security-controls.md) for the policy scope and
  pinned scanner versions.

## Environments and Promotion

The platform provides five logical application environments:

1. **Development**
2. **Test**
3. **Performance**
4. **Staging**
5. **Production**

The environments share one K3s cluster and are isolated with Kubernetes
namespaces. They are promoted through non-production, pre-production, and
production stages without environment-specific branches or infrastructure
copies.
A container image is built once and promoted between environments using the same
immutable commit SHA. Environment-specific branches and image rebuilds are not
used.

Staging and production deployments require approval. See
[Environment Strategy](docs/environment-strategy.md) for the namespace,
promotion, and branching model.

## Evidence

The [acceptance evidence](docs/acceptance-evidence.md) records the immutable
image SHA, five promotion runs, smoke-test results, security gates, and links to
the GitHub Actions logs used for review.
