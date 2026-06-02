# Recovery Services Vault Module

Creates a single Azure Recovery Services Vault used as the backup/restore container for VMs, file shares, and workloads.

## Usage

```hcl
module "rsv" {
  source = "../../modules/recovery_services_vault"

  name                = "rsv-trn-plat-user01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location

  storage_mode_type   = "GeoRedundant"
  soft_delete_enabled = true

  tags = {
    environment = "platform"
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.5.0      |
| azurerm   | >= 4.0, < 5.0 |

## Inputs

| Name                          | Type          | Default        | Required | Description                                                          |
| ----------------------------- | ------------- | -------------- | -------- | -------------------------------------------------------------------- |
| name                          | `string`      | n/a            | yes      | Vault name (2-50 chars, must start with a letter).                   |
| resource_group_name           | `string`      | n/a            | yes      | Owning resource group.                                               |
| location                      | `string`      | n/a            | yes      | Azure region.                                                        |
| sku                           | `string`      | `Standard`     | no       | `Standard` or `RS0`.                                                 |
| storage_mode_type             | `string`      | `GeoRedundant` | no       | `GeoRedundant`, `LocallyRedundant`, or `ZoneRedundant`.              |
| soft_delete_enabled           | `bool`        | `true`         | no       | Whether soft delete is enabled.                                      |
| cross_region_restore_enabled  | `bool`        | `false`        | no       | Cross-region restore (requires `GeoRedundant`).                      |
| public_network_access_enabled | `bool`        | `true`         | no       | Whether the vault is reachable from the public internet.             |
| tags                          | `map(string)` | `{}`           | no       | Tags applied to the vault.                                           |

## Outputs

| Name | Description                                        |
| ---- | -------------------------------------------------- |
| id   | Resource ID of the Recovery Services Vault.        |
| name | Name of the Recovery Services Vault.               |

## Notes

- `cross_region_restore_enabled = true` is only valid when `storage_mode_type = GeoRedundant`.
- Once `soft_delete_enabled` is `true`, deleted backup items are retained for 14 days. Disabling soft delete in production is discouraged.
- Changing `storage_mode_type` is only allowed before any backup items exist in the vault.
