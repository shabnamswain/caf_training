# Route Table Module

Creates an Azure Route Table and, optionally, a set of user-defined routes (UDRs) inside it.

Routes are declared as a `map(object)` so adding/removing a route is plan-stable.

## Usage

### Route table with no routes

```hcl
module "rt" {
  source = "../../modules/route_table"

  name                = "rt-trn-conn-user01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location

  tags = {
    environment = "connectivity"
  }
}
```

### Route table with a default route to a firewall (NVA)

```hcl
module "rt" {
  source = "../../modules/route_table"

  name                = "rt-trn-conn-user01-eus-001"
  resource_group_name = module.rg.name
  location            = module.rg.location

  routes = {
    to-firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.3.4"
    }
    to-onprem = {
      address_prefix = "192.168.0.0/16"
      next_hop_type  = "VirtualNetworkGateway"
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

| Name                          | Type                                                                                                | Default | Required | Description                                            |
| ----------------------------- | --------------------------------------------------------------------------------------------------- | ------- | -------- | ------------------------------------------------------ |
| name                          | `string`                                                                                            | n/a     | yes      | Route table name.                                      |
| resource_group_name           | `string`                                                                                            | n/a     | yes      | Owning resource group.                                 |
| location                      | `string`                                                                                            | n/a     | yes      | Azure region.                                          |
| bgp_route_propagation_enabled | `bool`                                                                                              | `true`  | no       | Whether BGP routes from a VNet gateway are propagated. |
| routes                        | `map(object({ address_prefix=string, next_hop_type=string, next_hop_in_ip_address=optional(string) }))` | `{}` | no | Routes to create. Key = route name.                |
| tags                          | `map(string)`                                                                                       | `{}`    | no       | Tags applied to the route table.                       |

## Outputs

| Name      | Description                                       |
| --------- | ------------------------------------------------- |
| id        | Resource ID of the route table.                   |
| name      | Route table name.                                 |
| route_ids | Map of `route name => route resource ID`.         |

## Notes

- `next_hop_type` values: `VirtualNetworkGateway`, `VnetLocal`, `Internet`, `VirtualAppliance`, `None`.
- `next_hop_in_ip_address` is only valid (and required) when `next_hop_type = VirtualAppliance`.
- Subnet association is **out of scope** for this module — wire it from the calling root module with `azurerm_subnet_route_table_association` when needed.
