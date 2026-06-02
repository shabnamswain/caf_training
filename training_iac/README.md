# Training IaC - Azure Landing Zones

Overview
- This repository contains Terraform code and Azure DevOps pipelines to provision three landing zones for training: `platform`, `connectivity`, and `sandbox`.
- Each landing zone uses a shared backend (Azure Storage account + container) for state files.

Repository layout (important folders)
- `training_iac/caf_lz/platform_lz/` — Terraform code for the platform landing zone.
- `training_iac/caf_lz/connectivity_lz/` — Terraform code for connectivity landing zone.
- `training_iac/caf_lz/sandbox_lz/` — Terraform code for sandbox landing zone (per-user instances supported).
- `training_iac/landingzone_tfvars/` — tfvars files for each landing zone: `platform.tfvars`, `connectivity.tfvars`, `sandbox.tfvars`.
- `training_iac/modules/` — Reusable Terraform modules (resource_group, virtual_network, storage_account, etc.).
- `training_iac/pipelines/azure-pipelines.yml` — Azure DevOps pipeline that bootstraps backend, runs `terraform init`, `plan`, and `apply` per environment.

Key concepts
- Single Azure DevOps service connection: the pipeline expects one service connection variable named `tf-service-connection` (change `variables.serviceConnection` in the pipeline if you use a different name).
Portal (simplest)

Project settings → Service connections → New service connection → Azure Resource Manager.
Choose "Service principal (manual)" or "automatic" and give it the name tf-service-connection (or change serviceConnection in the YAML to match your name).
Grant the SP the required role (e.g., Contributor) on the target subscription/resource scope.
- Remote state backend: an Azure Storage account container is used. Backend settings are set during pipeline `terraform init`.
- Sandbox variants: `sandbox` supports a `userId` parameter so each trainee can have an isolated state key.

Pipeline parameters
- `environment` (platform | connectivity | sandbox)
- `userId` (plat | conn | 01 | 02 | 03) — used for sandbox state suffixes and artifact names

How to create the required Azure DevOps service connection (brief)
- Portal: Project settings → Service connections → New → Azure Resource Manager. Name it `tf-service-connection` (or update pipeline variable to match).
- CLI (scripted): create a service principal with `az ad sp create-for-rbac`, then use `az devops service-endpoint create` with a JSON config.

How to run locally (developer sanity checks)
1. Set working directory to the landing zone, e.g. `training_iac/caf_lz/platform_lz`
2. Authenticate with Azure CLI: `az login` and ensure the account has contributor rights to the target subscription.
3. Run:
```bash
terraform init -reconfigure -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstatetrn001" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=platform-plat.tfstate"
terraform plan -var-file="../../landingzone_tfvars/platform.tfvars"
terraform apply -auto-approve
```

Notes and recommendations
- Terraform version used by the pipeline: 1.9.5. Use a matching local version when testing.
- Ensure the service principal used by the DevOps service connection has permission to create resource groups, storage accounts and containers (Contributor at subscription or RG scope).
- The pipeline bootstraps the backend resources (resource group, storage account, container) but it cannot create the Azure DevOps service connection.

Troubleshooting
- If the YAML schema error appears in the editor, ensure `training_iac/pipelines/azure-pipelines.schema.json` contains a valid schema (a minimal schema is included in the repo to quiet the language server).
- If `terraform init` fails in pipeline, check service connection permissions and backend names in the pipeline variables.

Contact / Next steps
- If you want, I can add a `svc.json` example for creating the service connection programmatically, or update this README to reflect a different service connection name.


# CAF Learning Platform — Repository Review & Target Architecture

A multi-user Azure CAF training environment built on **Azure + Terraform + Azure DevOps**, hosted in a single subscription, with three landing zones and one reusable pipeline driven by branch names.

> Status: review only. **No code changes are made by this document.** Implementation deltas listed under section 2 are queued for the next change set.

---

## Goal

| Aspect              | Decision                                                                                  |
| ------------------- | ----------------------------------------------------------------------------------------- |
| Cloud               | One Azure subscription, shared by all trainees                                            |
| IaC                 | Terraform (AzureRM v4, Terraform >= 1.5)                                                  |
| CI/CD               | Azure DevOps Pipelines (YAML, multi-stage)                                                |
| Landing zones       | **Platform** (shared) · **Connectivity** (shared) · **Sandbox** (per-trainee workload)    |
| Backend             | Single Azure Storage account, isolated by blob key                                        |
| tfvars              | **One file per landing zone** (`sandbox.tfvars`, `platform.tfvars`, `connectivity.tfvars`) |
| User identity       | Derived from the Git branch name (`feature/userNN` → `userNN`)                            |
| State per trainee   | `userNN.tfstate` (sandbox), `platform.tfstate`, `connectivity.tfstate`                    |

