###############################################################################
# Platform Landing Zone - Outputs
###############################################################################

output "resource_group_name" {
  description = "Name of the platform resource group."
  value       = module.rg.name
}

output "resource_group_id" {
  description = "Resource ID of the platform resource group."
  value       = module.rg.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = module.law.name
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = module.law.id
}

output "log_analytics_customer_id" {
  description = "Workspace (customer) ID used by agents."
  value       = module.law.workspace_id
}

output "recovery_services_vault_name" {
  description = "Name of the Recovery Services Vault."
  value       = module.rsv.name
}

output "recovery_services_vault_id" {
  description = "Resource ID of the Recovery Services Vault."
  value       = module.rsv.id
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = module.kv.name
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.kv.id
}

output "key_vault_uri" {
  description = "URI clients use to reach the Key Vault data plane."
  value       = module.kv.vault_uri
}
