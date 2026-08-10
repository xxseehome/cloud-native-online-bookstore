# CI Security Controls

The main CI workflow runs three security controls before the image publication
job. A failure in any control blocks both GHCR/ACR publication and subsequent
Kubernetes promotion.

| Control | Pinned tool | Scope | Failure threshold |
| --- | --- | --- | --- |
| Secret detection | Gitleaks 8.30.0 | Checked-out repository tree and pull-request contents | Any detected secret |
| Vulnerability and configuration scan | Trivy 0.70.0 | Source, Terraform, Kubernetes files, backend image, frontend image | High or critical findings that are fixable |
| Policy validation | OPA via Conftest 0.56.0 | Kustomize output for all five environments | Any policy denial |

The workflow downloads release archives from the projects' official GitHub
releases and verifies their published SHA-256 checksum before execution. It does
not use floating `latest` scanner tags. The repository Gitleaks config only
allowlists GitHub Actions expressions such as `${{ secrets.ACR_PASSWORD }}`;
actual credential values remain blocked.

## OPA policy guarantees

The Rego policy in `policies/kubernetes.rego` requires that each application
Deployment:

- uses a full 40-character commit SHA image from the Hangzhou ACR repository;
- disables privilege escalation, runs as non-root, and drops all capabilities;
- declares CPU and memory requests and limits; and
- uses the `RuntimeDefault` seccomp profile.

It also requires the expected application label on namespaces and the managed
Traefik ingress class.

The CI job renders `development`, `test`, `perf`, `staging`, and `production`
before running Conftest, so a policy change is evaluated against every
environment overlay.
