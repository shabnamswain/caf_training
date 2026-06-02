###############################################################################
# Sandbox Landing Zone - Outputs
###############################################################################

output "resource_group_name" {
  description = "Name of the sandbox resource group."
  value       = module.rg.name
}

output "resource_group_id" {
  description = "Resource ID of the sandbox resource group."
  value       = module.rg.id
}

output "storage_account_name" {
  description = "Name of the sandbox storage account."
  value       = module.storage.name
}

output "storage_account_id" {
  description = "Resource ID of the sandbox storage account."
  value       = module.storage.id
}

output "virtual_network_name" {
  description = "Name of the sandbox virtual network."
  value       = module.vnet.name
}

output "virtual_network_id" {
  description = "Resource ID of the sandbox virtual network."
  value       = module.vnet.id
}
