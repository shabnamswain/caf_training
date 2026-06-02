output "id" {
  description = "Resource ID of the Bastion host."
  value       = azurerm_bastion_host.this.id
}

output "name" {
  description = "Name of the Bastion host."
  value       = azurerm_bastion_host.this.name
}

output "dns_name" {
  description = "FQDN clients use to reach the Bastion host (e.g. bst-...bastion.azure.com)."
  value       = azurerm_bastion_host.this.dns_name
}
