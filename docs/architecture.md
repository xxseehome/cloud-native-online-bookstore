# Platform Architecture

This document is the implementation view of the Online Book Store platform.
The running demonstration uses one Alibaba Cloud ECS instance in Hangzhou with
K3s. Five application environments are namespaces in that cluster; they are not
five separate ECS or Kubernetes clusters.

## Application architecture

```mermaid
flowchart LR
    User[Browser user] --> IP[ECS public IP :80]
    IP --> Traefik[Traefik Ingress in K3s]
    Traefik --> Frontend[bookstore-frontend\nNginx :80]
    Traefik --> Backend[bookstore-backend\nFastAPI :8000]
    Frontend -->|/api and /health| Backend
    Backend -.->|optional future object storage| OSS[(Private OSS bucket)]
```

The current catalog is an in-memory demonstration dataset. The private OSS
bucket is provisioned by Terraform as the storage foundation and is not needed
for the current read-only API path. The ingress host is represented by the ECS
public IP for this cost-controlled demonstration, so a DNS name and TLS
certificate are deliberately out of scope.

## Infrastructure architecture

```mermaid
flowchart TB
    subgraph Alibaba[Alibaba Cloud - cn-hangzhou]
        VPC[VPC 10.20.0.0/16]
        VS[vSwitches]
        SG[Security Group\nHTTP public; SSH restricted]
        ECS[ECS instance\nUbuntu 22.04\nK3s single node]
        OSS[(OSS\nprivate, encrypted, versioned)]
        ACR[ACR Personal\nbackend/frontend images]
        VPC --> VS --> SG --> ECS
        ECS -. intranet endpoint .-> OSS
        ECS -->|pull by immutable tag| ACR
    end
    subgraph K3s[K3s cluster on ECS]
        T[Traefik Ingress]
        N1[bookstore-dev]
        N2[bookstore-test]
        N3[bookstore-perf]
        N4[bookstore-staging]
        N5[bookstore-production]
        MON[monitoring namespace\nPrometheus + Grafana]
        T --> N1
        T --> N2
        T --> N3
        T --> N4
        T --> N5
        MON -.->|observes| N1
        MON -.->|observes| N2
        MON -.->|observes| N3
        MON -.->|observes| N4
        MON -.->|observes| N5
    end
    ECS --> K3s
```

Terraform manages the VPC, vSwitch, security group, adopted ECS foundation,
K3s bootstrap inputs, and OSS bucket. `enable_alb` is `false`, so no ALB/SLB is
created in this deployment. The ECS public IP avoids an additional load
balancer charge while the account-specific free-trial entitlement is being
verified. ALB can be enabled later only after its entitlement, two vSwitches,
and import path are confirmed.

## Delivery pipeline

```mermaid
flowchart LR
    PR[Pull request] --> Checks[CI checks]
    Checks --> Secrets[Gitleaks]
    Checks --> Vuln[Trivy image/config scan]
    Checks --> Policy[OPA/Conftest]
    Checks --> Tests[Backend tests + manifest/Terraform validation]
    Secrets & Vuln & Policy & Tests --> Build[Build frontend/backend once]
    Build --> GHCR[GHCR]
    Build --> ACR[Hangzhou ACR mirror]
    ACR --> SHA[Immutable commit SHA]
    SHA --> D[Development]
    D --> T[Test]
    T --> P[Performance]
    P --> SA[Staging approval]
    SA --> S[Staging]
    S --> PA[Production approval]
    PA --> Prod[Production]
```

The deployment workflow accepts only a full 40-character Git SHA. Kustomize
renders the selected namespace, the same image reference is used in every
stage, and the protected `terraform-apply` environment gates the cloud apply.
ECS Cloud Assistant performs the idempotent K3s apply, rollout checks, HTTP
smoke tests, and monitoring smoke test.
