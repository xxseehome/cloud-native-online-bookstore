# Terraform Deployment from GitHub

The infrastructure pipeline runs entirely on GitHub-hosted runners. It uses
short-lived Alibaba Cloud credentials obtained through GitHub OIDC, stores state
in encrypted OSS, serializes Terraform runs through GitHub Actions, and pauses
before `apply` at a protected GitHub Environment.

No Alibaba Cloud AccessKey is stored in GitHub.

## Pipeline

```text
workflow_dispatch on main
        |
        v
terraform-plan environment
        |
        +-- GitHub OIDC -> read-only RAM role
        +-- remote OSS state
        +-- terraform plan
        +-- one-day immutable plan artifact
        |
        v
terraform-apply environment
        |
        +-- required reviewer approval
        +-- GitHub OIDC -> deployment RAM role
        +-- apply the exact saved plan
```

The `apply` workflow input defaults to `false`. A plan-only run never enters the
approval or apply job.

## 1. Bootstrap remote state in Alibaba Cloud

Create these once in the Alibaba Cloud console:

1. a dedicated private OSS bucket for Terraform state;
2. versioning and AES256 server-side encryption on the bucket.

Do not reuse the application asset bucket. Restrict the state bucket to the
Terraform RAM roles and account administrators.

## 2. Configure GitHub as an Alibaba Cloud OIDC identity provider

In Alibaba Cloud RAM, create an OIDC identity provider with:

- issuer URL: `https://token.actions.githubusercontent.com`;
- audience: `sts.aliyuncs.com`;
- the signing keys discovered from the issuer metadata.

Create two RAM roles that trust this provider:

- a plan role with read-only resource access plus the OSS permissions required
  to read state;
- an apply role with only the VPC, ECS, OSS, ALB, RAM key-pair, and state access
  required by this repository.

Restrict the role trust conditions to these exact GitHub OIDC subjects:

```text
repo:xxseehome/cloud-native-online-bookstore:environment:terraform-plan
repo:xxseehome/cloud-native-online-bookstore:environment:terraform-apply
```

Do not attach `AdministratorAccess` to either role.

## 3. Configure GitHub Environments

In **Settings -> Environments**, create:

### `terraform-plan`

- allow deployments only from `main`;
- no required reviewer is necessary;
- store the `TF_SSH_PUBLIC_KEY` environment secret here.

### `terraform-apply`

- allow deployments only from `main`;
- add a required reviewer;
- keep self-review disabled when a second reviewer is available.
- store the same `TF_SSH_PUBLIC_KEY` environment secret used by
  `terraform-plan`; the state-adoption workflow evaluates the full
  configuration but never writes the private key to state.

The apply job cannot start until this environment approves it.

## 4. Configure repository variables

In **Settings -> Secrets and variables -> Actions -> Variables**, add:

| Variable | Example or meaning |
| --- | --- |
| `ALICLOUD_REGION` | `cn-hangzhou` |
| `ALICLOUD_OIDC_PROVIDER_ARN` | RAM OIDC provider ARN |
| `ALICLOUD_PLAN_ROLE_ARN` | Read-only Terraform role ARN |
| `ALICLOUD_APPLY_ROLE_ARN` | Terraform deployment role ARN |
| `TF_STATE_BUCKET` | Dedicated state bucket name |
| `TF_STATE_KEY` | `shared/terraform.tfstate` |
| `TF_STATE_REGION` | State bucket region, for example `cn-shanghai` |
| `TF_AVAILABILITY_ZONES` | `["cn-hangzhou-i"]` for the adopted vSwitch |
| `TF_VPC_CIDR` | `172.16.0.0/12` for the adopted default VPC |
| `TF_VSWITCH_CIDRS` | `["172.20.128.0/20"]` for the adopted vSwitch |
| `TF_SSH_INGRESS_CIDRS` | JSON list of current Alibaba Cloud Workbench CIDRs; never include `0.0.0.0/0` |
| `TF_K3S_API_INGRESS_CIDRS` | `[]` when kubectl runs on the node |
| `TF_INSTANCE_TYPE` | Exact ECS free-trial instance type |
| `TF_IMAGE_ID` | Exact Ubuntu image ID in the selected region |
| `TF_INTERNET_MAX_BANDWIDTH_OUT` | `100` to preserve the trial instance configuration; traffic limits still apply |
| `TF_OSS_BUCKET_NAME` | Globally unique application bucket name |
| `TF_ENABLE_ALB` | `false` until the ALB trial/import is ready |
| `TF_ENABLE_SLB` | `false` until the SLB free-trial instance is imported |
| `TF_EXISTING_SLB_ID` | Trial SLB ID from the Hangzhou console; required only when `TF_ENABLE_SLB=true` |
| `TF_EXISTING_VPC_ID` | `vpc-bp15izs541lrz2xnc2b7j` |
| `TF_EXISTING_VSWITCH_ID` | `vsw-bp1d2g0o04pfsnxdp0y3a` |
| `TF_EXISTING_SECURITY_GROUP_ID` | `sg-bp1e67jdt4t6c9y90298` |
| `TF_EXISTING_INSTANCE_ID` | `i-bp1e67jdt4t6c9y8kbgt` |

