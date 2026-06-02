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
