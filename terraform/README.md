# Alibaba Cloud Terraform Foundation

This directory defines the cost-conscious Alibaba Cloud foundation for the
Online Book Store demonstration. It is intentionally safe to validate without
cloud credentials and does not run `terraform apply` in pull requests.

## Managed resources

- one VPC;
- one vSwitch per supplied availability zone;
- one security group with restricted SSH and K3s API access;
- one pay-as-you-go ECS instance bootstrapped as a single-node K3s cluster;
- one private, encrypted, versioned OSS bucket;
- an optional internet-facing ALB, disabled by default.

Five application environments are Kubernetes namespaces in this shared stack.
They are not five copies of the Alibaba Cloud infrastructure.

## Module layout

```text
terraform/
├── modules/
│   ├── alb/       # Optional ALB foundation
│   ├── compute/   # ECS, SSH key and pinned K3s bootstrap
│   ├── network/   # VPC, vSwitches and security rules
│   └── storage/   # Private OSS bucket
├── tests/         # Mock-provider safety tests
└── *.tf           # Shared demonstration stack
```

## Cost controls

- `enable_alb` defaults to `false`.
- ECS uses `PostPaid`, `PayByTraffic`, a bounded egress rate and
  `StopCharging` when stopped.
- SSH and the K3s API reject `0.0.0.0/0` as the administrator CIDR.
- ECS and OSS have `prevent_destroy` guards against accidental data loss.
- ALB requires two availability zones and also has deletion protection.
- No NAT Gateway, RDS, ACK, SLS or paid KMS instance is created.
- Pull-request CI runs only formatting, initialization, validation and mocked
  plans. It has no Alibaba Cloud credentials and cannot create resources.

Free-trial limits are account entitlements, not Terraform guarantees. Confirm
the ECS, OSS, ALB, EIP and traffic line items in the Alibaba Cloud console before
every real apply.

## Prepare values in the browser

1. Use Alibaba Cloud Cloud Shell to generate an SSH key if required:

   ```shell
   ssh-keygen -t ed25519 -C bookstore-admin
   ```

2. Copy only the `.pub` value. Keep the private key out of GitHub and Terraform
   state.
3. In the ECS free-trial page, select `cn-hangzhou` and record the exact
   2-vCPU/4-GiB instance type, available zones, and Ubuntu 22.04 x86_64 image ID.
4. Choose a globally unique OSS bucket name for the 20-GB local-redundancy
   trial.
5. Copy the example locally and replace every placeholder:

   ```shell
   cp terraform.tfvars.example terraform.tfvars
   ```

`terraform.tfvars` is ignored by Git and must never be committed.

## Validate without creating resources

```shell
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform test
```

Cloud deployment is intentionally separate from pull-request validation. See
[Terraform Deployment from GitHub](../docs/terraform-deployment.md) for the OIDC
identity, remote state, plan artifact, approval, and controlled apply workflow.

## ALB trial import path

The Alibaba Cloud ALB trial automatically creates an ALB and two EIPs, which
means it cannot initially be created by this configuration. After the VPC and
vSwitches exist:

1. activate the ALB trial against those vSwitches;
2. set `enable_alb = true`;
3. import the trial ALB before any apply:

   ```shell
   terraform import 'module.alb[0].alicloud_alb_load_balancer.this' <alb-id>
   ```

The two EIPs and listener/backend resources will be modeled in the networking
integration phase after the trial-generated resource IDs are known.
