# Virtual Network Module

Creates an Azure Virtual Network and, optionally, a set of subnets inside it.

Subnets are declared as a `map(object)` so adding or removing one does not force unrelated subnets to be recreated.

## Usage

### VNet only (no subnets)

```hcl
module "vnet" {
  source = "../../modules/virtual_network"

  name                = "vnet-trn-sbx-u01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = ["10.10.0.0/16"]

  tags = {
    environment = "sandbox"
  }
}
```

### VNet with subnets

```hcl
module "vnet" {
  source = "../../modules/virtual_network"

  name                = "vnet-trn-sbx-u01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = ["10.10.0.0/16"]

  subnets = {
    snet-app = {
      address_prefixes  = ["10.10.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    snet-data = {
      address_prefixes = ["10.10.2.0/24"]
    }
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.5.0      |
| azurerm   | >= 4.0, < 5.0 |

## Inputs

| Name                | Type                                                                                            | Default | Required | Description                                                  |
| ------------------- | ----------------------------------------------------------------------------------------------- | ------- | -------- | ------------------------------------------------------------ |
| name                | `string`                                                                                        | n/a     | yes      | Virtual network name (2-64 chars).                           |
| resource_group_name | `string`                                                                                        | n/a     | yes      | Resource group that owns the virtual network.                |
| location            | `string`                                                                                        | n/a     | yes      | Azure region.                                                |
| address_space       | `list(string)`                                                                                  | n/a     | yes      | One or more CIDR blocks for the VNet.                        |
| dns_servers         | `list(string)`                                                                                  | `[]`    | no       | Custom DNS servers. Empty list = Azure-provided DNS.         |
| subnets             | `map(object({ address_prefixes = list(string), service_endpoints = optional(list(string), []) }))` | `{}`    | no       | Map of subnets to create. Key = subnet name.                 |
| tags                | `map(string)`                                                                                   | `{}`    | no       | Tags applied to the virtual network.                         |

## Outputs

| Name           | Description                                       |
| -------------- | ------------------------------------------------- |
| id             | Resource ID of the virtual network.               |
| name           | Name of the virtual network.                      |
| address_space  | Address space of the virtual network.             |
| subnet_ids     | Map of `subnet name => subnet resource ID`.       |
| subnet_names   | List of subnet names created inside the VNet.     |

## Notes

- Subnets are keyed by name (`for_each`), not by index, so the plan is stable when the map changes.
- Tags are applied to the VNet only. Subnets do not support tags in Azure.
