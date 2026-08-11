# Acceptance Evidence

This file records the final `main` promotion. Every deployment row uses the
same full 40-character image SHA. Run links are immutable GitHub evidence; do
not record credentials, tokens, private keys, account numbers or unredacted
console data.

## Release identity

| Item | Value |
| --- | --- |
| Main commit | `2e637aa46b2756b9d732dd20d9132f3e26e390f8` |
| Backend image tag | `2e637aa46b2756b9d732dd20d9132f3e26e390f8` |
| Frontend image tag | `2e637aa46b2756b9d732dd20d9132f3e26e390f8` |
| Registry | Hangzhou ACR Personal (GHCR publication fallback) |
| Cluster | One K3s server on Alibaba Cloud ECS, `cn-hangzhou` |
| External entry point | Existing CLB trial `8.154.33.8:80` + Traefik HTTP ingress |

## CI and security gates

| Gate | Final evidence |
| --- | --- |
| Ruff lint and format | [Main CI run 130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31472774773) — passed |
| Gitleaks | [Main CI run 130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31472774773) — passed |
| Trivy filesystem and images | [Main CI run 130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31472774773) — passed |
| OPA/Conftest Kubernetes and workflow policy | [Main CI run 130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31472774773) — passed |
| Unit tests and manifest render | [Main CI run 130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31472774773) — passed |
| Image publication | [Main CI run 130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31472774773) — GHCR and ACR published |
| Terraform plan | [Terraform Deploy #10](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31473211142) — `No changes` (0 add / 0 change / 0 destroy) |

## Five-environment promotion

| Order | Environment | Namespace | Final workflow run | Result |
| ---: | --- | --- | --- | --- |
| 1 | Development | `bookstore-dev` | [Kubernetes Deploy #50](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31473350545) | Success; SHA verified |
| 2 | Test | `bookstore-test` | [Kubernetes Deploy #51](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31474129608) | Success; SHA verified |
| 3 | Performance | `bookstore-perf` | [Kubernetes Deploy #52](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31474747227) | Success; SHA verified |
| 4 | Staging | `bookstore-staging` | [Kubernetes Deploy #53](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31475163994) | Success; SHA verified |
| 5 | Production | `bookstore-production` | [Kubernetes Deploy #54](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31475640231) | Success; SHA verified |

## Resilience and runtime evidence

| Check | Final evidence |
| --- | --- |
| Staging approval and resilience workflow | [Kubernetes Resilience Check #1](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31476043213) — passed |
| Two Ready backend/frontend replicas after one-Pod deletions | [Resilience run](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31476043213) — passed |
| Zero HTTP probe failures during the exercise | [Resilience run](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31476043213) — passed |
| K3s systemd service enabled and active | [Resilience run](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31476043213) — passed |
| CLB listener and backend health | [CLB console screenshot](evidence/clb-listener-health.png) — `HTTP:80` running/healthy |
| Homepage, `/health`, and `/api/books` return HTTP 200 | `http://8.154.33.8/`, `/health`, `/api/books` — all HTTP 200 |
| Prometheus/Grafana rollout and health | [Production deploy job](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31475640231/job/93728630993) — monitoring smoke test passed |

## Screenshot inventory

Final redacted screenshots are stored under `docs/evidence/` and linked here:

1. [ci-security-gates.png](evidence/ci-security-gates.png) — final CI with Ruff, Gitleaks, Trivy, OPA and publication.
2. [terraform-noop-plan.png](evidence/terraform-noop-plan.png) — Terraform plan summary with no changes.
3. [five-environment-promotion.png](evidence/five-environment-promotion.png) — five successful promotion runs.
4. [staging-resilience.png](evidence/staging-resilience.png) — staging Pod resilience approval and success.
5. [clb-listener-health.png](evidence/clb-listener-health.png) — CLB listener and health status.
6. [application-homepage.png](evidence/application-homepage.png) — public application homepage; HTTP endpoint checks are recorded above.
7. [monitoring-runtime.png](evidence/monitoring-runtime.png) — production deployment job with monitoring rollout evidence.

Screenshots complement the immutable GitHub Actions links; they are not a
substitute for the run summaries or the final repository state.

## Accepted limitation

This is workload self-healing on one ECS/K3s node. ECS, system-disk, K3s
server, and availability-zone failure can still interrupt service. K3s
node-level HA is intentionally not claimed because it requires at least three
server nodes and would violate the no-new-paid-resources constraint.
