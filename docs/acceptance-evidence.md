# Acceptance Evidence

## Release identity

| Item | Value |
| --- | --- |
| Main commit | [`e58691acb4d4e37a8f957e3df5b71b4802eeba1a`](https://github.com/xxseehome/cloud-native-online-bookstore/commit/e58691acb4d4e37a8f957e3df5b71b4802eeba1a) |
| Backend image tag | `e58691acb4d4e37a8f957e3df5b71b4802eeba1a` |
| Frontend image tag | `e58691acb4d4e37a8f957e3df5b71b4802eeba1a` |
| Registry | Hangzhou ACR Personal (GHCR is the build/publish fallback) |
| Cluster | One K3s node on Alibaba Cloud ECS, `cn-hangzhou` |
| External entry point | CLB (SLB) trial public IP + Traefik HTTP ingress; production has an IP-only fallback route |

The deployment workflow rejects tags that are not full 40-character commit
SHAs. Every row below therefore points to a promotion run using the exact same
release identity.

## CI and security gates

| Gate | Evidence |
| --- | --- |
| Gitleaks | [Main CI run 31393791861](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31393791861) — passed |
| Trivy image/config scan | [Main CI run 31393791861](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31393791861) — passed |
| OPA/Conftest | [Main CI run 31393791861](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31393791861) — passed |
| Unit tests, manifest and Terraform validation | [Main CI run 31393791861](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31393791861) — passed |
| Image publication | [Main CI run 31393791861](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31393791861) — GHCR and Hangzhou ACR publication passed |

## Five-environment promotion

| Environment | Namespace | Workflow run | Result |
| --- | --- | --- | --- |
| Development | `bookstore-dev` | [31395778130](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31395778130) | Passed |
| Test | `bookstore-test` | [31396564930](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31396564930) | Passed |
| Performance | `bookstore-perf` | [31397092693](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31397092693) | Passed |
| Staging | `bookstore-staging` | [31441986475](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31441986475) | Passed after idempotent K3s API retry |
| Production | `bookstore-production` | [31442639321](https://github.com/xxseehome/cloud-native-online-bookstore/actions/runs/31442639321) | Passed |

Each successful deployment records the HTTP smoke-test and monitoring smoke-test
messages in the `Deploy through ECS Cloud Assistant` step. Staging and
production also show the `terraform-apply` approval event in the run page.
Earlier transient retry failures are intentionally not listed as promotion
evidence; the table links only to the successful run for each namespace.

## Screenshot capture checklist

The linked run pages are the canonical, reproducible evidence. For a review
package, capture the following visible pages and store them with the release
notes (do not put credentials or tokens in screenshots):

1. Main CI summary showing Gitleaks, Trivy, OPA, tests, and image publication.
2. Development/Test/Performance run summaries showing green jobs and the full
   SHA link.
3. Staging and Production run summaries showing the approval event and green
   `Deploy through ECS Cloud Assistant` job.
4. The application page at `http://<CLB-public-IP>/` and the `/health` response.
5. Grafana/monitoring rollout and smoke-test output from the same deployment.

These screenshots complement, rather than replace, the immutable GitHub
Actions links above.