---

## 1. Current Repository Structure (Review)

```
Terraform_Training/
└── training_iac/
    ├── caf_lz/
    │   ├── sandbox_lz/        main.tf, variables.tf, outputs.tf, README.md
    │   ├── platform_lz/       main.tf, variables.tf, outputs.tf, README.md
    │   └── connectivity_lz/   main.tf, variables.tf, outputs.tf, README.md
    ├── landingzone_tfvars/
    │   ├── sandbox.tfvars             (reference, user01 baked in)
    │   ├── sandbox.user01.tfvars      *** to be removed (see §2) ***
    │   ├── sandbox.user02.tfvars      *** to be removed (see §2) ***
    │   ├── sandbox.user03.tfvars      *** to be removed (see §2) ***
    │   ├── platform.tfvars
    │   └── connectivity.tfvars
    ├── modules/               10 reusable building blocks (4-file layout each)
    │   ├── resource_group/            virtual_network/        storage_account/
    │   ├── log_analytics_workspace/   recovery_services_vault/ key_vault/
    │   ├── public_ip/                 bastion_host/            route_table/
    │   └── diagnostic_setting/
    └── pipelines/
        ├── azure-pipelines.yml        (entry point, branch routing)
        ├── README.md
        └── templates/
            ├── bootstrap.yml          (creates rg-tfstate, storage account, container)
            ├── terraform-init.yml     (install + init with -backend-config)
            ├── terraform-plan.yml     (init + validate + plan + publish artifact)
            └── terraform-apply.yml    (download artifact + init + apply tfplan)
```

What is **in place** and matches the goal:

- All three LZ root modules scaffolded with partial `backend "azurerm" {}` blocks.
- 10 reusable modules with the standard 4-file layout (`versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`).
- Single reusable pipeline with Bootstrap → Plan → Apply structure and per-LZ deployment environments.
- CAF naming convention woven into locals: `<type>-<workload>-<env>-<user>-<region>-<instance>`.
- Cross-LZ data flow demonstrated via `terraform_remote_state` (sandbox → platform diagnostics, opt-in).

---

## 2. Gap Analysis — Missing or Misaligned

### 2a. Misaligned with "one sandbox.tfvars + user from branch"

| File                                              | Status     | Action                                                                 |
| ------------------------------------------------- | ---------- | ---------------------------------------------------------------------- |
| `landingzone_tfvars/sandbox.user01.tfvars`        | **Remove** | Replaced by branch-derived `user_alias`.                               |
| `landingzone_tfvars/sandbox.user02.tfvars`        | **Remove** | Same.                                                                  |
| `landingzone_tfvars/sandbox.user03.tfvars`        | **Remove** | Same.                                                                  |
| `landingzone_tfvars/sandbox.tfvars`               | **Edit**   | Remove the hard-coded `user_alias = "user01"` line; keep everything else. The pipeline will inject `user_alias` via `-var`. |
| `pipelines/azure-pipelines.yml` (sandbox stages)  | **Edit**   | Change `tfvarsRelPath` to `sandbox.tfvars` and add `-var "user_alias=$(Build.SourceBranchName)"` to the plan command. |
| `pipelines/templates/terraform-plan.yml`          | **Edit**   | Accept an optional `extraVars` parameter so the sandbox stage can pass `-var user_alias=...`. |

> The same approach can extend to per-CIDR injection later (e.g. `-var 'vnet_address_space=["10.<NN>.0.0/16"]'`) if you want full network isolation without per-user files.

### 2b. Missing files

