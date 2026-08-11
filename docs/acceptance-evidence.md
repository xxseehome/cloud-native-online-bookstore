# Acceptance Evidence

This file is updated after the final `main` commit is promoted. Every
deployment row must use the same full 40-character image SHA. Replace the
`TBD` links only with the final run URLs; do not record credentials, tokens,
private keys, account numbers or unredacted console data.

## Release identity

| Item | Value |
| --- | --- |
| Main commit | `TBD after merge` |
| Backend image tag | `TBD after final CI` |
| Frontend image tag | `TBD after final CI` |
| Registry | Hangzhou ACR Personal (GHCR publication fallback) |
| Cluster | One K3s server on Alibaba Cloud ECS, `cn-hangzhou` |
| External entry point | Existing CLB trial public IP + Traefik HTTP ingress |

## CI and security gates

| Gate | Final evidence |
| --- | --- |
| Ruff lint and format | `TBD` |
| Gitleaks | `TBD` |
| Trivy filesystem and images | `TBD` |
| OPA/Conftest Kubernetes and workflow policy | `TBD` |
| Unit tests and manifest render | `TBD` |
| Image publication | `TBD` |
| Terraform plan | `TBD` — must show `0 add / 0 change / 0 destroy` |

## Five-environment promotion

| Order | Environment | Namespace | Final workflow run | Result |
| ---: | --- | --- | --- | --- |
| 1 | Development | `bookstore-dev` | `TBD` | Pending final SHA |
| 2 | Test | `bookstore-test` | `TBD` | Pending final SHA |
| 3 | Performance | `bookstore-perf` | `TBD` | Pending final SHA |
| 4 | Staging | `bookstore-staging` | `TBD` | Pending final SHA |
| 5 | Production | `bookstore-production` | `TBD` | Pending final SHA |

## Resilience and runtime evidence

| Check | Final evidence |
| --- | --- |
| Staging approval and resilience workflow | `TBD` |
| Two Ready backend/frontend replicas after one-Pod deletions | `TBD` |
| Zero HTTP probe failures during the exercise | `TBD` |
| K3s systemd service enabled and active | `TBD` |
| CLB listener and backend health | `TBD` |
| Homepage, `/health`, and `/api/books` return HTTP 200 | `TBD` |
| Prometheus/Grafana rollout and health | `TBD` |

## Screenshot inventory

Final redacted screenshots are stored under `docs/evidence/` and linked here:

1. `TBD` — final CI with Ruff, Gitleaks, Trivy, OPA and publication.
2. `TBD` — Terraform plan/apply summary and zero-change plan.
3. `TBD` — five promotion runs and the common image SHA.
4. `TBD` — staging Pod resilience output and approval.
5. `TBD` — CLB listener health and public homepage/health response.
6. `TBD` — Prometheus/Grafana runtime status.

Screenshots complement the immutable GitHub Actions links; they are not a
substitute for the run summaries or the final repository state.

## Accepted limitation

This is workload self-healing on one ECS/K3s node. ECS, system-disk, K3s
server, and availability-zone failure can still interrupt service. K3s
node-level HA is intentionally not claimed because it requires at least three
server nodes and would violate the no-new-paid-resources constraint.
