# Kubernetes deployment

The shared K3s cluster hosts three namespace-isolated environments:

| Environment | Namespace | Ingress host |
| --- | --- | --- |
| Development | `bookstore-dev` | `dev.bookstore.example.com` |
| Staging | `bookstore-staging` | `staging.bookstore.example.com` |
| Production | `bookstore-production` | `bookstore.example.com` |

The base contains the backend and frontend Deployments, internal Services, and
Traefik Ingress. Each overlay supplies the namespace, hostname, and replica count.

Run **Kubernetes Deploy** from GitHub Actions with an environment and the full
commit SHA published by the main CI workflow. The workflow authenticates to
Alibaba Cloud with OIDC and uses ECS Cloud Assistant to run `kubectl` locally on
the K3s node. The Kubernetes API therefore remains closed to the public internet,
and no long-lived SSH or cloud access key is stored in GitHub.

Before staging or production deployment, configure the matching GitHub
Environment with required reviewers. Public DNS names can replace the example
hosts when a domain is available.
