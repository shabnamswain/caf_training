# Key Vault Module

Creates a single Azure Key Vault with secure defaults (RBAC authorization on, purge protection off for sandbox use).

The caller passes a name that already satisfies Key Vault rules: 3-24 chars, must start with a letter, alphanumeric and hyphens only, and **globally unique** across all of Azure.

## Usage

```hcl
data "azurerm_client_config" "current" {}

module "kv" {
  source = "../../modules/key_vault"

  name                = "kv-trn-plat-user01-eus"
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

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

| Name                            | Type          | Default    | Required | Description                                                            |
| ------------------------------- | ------------- | ---------- | -------- | ---------------------------------------------------------------------- |
| name                            | `string`      | n/a        | yes      | Key Vault name (3-24 chars, globally unique).                          |
| resource_group_name             | `string`      | n/a        | yes      | Owning resource group.                                                 |
| location                        | `string`      | n/a        | yes      | Azure region.                                                          |
| tenant_id                       | `string`      | n/a        | yes      | Entra ID tenant the vault is bound to.                                 |
| sku_name                        | `string`      | `standard` | no       | `standard` or `premium`.                                               |
| soft_delete_retention_days      | `number`      | `7`        | no       | Soft-delete retention (7-90).                                          |
| purge_protection_enabled        | `bool`        | `false`    | no       | Once `true`, cannot be turned off.                                     |
| enable_rbac_authorization       | `bool`        | `true`     | no       | Use Azure RBAC (recommended) instead of legacy access policies.        |
| enabled_for_disk_encryption     | `bool`        | `false`    | no       | Allow ADE to retrieve secrets.                                         |
| enabled_for_deployment          | `bool`        | `false`    | no       | Allow VMs to retrieve certificates.                                    |
| enabled_for_template_deployment | `bool`        | `false`    | no       | Allow ARM to retrieve secrets during deployment.                       |
| public_network_access_enabled   | `bool`        | `true`     | no       | Whether the Key Vault is reachable from the public internet.           |
| tags                            | `map(string)` | `{}`       | no       | Tags applied to the Key Vault.                                         |

## Outputs

| Name      | Description                                          |
| --------- | ---------------------------------------------------- |
| id        | Resource ID of the Key Vault.                        |
| name      | Key Vault name.                                      |
| vault_uri | URI clients use to reach the Key Vault data plane.   |

## Notes

- **Names are globally unique across Azure.** If apply fails with a name conflict, change the name (e.g. bump `instance` in the root module).
- **`purge_protection_enabled` is permanent.** Leave it `false` for training so trainees can fully destroy and recreate. Set it to `true` for production.
- **RBAC is on by default.** Trainees grant themselves data-plane access via Azure RBAC role assignments (e.g. `Key Vault Secrets Officer`), not access policies.
- Soft-deleted vaults are retained for `soft_delete_retention_days` and block reuse of the same name. If a trainee destroys and immediately re-applies, they may hit a "vault still in soft-deleted state" error.
