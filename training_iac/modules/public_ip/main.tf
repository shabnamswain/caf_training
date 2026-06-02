resource "azurerm_public_ip" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku               = var.sku
  allocation_method = var.allocation_method
  zones             = length(var.zones) > 0 ? var.zones : null
  domain_name_label = var.domain_name_label

  tags = var.tags
}
