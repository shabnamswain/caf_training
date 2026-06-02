# Bastion Host Module

Creates an Azure Bastion host attached to an existing `AzureBastionSubnet` and a Standard SKU Public IP.

## Usage

```hcl
module "bastion" {
  source = "../../modules/bastion_host"

  name                 = "bas-trn-conn-user01-eus-001"
  resource_group_name  = module.rg.name
  location             = module.rg.location
  subnet_id            = module.hub_vnet.subnet_ids["AzureBastionSubnet"]
  public_ip_address_id = module.pip_bastion.id

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

| Name                  | Type          | Default         | Required | Description                                                                  |
| --------------------- | ------------- | --------------- | -------- | ---------------------------------------------------------------------------- |
| name                  | `string`      | n/a             | yes      | Bastion host name.                                                           |
| resource_group_name   | `string`      | n/a             | yes      | Owning resource group.                                                       |
| location              | `string`      | n/a             | yes      | Azure region.                                                                |
| sku                   | `string`      | `Basic`         | no       | `Basic` or `Standard`.                                                       |
| subnet_id             | `string`      | n/a             | yes      | Resource ID of the **AzureBastionSubnet** (must be named exactly that, /26+).|
| public_ip_address_id  | `string`      | n/a             | yes      | Resource ID of a **Standard / Static** Public IP.                            |
| ip_configuration_name | `string`      | `configuration` | no       | Name of the inner `ip_configuration` block.                                  |
| tags                  | `map(string)` | `{}`            | no       | Tags applied to the Bastion host.                                            |

## Outputs

| Name     | Description                                              |
| -------- | -------------------------------------------------------- |
| id       | Resource ID of the Bastion host.                         |
| name     | Bastion host name.                                       |
| dns_name | FQDN clients use to reach Bastion.                       |

## Notes

- The subnet **must** be named `AzureBastionSubnet` (case-sensitive, hard-coded by Azure).
- The Public IP **must** be Standard SKU with Static allocation.
- **Cost warning:** even Basic Bastion bills hourly (~USD 0.19/hr in most regions). For 10 trainees that adds up; consider tearing down between class sessions.
- Standard SKU unlocks file copy, IP-based connect, shareable links, and tunneling — none of which Basic supports.
