###############################################################################
# Platform Landing Zone - Shared tfvars (one instance per subscription)
#
# Produced resource names (CAF-derived in main.tf):
#   Resource Group           : rg-trn-plat-eus-001
#   Log Analytics Workspace  : log-trn-plat-eus-001
#   Recovery Services Vault  : rsv-trn-plat-eus-001
#   Key Vault                : kv-trn-plat-eus-001
#
# Notes:
# - Key Vault names must be globally unique across Azure. If apply fails with
#   a name conflict, bump `instance` (002, 003, ...).
# - tenant_id is auto-fetched in main.tf via data.azurerm_client_config.
###############################################################################

subscription_id = "58974d62-0f68-4856-8152-953266b7f10b"

location       = "eastus"
location_short = "eus"

workload    = "trn"      # training
environment = "plat"     # platform
instance    = "001"

log_analytics_retention_in_days = 30

recovery_vault_storage_mode_type = "GeoRedundant"

key_vault_sku_name                 = "standard"
key_vault_purge_protection_enabled = false

tags = {
  environment = "platform"
  managed_by  = "terraform"
}
