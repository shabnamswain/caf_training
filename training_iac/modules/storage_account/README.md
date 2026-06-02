# Storage Account Module

Creates a single Azure Storage Account with secure defaults (TLS 1.2, no public blob access).

The caller is expected to pass a name that already conforms to Azure storage account rules: 3-24 characters, lowercase letters and digits only. This is enforced by a `validation` block so trainees get an immediate error on bad input.

## Usage

```hcl
module "storage" {
  source = "../../modules/storage_account"

  name                     = "sttrnsbxu01eus001"
  resource_group_name      = module.rg.name
  location                 = module.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "sandbox"
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.5.0      |
| azurerm   | >= 4.0, < 5.0 |

## Inputs

| Name                            | Type          | Default      | Required | Description                                                                  |
| ------------------------------- | ------------- | ------------ | -------- | ---------------------------------------------------------------------------- |
| name                            | `string`      | n/a          | yes      | Storage account name (3-24 chars, lowercase alphanumeric).                   |
| resource_group_name             | `string`      | n/a          | yes      | Resource group that owns the storage account.                                |
| location                        | `string`      | n/a          | yes      | Azure region.                                                                |
| account_tier                    | `string`      | `Standard`   | no       | `Standard` or `Premium`.                                                     |
| account_replication_type        | `string`      | `LRS`        | no       | One of `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, `RAGZRS`.                       |
| account_kind                    | `string`      | `StorageV2`  | no       | Storage account kind.                                                        |
| min_tls_version                 | `string`      | `TLS1_2`     | no       | Minimum TLS version.                                                         |
| allow_nested_items_to_be_public | `bool`        | `false`      | no       | Whether blobs/containers can be set to public access.                        |
| shared_access_key_enabled       | `bool`        | `true`       | no       | Whether storage account access keys are enabled.                             |
| public_network_access_enabled   | `bool`        | `true`       | no       | Whether the storage account is reachable from the public internet.           |
| tags                            | `map(string)` | `{}`         | no       | Tags applied to the storage account.                                         |

## Outputs

| Name                       | Sensitive | Description                                       |
| -------------------------- | --------- | ------------------------------------------------- |
| id                         | no        | Resource ID of the storage account.               |
| name                       | no        | Name of the storage account.                      |
| primary_blob_endpoint      | no        | Primary blob service endpoint.                    |
| primary_access_key         | yes       | Primary access key.                               |
| primary_connection_string  | yes       | Primary connection string.                        |

## Notes

- Secure-by-default: `min_tls_version = TLS1_2` and `allow_nested_items_to_be_public = false`.
- Sensitive outputs are marked so Terraform will not print them in plan/apply output.
- For production, consider disabling `shared_access_key_enabled` and `public_network_access_enabled` and using Entra ID + private endpoints instead.
