###############################################################################
# Connectivity Landing Zone - Outputs
###############################################################################

output "resource_group_name" {
  description = "Name of the connectivity resource group."
  value       = module.rg.name
}

output "resource_group_id" {
  description = "Resource ID of the connectivity resource group."
  value       = module.rg.id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet."
  value       = module.hub_vnet.name
}

output "hub_vnet_id" {
  description = "Resource ID of the hub VNet."
  value       = module.hub_vnet.id
}

output "hub_subnet_ids" {
  description = "Map of subnet name to subnet ID inside the hub VNet."
  value       = module.hub_vnet.subnet_ids
}

output "bastion_public_ip_address" {
  description = "Public IP address allocated to Bastion (null when deploy_bastion = false)."
  value       = var.deploy_bastion ? module.pip_bastion[0].ip_address : null
}

output "bastion_dns_name" {
  description = "DNS name of the Bastion host (null when deploy_bastion = false)."
  value       = var.deploy_bastion ? module.bastion[0].dns_name : null
}

output "route_table_id" {
  description = "Resource ID of the demo route table."
  value       = module.route_table.id
}
