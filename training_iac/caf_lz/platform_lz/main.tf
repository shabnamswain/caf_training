###############################################################################
# Platform Landing Zone - Root Module
# Shared LZ - one instance per subscription (no user_alias in the name).
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Used to populate tenant_id on the Key Vault without trainees having to look it up.
data "azurerm_client_config" "current" {}

###############################################################################
# CAF naming: <type>-<workload>-<env>-<region>-<instance>
# Key Vault: <= 24 chars, must start with a letter, alphanumeric + hyphens only.
###############################################################################
locals {
  name_suffix = "${var.workload}-${var.environment}-${var.location_short}-${var.instance}"

  rg_name             = "rg-${local.name_suffix}"
  log_analytics_name  = "log-${local.name_suffix}"
  recovery_vault_name = "rsv-${local.name_suffix}"

  key_vault_name = substr("kv-${local.name_suffix}", 0, 24)
}

###############################################################################
# Resource Group
###############################################################################
module "rg" {
  source = "../../modules/resource_group"

  name     = local.rg_name
  location = var.location
  tags     = var.tags
}

###############################################################################
# Log Analytics Workspace
###############################################################################
module "law" {
  source = "../../modules/log_analytics_workspace"

  name                = local.log_analytics_name
  resource_group_name = module.rg.name
  location            = module.rg.location

  retention_in_days = var.log_analytics_retention_in_days

  tags = var.tags
}

###############################################################################
# Recovery Services Vault
###############################################################################
module "rsv" {
  source = "../../modules/recovery_services_vault"

  name                = local.recovery_vault_name
  resource_group_name = module.rg.name
  location            = module.rg.location

  storage_mode_type = var.recovery_vault_storage_mode_type

  tags = var.tags
}

###############################################################################
# Key Vault
###############################################################################
module "kv" {
  source = "../../modules/key_vault"

  name                = local.key_vault_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                 = var.key_vault_sku_name
  purge_protection_enabled = var.key_vault_purge_protection_enabled

  tags = var.tags
}