JSON list values must remain valid JSON, including the brackets and quotes.
`TF_STATE_REGION` is independent from `ALICLOUD_REGION`; this allows the state
bucket to remain in Shanghai while the demonstration stack runs in Hangzhou.

For the current Hangzhou Workbench configuration, set
`TF_SSH_INGRESS_CIDRS` to:

```json
["47.96.60.0/24","118.31.243.0/24","8.139.112.0/24","8.139.99.192/26"]
```

Reconfirm these service ranges in Alibaba Cloud documentation before reusing
the configuration in another account or region.

## 5. Adopt the console-created free-trial resources once

The ECS free-trial flow created the VPC, vSwitch, security group, and instance
before Terraform state existed. The SLB trial is also created in the console
before Terraform state exists. Do not run a normal apply until the existing
resources are adopted.

1. Open **Actions -> Terraform Adopt Existing Resources -> Run workflow**.
2. Select `main` and enter `i-bp1e67jdt4t6c9y8kbgt` as the confirmation.
3. Approve the protected `terraform-apply` environment deployment.
4. Confirm the summary lists these four addresses:

   ```text
   module.network.alicloud_vpc.this
   module.network.alicloud_vswitch.this[0]
   module.network.alicloud_security_group.k3s
   module.compute.alicloud_instance.k3s
   ```

   When `TF_ENABLE_SLB=true`, the summary must also include:

   ```text
   module.slb[0].alicloud_slb_load_balancer.this
   ```

The workflow is idempotent, rejects an existing state address that points to a
different resource ID, and never runs `terraform apply`. OSS application
storage, Terraform-managed security-group rules, and the SSH key pair remain
unmanaged until a later reviewed plan is applied.

## 6. Run from the GitHub website

1. Open **Actions -> Terraform Deploy -> Run workflow**.
2. Select `main` and leave **Apply** unchecked.
3. Review the plan in the run summary.
4. After the plan is cost-safe, run the workflow again with **Apply** checked.
5. Review and approve the `terraform-apply` environment deployment.

For the first plan after adoption, expect differences in names, tags, security
rules, the SSH key pair, and K3s bootstrap configuration. Do not apply until the
plan contains no ECS replacement or deletion. After the restricted Workbench
SSH rules are applied and tested, remove the original manual SSH rule that
allows `0.0.0.0/0`.

The plan artifact expires after one day and the apply job consumes the exact plan
created earlier in the same workflow run.

## Safety boundaries

- Pull requests never receive cloud credentials and cannot apply resources.
- Only manually dispatched runs from `main` are accepted.
- GitHub serializes this shared infrastructure pipeline; runs are never canceled
  while an apply may be in progress.
- OIDC credentials expire after 30 minutes.
- Remote state is private, encrypted, and versioned.
- The OSS backend has no backend-level lock. Run Terraform only through these
  workflows. Production environments should add Tablestore locking.
- ALB and SLB remain disabled by default until the selected trial resource can
  be imported. Never enable both flags.
- Resource adoption writes remote Terraform state but never changes Alibaba
  Cloud resources; the protected environment provides an explicit approval.
