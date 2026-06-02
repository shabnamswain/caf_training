output "id" {
  description = "Resource ID of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.this.id
}

output "name" {
  description = "Name of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.this.name
}
