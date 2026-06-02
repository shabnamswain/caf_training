# Platform Landing Zone (Root Module)

CAF-style platform landing zone used for the training class.

**Shared LZ**: one instance per subscription. Deployed once by the trainer from `main`. Trainee sandboxes consume its outputs (e.g. Log Analytics workspace ID) via `terraform_remote_state`.

## What this module creates

| Resource                  | Example name                       |
| ------------------------- | ---------------------------------- |
| Resource Group            | `rg-trn-plat-eus-001`              |
| Log Analytics Workspace   | `log-trn-plat-eus-001`             |
| Recovery Services Vault   | `rsv-trn-plat-eus-001`             |
| Key Vault                 | `kv-trn-plat-eus-001`              |

All four resources are provisioned through the reusable modules under [`training_iac/modules/`](../../modules).

## CAF naming convention

`<type>-<workload>-<env>-<region>-<instance>`

Computed in `main.tf` from:

- `workload`       (e.g. `trn`)
- `environment`    (e.g. `plat`)
- `location_short` (e.g. `eus`)
- `instance`       (e.g. `001`)

The Key Vault name is `substr(..., 0, 24)` because Azure caps it at 24 chars.

## File layout

| File           | Purpose                                                                       |
| -------------- | ----------------------------------------------------------------------------- |
| `variables.tf` | Input contract. Values come from `landingzone_tfvars/platform.tfvars`.        |
| `main.tf`      | `terraform`/provider blocks, `data` lookup, CAF locals, and 4 `module` calls. |
| `outputs.tf`   | Re-exports module outputs (RG, LAW, RSV, KV names + IDs).                     |

Trainee values live in [`../../landingzone_tfvars/platform.tfvars`](../../landingzone_tfvars/platform.tfvars).

## Trainee instructions

From this directory (`training_iac/caf_lz/platform_lz/`):

```powershell
terraform init
terraform plan  -var-file="../../landingzone_tfvars/platform.tfvars"
terraform apply -var-file="../../landingzone_tfvars/platform.tfvars"
```

To tear down:

```powershell
terraform destroy -var-file="../../landingzone_tfvars/platform.tfvars"
```

## Inputs

| Name                               | Type          | Default        | Description                                              |
| ---------------------------------- | ------------- | -------------- | -------------------------------------------------------- |
| subscription_id                    | `string`      | n/a            | Azure subscription ID.                                   |
| location                           | `string`      | n/a            | Azure region.                                            |
| location_short                     | `string`      | n/a            | Short region code (e.g. `eus`).                          |
| workload                           | `string`      | n/a            | Workload code (e.g. `trn`).                              |
| environment                        | `string`      | n/a            | Environment code (e.g. `plat`).                          |
| instance                           | `string`      | `001`          | Instance suffix.                                         |
| log_analytics_retention_in_days    | `number`      | `30`           | Workspace retention (30-730).                            |
| recovery_vault_storage_mode_type   | `string`      | `GeoRedundant` | Vault replication.                                       |
| key_vault_sku_name                 | `string`      | `standard`     | Key Vault SKU.                                           |
| key_vault_purge_protection_enabled | `bool`        | `false`        | Once `true`, cannot be turned off.                       |
| tags                               | `map(string)` | `{}`           | Common tags.                                             |

## Outputs

| Name                          | Description                                          |
| ----------------------------- | ---------------------------------------------------- |
| resource_group_name / _id     | Platform RG.                                         |
| log_analytics_workspace_name  | Name of the workspace.                               |
| log_analytics_workspace_id    | Resource ID of the workspace.                        |
| log_analytics_customer_id     | Workspace (customer) ID used by agents.              |
| recovery_services_vault_name  | Name of the Recovery Services Vault.                 |
| recovery_services_vault_id    | Resource ID of the Recovery Services Vault.          |
| key_vault_name / _id          | Key Vault identifiers.                               |
| key_vault_uri                 | Data-plane URI for the Key Vault.                    |

## Gotchas to teach

- **Key Vault names are globally unique.** If apply fails with `VaultAlreadyExists` or `ConflictError`, bump `instance` (`002`, `003` ...) in the tfvars.
- **Soft-deleted Key Vaults block name reuse** for `soft_delete_retention_days` (7 by default). If a trainee destroys and immediately re-applies, they may have to wait or change the name.
- **`purge_protection_enabled` is permanent.** Keep it `false` for training so trainees can fully tear down.
- **Tenant ID is auto-fetched** via `data "azurerm_client_config" "current"` — trainees do not put it in the tfvars.
