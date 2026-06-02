# Sandbox Landing Zone (Root Module)

CAF-style sandbox landing zone used for the training class.

One subscription holds up to **10 sandboxes**, one per trainee. The same root module is reused; each trainee passes a different `user_alias` (`u01`...`u10`) so resource names never collide.

## What this module creates

Per trainee:

| Resource         | Example name (`user_alias = u01`)        |
| ---------------- | ---------------------------------------- |
| Resource Group   | `rg-trn-sbx-u01-eus-001`                 |
| Storage Account  | `sttrnsbxu01eus001`                      |
| Virtual Network  | `vnet-trn-sbx-u01-eus-001`               |

All three resources are provisioned through the reusable modules under [`training_iac/modules/`](../../modules).

## CAF naming convention

`<type>-<workload>-<env>-<user>-<region>-<instance>`

Computed in `main.tf` from these variables:

- `workload`       (e.g. `trn`)
- `environment`    (e.g. `sbx`)
- `user_alias`     (e.g. `u01`)
- `location_short` (e.g. `eus`)
- `instance`       (e.g. `001`)

Storage account name is lowercased and truncated to 24 chars to satisfy Azure rules.

## File layout

| File           | Purpose                                                                  |
| -------------- | ------------------------------------------------------------------------ |
| `variables.tf` | Input contract. Values come from `landingzone_tfvars/sandbox.tfvars`.    |
| `main.tf`      | `terraform`/provider blocks, CAF name locals, and 3 `module` calls.      |
| `outputs.tf`   | Re-exports module outputs (RG, storage, VNet names + IDs).               |

Trainee values live in [`../../landingzone_tfvars/sandbox.tfvars`](../../landingzone_tfvars/sandbox.tfvars).

## Trainer instructions

1. Hand each trainee a copy of `sandbox.tfvars` with a unique `user_alias` (`u01`...`u10`).
2. Confirm every trainee uses the same `subscription_id`.
3. Recommend each trainee use an isolated remote state (see "Next steps" below).

## Trainee instructions

From this directory (`training_iac/caf_lz/sandbox_lz/`):

```powershell
terraform init
terraform plan  -var-file="../../landingzone_tfvars/sandbox.tfvars"
terraform apply -var-file="../../landingzone_tfvars/sandbox.tfvars"
```

To tear down:

```powershell
terraform destroy -var-file="../../landingzone_tfvars/sandbox.tfvars"
```

## Inputs

| Name                        | Type           | Default | Description                                          |
| --------------------------- | -------------- | ------- | ---------------------------------------------------- |
| subscription_id             | `string`       | n/a     | Azure subscription ID.                               |
| location                    | `string`       | n/a     | Azure region (e.g. `eastus`).                        |
| location_short              | `string`       | n/a     | Short region code (e.g. `eus`).                      |
| workload                    | `string`       | n/a     | Workload code (e.g. `trn`).                          |
| environment                 | `string`       | n/a     | Environment code (e.g. `sbx`).                       |
| user_alias                  | `string`       | n/a     | Per-trainee alias (e.g. `u01`). **Must be unique.**  |
| instance                    | `string`       | `001`   | Instance suffix.                                     |
| vnet_address_space          | `list(string)` | n/a     | CIDR blocks for the VNet.                            |
| storage_account_tier        | `string`       | `Standard` | Storage tier.                                     |
| storage_account_replication | `string`       | `LRS`   | Storage replication type.                            |
| enable_diagnostics          | `bool`         | `false` | Send VNet/storage diagnostics to platform LZ workspace. Requires platform_lz applied first. |
| platform_state_path         | `string`       | `../platform_lz/terraform.tfstate` | Path to platform_lz state file (used when `enable_diagnostics = true`). |
| tags                        | `map(string)`  | `{}`    | Common tags.                                         |

## Outputs

| Name                  | Description                          |
| --------------------- | ------------------------------------ |
| resource_group_name   | Name of the sandbox RG.              |
| resource_group_id     | Resource ID of the sandbox RG.       |
| storage_account_name  | Name of the storage account.         |
| storage_account_id    | Resource ID of the storage account.  |
| virtual_network_name  | Name of the VNet.                    |
| virtual_network_id    | Resource ID of the VNet.             |

## Cross-LZ diagnostics (opt-in)

When `enable_diagnostics = true`, this module:

1. Reads the **platform LZ** state via `terraform_remote_state` (local backend) to discover the Log Analytics workspace ID.
2. Creates two diagnostic settings:
   - VNet -> platform workspace (`log_categories = ["VMProtectionAlerts"]`, `metric_categories = ["AllMetrics"]`)
   - Storage account -> platform workspace (`metric_categories = ["Transaction","Capacity"]`)

**Order of operations:**

```powershell
# 1. Apply the platform LZ first so its state file exists
cd ..\platform_lz
terraform apply -var-file="../../landingzone_tfvars/platform.tfvars"

# 2. Then set enable_diagnostics = true in sandbox.tfvars and apply
cd ..\sandbox_lz
terraform apply -var-file="../../landingzone_tfvars/sandbox.tfvars"
```

`platform_state_path` defaults to `../platform_lz/terraform.tfstate`. Override it via tfvars if the state lives elsewhere (e.g. a real `azurerm` backend).

## Next steps (optional)

- Add a `backend "azurerm"` block, keyed by `user_alias`, so each trainee has an isolated state file.
- Pass a `subnets = {...}` map to the VNet module to extend the lab.
