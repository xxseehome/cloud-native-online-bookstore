# Alibaba Cloud Terraform Foundation

This directory defines the cost-conscious Alibaba Cloud foundation for the
Online Book Store demonstration. Pull requests validate the configuration but
never receive cloud credentials or run `terraform apply`.

## Managed resources

- one VPC and one vSwitch per supplied availability zone;
- one security group with restricted SSH and optional K3s API access;
- one pay-as-you-go ECS instance bootstrapped as a single-node K3s cluster;
- one private, encrypted, versioned OSS bucket;
- the existing Hangzhou CLB (SLB family) trial, only after it is adopted.

Five application environments are Kubernetes namespaces in this shared stack;
they are not five copies of Alibaba Cloud infrastructure.

## Module layout

```text
terraform/
├── modules/
│   ├── slb/       # Existing CLB listener and ECS backend integration
│   ├── compute/   # ECS and pinned K3s bootstrap
│   ├── network/   # VPC, vSwitches and security rules
│   └── storage/   # Private OSS bucket
├── tests/         # Mock-provider safety tests
└── *.tf           # Shared demonstration stack
```

ALB and NLB modules are intentionally not present. They are documented as
future options only; no new load-balancer or EIP resource is created by this
plan.

## Cost controls

- `enable_slb` defaults to `false`; the existing CLB trial is enabled only
  after its console-created instance is imported.
- ECS uses `PostPaid`, `PayByTraffic`, a bounded egress rate and
  `StopCharging` when stopped.
- SSH and the optional K3s API reject `0.0.0.0/0` for every allowed CIDR.
- ECS and OSS have `prevent_destroy` guards against accidental data loss.
- No NAT Gateway, RDS, ACK, SLS or paid KMS instance is created.
- The final reviewed Terraform plan must be exactly `0 add / 0 change / 0
  destroy`; stop before apply if it is not.

Free-trial limits are account entitlements, not Terraform guarantees. Confirm
the ECS, OSS, CLB and traffic line items in the Alibaba Cloud console before a
real plan/apply and release trial resources before their expiry dates.

## Validate without creating resources

```shell
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
terraform test
```

The provider lock file is committed so CI resolves the same provider version on
every runner. The GitHub deployment guide covers OIDC, encrypted OSS state,
plan artifacts, protected approval and the one-time state-only adoption flow.

## CLB trial adoption

The Alibaba Cloud console creates the CLB trial before Terraform can manage it.
After the VPC, vSwitch and ECS foundation exist:

1. activate the existing Hangzhou CLB trial;
2. set `TF_ENABLE_SLB=true` and `TF_EXISTING_SLB_ID=<trial-clb-id>` in GitHub
   repository variables;
3. run **Terraform Adopt Existing Resources** and confirm the ECS instance;
4. run a plan-only **Terraform Deploy** and require `0 add / 0 change / 0
   destroy` before any apply.

The managed CLB module then owns the HTTP listener, `/health` health check,
virtual server group and ECS backend attachment. ALB/NLB trials must remain
unactivated under the no-new-resource constraint.
