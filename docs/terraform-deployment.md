# Terraform Deployment from GitHub

The infrastructure pipeline runs entirely on GitHub-hosted runners. It uses
short-lived Alibaba Cloud credentials obtained through GitHub OIDC, stores state
in encrypted OSS, locks state with Tablestore, and pauses before `apply` at a
protected GitHub Environment.

No Alibaba Cloud AccessKey is stored in GitHub.

## Pipeline

```text
workflow_dispatch on main
        |
        v
terraform-plan environment
        |
        +-- GitHub OIDC -> read-only RAM role
        +-- remote OSS state + Tablestore lock
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
2. versioning and AES256 server-side encryption on the bucket;
3. a Tablestore instance in the same region;
4. a Tablestore table whose primary key is named `LockID` and has type `String`.

Do not reuse the application asset bucket. Restrict the state bucket and lock
table to the Terraform RAM roles and account administrators.

## 2. Configure GitHub as an Alibaba Cloud OIDC identity provider

In Alibaba Cloud RAM, create an OIDC identity provider with:

- issuer URL: `https://token.actions.githubusercontent.com`;
- audience: `sts.aliyuncs.com`;
- the signing keys discovered from the issuer metadata.

Create two RAM roles that trust this provider:

- a plan role with read-only resource access plus the OSS/Tablestore permissions
  required to read and lock state;
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

The apply job cannot start until this environment approves it.

## 4. Configure repository variables

In **Settings -> Secrets and variables -> Actions -> Variables**, add:

| Variable | Example or meaning |
| --- | --- |
| `ALICLOUD_REGION` | `cn-hongkong` |
| `ALICLOUD_OIDC_PROVIDER_ARN` | RAM OIDC provider ARN |
| `ALICLOUD_PLAN_ROLE_ARN` | Read-only Terraform role ARN |
| `ALICLOUD_APPLY_ROLE_ARN` | Terraform deployment role ARN |
| `TF_STATE_BUCKET` | Dedicated state bucket name |
| `TF_STATE_KEY` | `shared/terraform.tfstate` |
| `TF_STATE_TABLESTORE_ENDPOINT` | HTTPS endpoint of the lock instance |
| `TF_STATE_TABLESTORE_TABLE` | Lock table name |
| `TF_AVAILABILITY_ZONES` | `["cn-hongkong-b","cn-hongkong-c"]` |
| `TF_VSWITCH_CIDRS` | `["10.20.1.0/24","10.20.2.0/24"]` |
| `TF_ADMIN_CIDR` | Your current public IPv4 address with `/32` |
| `TF_INSTANCE_TYPE` | Exact ECS free-trial instance type |
| `TF_IMAGE_ID` | Exact Ubuntu image ID in the selected region |
| `TF_OSS_BUCKET_NAME` | Globally unique application bucket name |
| `TF_ENABLE_ALB` | `false` until the ALB trial/import is ready |

JSON list values must remain valid JSON, including the brackets and quotes.

## 5. Run from the GitHub website

1. Open **Actions -> Terraform Deploy -> Run workflow**.
2. Select `main` and leave **Apply** unchecked.
3. Review the plan in the run summary.
4. After the plan is cost-safe, run the workflow again with **Apply** checked.
5. Review and approve the `terraform-apply` environment deployment.

The plan artifact expires after one day and the apply job consumes the exact plan
created earlier in the same workflow run.

## Safety boundaries

- Pull requests never receive cloud credentials and cannot apply resources.
- Only manually dispatched runs from `main` are accepted.
- GitHub serializes this shared infrastructure pipeline; runs are never canceled
  while an apply may be in progress.
- OIDC credentials expire after 30 minutes.
- Remote state is private, encrypted, versioned, and locked.
- ALB remains disabled by default until its trial resources can be imported.
