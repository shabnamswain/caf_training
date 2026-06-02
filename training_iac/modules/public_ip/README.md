# Public IP Module

Creates a single Azure Public IP. Defaults to Standard SKU + Static allocation (the modern combination required by Bastion, Standard LB, Application Gateway v2, etc.).

## Usage

```hcl
module "pip_bastion" {
  source = "../../modules/public_ip"

  name                = "pip-bas-trn-conn-user01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location

  tags = {
    environment = "connectivity"
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.5.0      |
| azurerm   | >= 4.0, < 5.0 |

## Inputs

| Name                | Type           | Default    | Required | Description                                                       |
| ------------------- | -------------- | ---------- | -------- | ----------------------------------------------------------------- |
| name                | `string`       | n/a        | yes      | Public IP name (1-80 chars).                                      |
| resource_group_name | `string`       | n/a        | yes      | Owning resource group.                                            |
| location            | `string`       | n/a        | yes      | Azure region.                                                     |
| sku                 | `string`       | `Standard` | no       | `Basic` or `Standard`.                                            |
| allocation_method   | `string`       | `Static`   | no       | `Static` or `Dynamic`. Standard SKU requires `Static`.            |
| zones               | `list(string)` | `[]`       | no       | Optional zonal pinning (e.g. `["1","2","3"]`).                    |
| domain_name_label   | `string`       | `null`     | no       | DNS label -> `<label>.<region>.cloudapp.azure.com`.               |
| tags                | `map(string)`  | `{}`       | no       | Tags applied to the Public IP.                                    |

## Outputs

| Name       | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| id         | Resource ID of the Public IP.                                     |
| name       | Public IP name.                                                   |
| ip_address | Allocated IP (known after apply for Static SKU).                  |
| fqdn       | FQDN of the Public IP (only set when `domain_name_label` is set). |

## Notes

- **Standard SKU is zone-aware**; Basic is not. Bastion and Standard Load Balancer both require Standard.
- Changing `sku` is a destroy/recreate operation.
- `domain_name_label` is globally unique within the region. Conflict -> pick a different label.
