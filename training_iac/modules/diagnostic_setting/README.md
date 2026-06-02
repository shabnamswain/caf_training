# Diagnostic Setting Module

Generic wrapper around `azurerm_monitor_diagnostic_setting`. Sends logs and metrics from any Azure resource to a Log Analytics workspace.

The caller is responsible for choosing log/metric category names that are valid for the target resource type (Azure rejects invalid categories at apply time).

## Usage

```hcl
module "vnet_diag" {
  source = "../../modules/diagnostic_setting"

  name                       = "diag-to-platform-law"
  target_resource_id         = module.vnet.id
  log_analytics_workspace_id = data.terraform_remote_state.platform.outputs.log_analytics_workspace_id

  log_categories    = ["VMProtectionAlerts"]
  metric_categories = ["AllMetrics"]
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.5.0      |
| azurerm   | >= 4.0, < 5.0 |

## Inputs

| Name                       | Type           | Default          | Required | Description                                                              |
| -------------------------- | -------------- | ---------------- | -------- | ------------------------------------------------------------------------ |
| name                       | `string`       | n/a              | yes      | Diagnostic setting name.                                                 |
| target_resource_id         | `string`       | n/a              | yes      | Resource ID of the source resource.                                      |
| log_analytics_workspace_id | `string`       | n/a              | yes      | Resource ID of the destination workspace.                                |
| log_categories             | `list(string)` | `[]`             | no       | Log categories to enable. Must be valid for the target resource type.    |
| metric_categories          | `list(string)` | `["AllMetrics"]` | no       | Metric categories to enable.                                             |

## Outputs

| Name | Description                          |
| ---- | ------------------------------------ |
| id   | Resource ID of the diagnostic setting. |

## Notes

- Valid log categories vary by resource type. Common examples:
  - **Virtual Network:** `VMProtectionAlerts`
  - **Key Vault:** `AuditEvent`, `AzurePolicyEvaluationDetails`
  - **Storage Account (sub-resources):** `StorageRead`, `StorageWrite`, `StorageDelete`
- This module only supports the Log Analytics destination. Extend it with `eventhub_*` / `storage_account_id` inputs if you need Event Hubs or Storage as destinations.
- The `retention_policy` block was removed in azurerm 4.x; retention is now managed at the workspace level.
