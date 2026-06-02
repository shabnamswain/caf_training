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
