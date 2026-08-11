# Senior Platform Engineer Test Compliance

This matrix maps the required test evidence to the repository and the live
demonstration. The source requirements are recorded in the supplied
`sr-platform-engineer-test.pdf`.

| Requirement | Implementation | Evidence | Status |
| --- | --- | --- | --- |
| Multi-tier application | Nginx frontend, FastAPI backend and Traefik routing | `docs/architecture.md`, Kustomize overlays, HTTP smoke tests | Satisfied |
| Infrastructure as Code | Terraform modules for VPC, vSwitch/security group, adopted ECS, CLB integration and OSS | `terraform/`, Terraform CI and plan/apply run | Satisfied |
| Five environments | Development, test, perf, staging and production namespaces | `kubernetes/overlays/`, `docs/environment-strategy.md` | Satisfied |
| Infrastructure pipeline | Format, validate, mocked tests, OIDC plan, protected apply | `.github/workflows/terraform*.yml`, Terraform run summary | Satisfied |
| Service pipeline | Unit tests, Ruff, manifest render, Gitleaks, Trivy, OPA, one build and SHA promotion | `.github/workflows/ci.yml`, `kubernetes-deploy.yml` | Satisfied |
| Policy as Code | Kubernetes policy plus workflow gate policy, with positive/negative Rego tests | `policies/*.rego`, `conftest verify` | Satisfied |
| Immutable promotion | Full 40-character commit SHA is built once and used in all five environments | Deployment input validation and promotion run links | Satisfied |
| Workload resilience | Two replicas in perf/staging/production, safe rolling updates and manual staging Pod deletion check | `kubernetes-resilience.yml`, resilience run summary | Satisfied with single-node limitation |
| Load balancing | Existing Hangzhou CLB trial provides stable HTTP entry and health check | `docs/architecture.md`, CLB listener evidence | Satisfied |
| Node-level HA | Not implemented | One ECS/K3s server; three-server K3s HA would add capacity/cost | Explicit limitation |
| Documentation and diagrams | Application, infrastructure, pipeline, failure-domain and load-balancer decision diagrams | `docs/architecture.md` | Satisfied |
| Acceptance material | Redacted CI, Terraform, promotion, CLB, application, resilience and monitoring screenshots | `docs/evidence/` and `docs/acceptance-evidence.md` | Satisfied |

## Out of scope

Multi-region, multi-cloud, purchased DNS/TLS, a database, Terraform Cloud,
node-level K3s HA, and new ALB/NLB/EIP resources are optional extensions and
are not required for this cost-controlled submission.

## Cost boundary

The plan creates no new ECS, ALB, NLB, EIP or database. The existing ECS, OSS
and CLB trials remain subject to their account quotas and expiry dates. Budget
alerts are notifications, not a billing cap; release the trial resources before
their end dates if the demonstration is no longer needed.
