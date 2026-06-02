output "id" {
  description = "Resource ID of the route table."
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "Name of the route table."
  value       = azurerm_route_table.this.name
}

output "route_ids" {
  description = "Map of route name to route resource ID."
  value       = { for k, r in azurerm_route.this : k => r.id }
}