| Missing                                | Why it matters                                                                        |
| -------------------------------------- | ------------------------------------------------------------------------------------- |
| `README.md` at repository root         | This file. Single source of truth for the platform.                                   |
| `.gitignore`                           | Currently nothing prevents committing `.terraform/`, `*.tfstate`, `*.tfplan`, crash logs, `*.tfvars.local`. High-risk omission. |
| `training_iac/README.md`               | Index for the IaC tree (modules vs. LZs vs. tfvars vs. pipelines).                    |
| Hub–spoke peering wiring               | `connectivity_lz` builds the hub VNet, `sandbox_lz` builds the spoke, but no peering resource exists yet. |
| Remote-state migration for cross-LZ    | `sandbox_lz/main.tf` reads `platform` state via `backend = "local"`. After remote backend roll-out this must become `backend = "azurerm"`. |
| `caf-lz-sandbox` / `-platform` / `-connectivity` ADO Environments | Required for the `deployment` jobs to bind to and for approval gates. Created in the ADO UI (one-time). |


---

## 3. Proposed Final Architecture

### 3a. Target tree (delta from §1 shown inline)

```
Terraform_Training/
├── README.md                         (this file)
├── .gitignore                        (NEW - .terraform/, *.tfstate*, *.tfplan, crash.log)
└── training_iac/
    ├── README.md                     (NEW - index of the IaC tree)
    ├── caf_lz/
    │   ├── sandbox_lz/               (unchanged, peering resource added)
    │   ├── platform_lz/
    │   └── connectivity_lz/
    ├── landingzone_tfvars/
    │   ├── sandbox.tfvars            (single file, no user_alias)
    │   ├── platform.tfvars
    │   └── connectivity.tfvars
    ├── modules/                      (unchanged, 10 modules)
    └── pipelines/
        ├── azure-pipelines.yml       (sandbox stage passes -var user_alias)
        ├── README.md
        └── templates/                (unchanged)
```

### 3b. Subscription & landing-zone topology

```
┌──────────────────────────────────────────────────────────────────────┐
│                    Single Azure Subscription                         │
│                                                                      │
│  ┌────────────────────┐  ┌────────────────────┐                      │
│  │ Platform LZ        │  │ Connectivity LZ    │                      │
│  │ (shared, 1 state)  │  │ (shared, 1 state)  │                      │
│  │ - Log Analytics    │  │ - Hub VNet 10.0/16 │                      │
│  │ - Recovery Vault   │  │ - Bastion / PIP    │                      │
│  │ - Key Vault        │  │ - Route Table      │                      │
│  └─────────▲──────────┘  └─────────▲──────────┘                      │
│            │ diagnostics            │ peering                        │
│            │ (remote_state)         │ (remote_state)                 │
│  ┌─────────┴────────────────────────┴──────────┐                     │
│  │ Sandbox LZ - one per trainee (10 states)    │                     │
│  │ - RG / Storage / Spoke VNet 10.NN.0.0/16    │                     │
│  │ - user_alias injected from branch name      │                     │
│  └─────────────────────────────────────────────┘                     │
└──────────────────────────────────────────────────────────────────────┘
```

### 3c. Naming convention (unchanged)

`<type>-<workload>-<env>-<user>-<region>-<instance>` — e.g. `rg-trn-sandbox-user01-eus-001`.
Storage accounts: lowercase, alphanumeric, truncated to 24 chars.

### 3d. Backend strategy

| Item                    | Value                                                              |
| ----------------------- | ------------------------------------------------------------------ |
| Backend type            | `azurerm` (partial config in every root module)                    |
| Resource group          | `rg-tfstate` (created by Bootstrap stage if missing)               |
| Storage account         | `sttfstatetrn001` (shared by all trainees, all LZs)                |
| Container               | `tfstate`                                                          |
| Blob key (platform)     | `platform.tfstate`                                                 |
| Blob key (connectivity) | `connectivity.tfstate`                                             |
| Blob key (sandbox)      | `<branch-leaf>.tfstate` — `feature/user01` → `user01.tfstate`      |

### 3e. tfvars strategy

- **One file per landing zone.** No per-user files.
- `subscription_id`, `location`, `workload`, `environment`, `instance`, tags etc. live in the LZ tfvars.
- `user_alias` is **never** stored in tfvars; the pipeline appends `-var "user_alias=$(Build.SourceBranchName)"` for the sandbox stage. Platform and connectivity do not need `user_alias` because they are shared.
- Per-user CIDR isolation (`10.NN.0.0/16`) can be derived from the branch name with a `locals` block in `sandbox_lz/main.tf`, or passed explicitly via `-var`.

### 3f. Pipeline routing (single `azure-pipelines.yml`)

