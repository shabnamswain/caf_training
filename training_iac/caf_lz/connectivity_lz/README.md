# Connectivity Landing Zone (Root Module)

CAF-style connectivity landing zone used for the training class.

**Shared LZ**: one hub per subscription. Deployed once by the trainer from `main`. Sandbox spokes peer into this hub.

## What this module creates

With `deploy_bastion = true`:

| Resource                 | Example name                              |
| ------------------------ | ----------------------------------------- |
| Resource Group           | `rg-trn-conn-eus-001`                     |
| Hub VNet                 | `vnet-hub-trn-conn-eus-001`               |
| AzureBastionSubnet       | `AzureBastionSubnet` (fixed name)         |
| Workload Subnet          | `snet-workload`                           |
| Public IP (Bastion)      | `pip-bas-trn-conn-eus-001`                |
| Bastion Host             | `bas-trn-conn-eus-001`                    |
| Route Table              | `rt-trn-conn-eus-001` (+ optional UDR)    |

The workload subnet is associated with the route table via `azurerm_subnet_route_table_association`.

## Resource graph

```
RG
 ├── Hub VNet
 │    ├── AzureBastionSubnet  ─── used by Bastion
 │    └── snet-workload       ─── associated with Route Table
 ├── Public IP (Standard/Static)  ─── used by Bastion
 ├── Bastion Host
 └── Route Table  (+ optional default route to NVA)
```

## File layout

| File           | Purpose                                                                 |
| -------------- | ----------------------------------------------------------------------- |
| `variables.tf` | Input contract. Values come from `landingzone_tfvars/connectivity.tfvars`. |
| `main.tf`      | Provider, CAF locals, 5 `module` calls + 1 subnet/route-table association. |
| `outputs.tf`   | RG, hub VNet, subnet IDs, Bastion IP/DNS, route table ID.               |

## Trainee instructions

```powershell
cd training_iac\caf_lz\connectivity_lz
terraform init
terraform plan  -var-file="../../landingzone_tfvars/connectivity.tfvars"
terraform apply -var-file="../../landingzone_tfvars/connectivity.tfvars"
```

To tear down (Bastion bills hourly — destroy when not in use):

```powershell
terraform destroy -var-file="../../landingzone_tfvars/connectivity.tfvars"
```

## Key inputs

| Name                       | Type           | Default | Description                                                                 |
| -------------------------- | -------------- | ------- | --------------------------------------------------------------------------- |
| hub_vnet_address_space     | `list(string)` | n/a     | Hub VNet CIDR (e.g. `["10.0.0.0/16"]`).                                     |
| bastion_subnet_prefix      | `string`       | n/a     | AzureBastionSubnet CIDR (**/26 or larger** required by Azure).              |
| workload_subnet_prefix     | `string`       | n/a     | Demo workload subnet CIDR.                                                  |
| deploy_bastion             | `bool`         | `true`  | Toggle Bastion on/off.                                                      |
| bastion_sku                | `string`       | `Basic` | `Basic` or `Standard`.                                                      |
| default_route_next_hop_ip  | `string`       | `""`    | Set to an NVA IP to create a `0.0.0.0/0` UDR; leave empty for no default.   |

## Gotchas to teach

1. **`AzureBastionSubnet` name is hard-coded by Azure.** Don't rename it. Minimum size is /26.
2. **Bastion costs ~USD 0.19/hr (Basic).** For 10 trainees over a multi-day class, this adds up. The `deploy_bastion = false` toggle lets you keep the VNet but skip the meter.
3. **CIDR planning.** Hub VNet must not overlap any sandbox VNet (sandboxes auto-derive `10.NN.0.0/16` where `NN >= 1`). Sample hub uses `10.0.0.0/16`.
4. **Workload subnet ↔ route table association** is done at the root module via `azurerm_subnet_route_table_association` — intentionally not inside the `route_table` module, so the module stays generic.
5. **No on-prem connectivity** (VPN/ExpressRoute Gateway) in this slimmed-down version. Add `azurerm_virtual_network_gateway` + `GatewaySubnet` to extend.
