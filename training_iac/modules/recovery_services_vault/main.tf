resource "azurerm_recovery_services_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                           = var.sku
  storage_mode_type             = var.storage_mode_type
  soft_delete_enabled           = var.soft_delete_enabled
  cross_region_restore_enabled  = var.cross_region_restore_enabled
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}
