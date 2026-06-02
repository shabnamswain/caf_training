# Log Analytics Workspace Module

Creates a single Azure Log Analytics workspace.

The caller passes a CAF-compliant name (e.g. `log-trn-plat-user01-eus-001`).

## Usage

```hcl
module "law" {
  source = "../../modules/log_analytics_workspace"

  name                = "log-trn-plat-user01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location

  retention_in_days = 30

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

| Name                | Type          | Default     | Required | Description                                              |
| ------------------- | ------------- | ----------- | -------- | -------------------------------------------------------- |
| name                | `string`      | n/a         | yes      | Workspace name (4-63 chars, alphanumeric + hyphens).     |
| resource_group_name | `string`      | n/a         | yes      | Owning resource group.                                   |
| location            | `string`      | n/a         | yes      | Azure region.                                            |
| sku                 | `string`      | `PerGB2018` | no       | Workspace SKU.                                           |
| retention_in_days   | `number`      | `30`        | no       | Data retention period (30-730).                          |
| daily_quota_gb      | `number`      | `-1`        | no       | Daily ingestion cap in GB (`-1` = unlimited).            |
| tags                | `map(string)` | `{}`        | no       | Tags applied to the workspace.                           |

## Outputs

| Name                | Sensitive | Description                                          |
| ------------------- | --------- | ---------------------------------------------------- |
| id                  | no        | Resource ID of the workspace.                        |
| name                | no        | Workspace name.                                      |
| workspace_id        | no        | Workspace (customer) ID used by agents to send data. |
| primary_shared_key  | yes       | Primary shared key.                                  |

## Notes

- `daily_quota_gb = -1` disables the cap (unlimited ingestion).
- `primary_shared_key` is marked sensitive so it does not appear in `plan`/`apply` output.
