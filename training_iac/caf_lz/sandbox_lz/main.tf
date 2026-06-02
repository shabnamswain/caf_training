###############################################################################
# Sandbox Landing Zone - Root Module
# One subscription -> one sandbox RG per trainee (user_alias makes it unique).
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

###############################################################################
# CAF naming: <type>-<workload>-<env>-<user>-<region>-<instance>
# Storage accounts: alphanumeric, lowercase, <= 24 chars (no hyphens)
###############################################################################
locals {
  name_suffix = "${var.workload}-${var.environment}-${var.user_alias}-${var.location_short}-${var.instance}"

  rg_name   = "rg-${local.name_suffix}"
  vnet_name = "vnet-${local.name_suffix}"

  storage_account_name = lower(substr(
    "st${var.workload}${var.environment}${var.user_alias}${var.location_short}${var.instance}",
    0, 24
  ))

  # Derive VNet CIDR from user_alias when not explicitly overridden:
  #   user01 -> 10.1.0.0/16, user02 -> 10.2.0.0/16, ..., user10 -> 10.10.0.0/16
  user_index           = tonumber(regex("[0-9]+$", var.user_alias))
  derived_vnet_cidr    = "10.${local.user_index}.0.0/16"
  effective_vnet_cidrs = length(var.vnet_address_space) > 0 ? var.vnet_address_space : [local.derived_vnet_cidr]
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
# Storage Account
###############################################################################
module "storage" {
  source = "../../modules/storage_account"

  name                     = local.storage_account_name
  resource_group_name      = module.rg.name
  location                 = module.rg.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication
  tags                     = var.tags
}

###############################################################################
# Virtual Network
###############################################################################
module "vnet" {
  source = "../../modules/virtual_network"

  name                = local.vnet_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = local.effective_vnet_cidrs
  tags                = var.tags
}

###############################################################################
# Cross-LZ wire-up: send VNet + Storage diagnostics to the Platform LZ
# Log Analytics workspace. The workspace ID is read from the shared azurerm
# backend (platform.tfstate), so platform_lz must be applied first.
###############################################################################
data "terraform_remote_state" "platform" {
  count = var.enable_diagnostics ? 1 : 0

  backend = "azurerm"
  config = {
    resource_group_name  = var.platform_state_resource_group_name
    storage_account_name = var.platform_state_storage_account_name
    container_name       = var.platform_state_container_name
    key                  = var.platform_state_key
  }
}

module "vnet_diagnostics" {
  count = var.enable_diagnostics ? 1 : 0

  source = "../../modules/diagnostic_setting"

  name                       = "diag-vnet-to-platform-law"
  target_resource_id         = module.vnet.id
  log_analytics_workspace_id = data.terraform_remote_state.platform[0].outputs.log_analytics_workspace_id

  log_categories    = ["VMProtectionAlerts"]
  metric_categories = ["AllMetrics"]
}

module "storage_diagnostics" {
  count = var.enable_diagnostics ? 1 : 0

  source = "../../modules/diagnostic_setting"

  name                       = "diag-storage-to-platform-law"
  target_resource_id         = module.storage.id
  log_analytics_workspace_id = data.terraform_remote_state.platform[0].outputs.log_analytics_workspace_id

  metric_categories = ["Transaction", "Capacity"]
}