| Trigger                       | Stages fired                                       | tfvars                                            | State key              |
| ----------------------------- | -------------------------------------------------- | ------------------------------------------------- | ---------------------- |
| `main` + param `platform`     | Bootstrap → Platform_Plan → Platform_Apply         | `platform.tfvars`                                 | `platform.tfstate`     |
| `main` + param `connectivity` | Bootstrap → Connectivity_Plan → Connectivity_Apply | `connectivity.tfvars`                             | `connectivity.tfstate` |
| `feature/userNN`              | Bootstrap → Sandbox_Plan → Sandbox_Apply           | `sandbox.tfvars` + `-var user_alias=userNN`       | `userNN.tfstate`       |

Stage selection is enforced by `condition:` expressions on `Build.SourceBranch` and the parameter; every run fires exactly one Plan + Apply pair.

---

## 4. Deployment Sequence

The three LZs have a strict dependency order because sandbox reads outputs from platform and connectivity via `terraform_remote_state`.

### Step 0 — Trainer one-time setup (manual, ADO UI)

1. Create ARM service connection `Azure-Training` scoped to the training subscription (SP needs `Contributor` on the subscription).
2. Create ADO Environments: `caf-lz-platform`, `caf-lz-connectivity`, `caf-lz-sandbox`. Attach approval checks if desired.
3. Register the pipeline pointing at `training_iac/pipelines/azure-pipelines.yml`.

### Step 1 — Bootstrap (automatic, every run)

The pipeline's Bootstrap stage idempotently creates:

- `rg-tfstate` resource group
- `sttfstatetrn001` storage account (LRS, TLS 1.2, no public blob access)
- `tfstate` blob container

No trainee action required.

### Step 2 — Platform LZ (trainer, once)

```
Pipelines -> Run pipeline
  Branch:    main
  Parameter: mainBranchLandingZone = platform
```

Produces `platform.tfstate` containing: Log Analytics Workspace, Recovery Services Vault, Key Vault — and the outputs that sandbox will consume for diagnostics.

### Step 3 — Connectivity LZ (trainer, once)

```
Pipelines -> Run pipeline
  Branch:    main
  Parameter: mainBranchLandingZone = connectivity
```

Produces `connectivity.tfstate` containing: hub VNet (`10.0.0.0/16`), AzureBastionSubnet, optional Bastion + Public IP, route table — and the outputs that sandbox will consume for peering.

### Step 4 — Sandbox LZ (each trainee, per branch)

```
git checkout -b feature/user01
# (optional) edit landingzone_tfvars/sandbox.tfvars
git push origin feature/user01
```

Pipeline auto-triggers. Sandbox stages:

1. **Plan** reads `platform.tfstate` and `connectivity.tfstate` via `terraform_remote_state` (`azurerm` backend, same storage account).
2. Produces and applies: trainee RG, storage account, spoke VNet (`10.NN.0.0/16`), VNet peering hub↔spoke, optional diagnostic settings → Log Analytics in platform.
3. State written to `userNN.tfstate`.

### Step 5 — Teardown

Same pipeline, manual run from the trainee's branch with a follow-on `terraform destroy` flow. Recommended: keep destroy as an explicit operator action rather than wiring it into the standard pipeline (lower blast radius for training).

### Dependency graph

```
Bootstrap (always)
   |
   +-- Platform_Plan ---> Platform_Apply         (run once, before sandbox)
   |
   +-- Connectivity_Plan ---> Connectivity_Apply (run once, before sandbox)
   |
   +-- Sandbox_Plan ---> Sandbox_Apply           (per trainee, after both above)
                |
                +-- reads remote_state of platform + connectivity
```

---

## Next change set (queued, not yet executed)

1. Delete `sandbox.user01-03.tfvars`; strip `user_alias` from `sandbox.tfvars`.
2. Update `pipelines/templates/terraform-plan.yml` to accept an `extraVars` parameter.
3. Update `azure-pipelines.yml` sandbox stages to pass `-var "user_alias=$(Build.SourceBranchName)"`.
4. Add root `.gitignore` and `training_iac/README.md`.
5. Add VNet peering resource to `sandbox_lz/main.tf` consuming `connectivity` remote state.
6. Migrate the existing cross-LZ diagnostics `terraform_remote_state` block from `backend = "local"` to `backend = "azurerm"` reading `platform.tfstate`.

Ask before I proceed with any of these.

