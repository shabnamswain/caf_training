output "id" {
  description = "Resource ID of the Public IP."
  value       = azurerm_public_ip.this.id
}

output "name" {
  description = "Name of the Public IP."
  value       = azurerm_public_ip.this.name
}

output "ip_address" {
  description = "Allocated public IP address (known after apply for Static SKU)."
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "FQDN of the Public IP (only set when domain_name_label is provided)."
  value       = azurerm_public_ip.this.fqdn
}
