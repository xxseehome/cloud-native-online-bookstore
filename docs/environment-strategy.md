# Environment Strategy

## Purpose

The platform must provide five logical environments without maintaining
environment-specific Git branches or duplicating the complete infrastructure
stack. The environments are therefore organized into three promotion stages and
isolated with Kubernetes namespaces in a shared K3s cluster.

## Promotion Stages

| Promotion stage | Logical environment | Kubernetes namespace | Purpose |
| --- | --- | --- | --- |
| Non-production | Development | `bookstore-dev` | Developer integration and rapid feedback |
| Non-production | Test | `bookstore-test` | Internal QA and automated end-to-end testing |
| Pre-production | Performance | `bookstore-perf` | Performance and capacity checks |
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
five logical environments.

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

- Development and test deployments are automatic after their required checks pass.
- Performance deployment uses the same immutable image promoted from test.
- Staging requires a GitHub Environment approval.
- Production requires a separate GitHub Environment approval.
- Open Policy Agent policies verify that staging and production are configured
  with approval requirements.
- Gitleaks runs before any deployment and OPA verifies that the pipeline includes
  the required secret-scanning control.

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
- one external load balancer;
- separate Kubernetes namespaces for workload isolation.

This is a cost-conscious demonstration design. Separate clusters or accounts
would be preferred for strongly isolated production systems, but are outside the
scope of this one-week exercise.
