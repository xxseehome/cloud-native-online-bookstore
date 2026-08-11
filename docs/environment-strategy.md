# Environment Strategy

## Purpose

The platform provides five logical environments without maintaining
environment-specific Git branches or duplicating the complete infrastructure
stack. They are isolated with Kubernetes namespaces in a shared K3s cluster.

## Promotion Stages

| Promotion stage | Environment | Kubernetes namespace | Purpose |
| --- | --- | --- |
| Non-production | Development | `bookstore-dev` | Developer integration |
| Non-production | Test | `bookstore-test` | Internal QA and automated testing |
| Non-production | Performance | `bookstore-perf` | Performance and capacity checks |
| Pre-production | Staging | `bookstore-staging` | Integration testing and UAT |
| Production | Production | `bookstore-production` | Production workload |

## Branching Model

The repository uses trunk-based development:

- `main` is the only long-lived branch.
- Work is prepared on short-lived `feature/*` or `agent/*` branches.
- Changes reach `main` through pull requests.
- Environment-specific branches are not used.
- Deployment promotion never requires merging one environment branch into another.

## Immutable Image Promotion

The service pipeline builds the frontend and backend images once. Images are
tagged with the Git commit SHA and the same image digest is promoted through all
five environments.

```mermaid
flowchart LR
    PR[Pull request] --> CI[Unit and security checks]
    CI --> Build[Build image once]
    Build --> Dev[Development]
    Dev --> Test[Test]
    Test --> Perf[Performance]
    Perf --> Staging[Staging approval]
    Staging --> Production[Production approval]
```

Rebuilding an image for an environment is prohibited because it would make the
tested artifact different from the production artifact.

## Deployment Rules

- Development, test, and performance deployments can run without a protected
  reviewer once the required checks pass.
- Staging requires a GitHub Environment approval.
- Production requires a separate GitHub Environment approval.
- Gitleaks, Trivy, and OPA/Conftest run before image publication and deployment.
- OPA policies verify the rendered manifests use immutable images and safe
  container security settings.
- GitHub Environment protection rules provide the staging and production
  approvals.

## Kubernetes Configuration

Shared manifests will live in `kubernetes/base`. Small environment-specific
patches will live under `kubernetes/overlays/<environment>`. Overlays may
change namespace, replica count, resource limits, host names, and configuration,
but must not duplicate the complete base manifests.

## Infrastructure Scope

The five environments share one Alibaba Cloud infrastructure stack for this
demonstration:

- one VPC and vSwitch;
- one security group;
- one ECS-hosted K3s cluster;
- one private, versioned OSS bucket;
- separate Kubernetes namespaces for workload isolation.

The deployed variables enable only the account's existing **CLB (SLB-family)
free trial** through `enable_slb`. Terraform manages its HTTP listener, health
check, server group and ECS backend after the console-created trial instance is
imported. ALB and NLB are intentionally absent from Terraform and are not
activated: their trial resources would add load-balancer/EIP instances without
providing failover for this single ECS node. The production overlay includes a
hostless fallback ingress so the CLB public IP works without a purchased DNS
name. This is a cost-control choice, not a production availability
recommendation.

Separate clusters or accounts would be preferred for strongly isolated
production systems, but are outside the scope of this one-week exercise.
