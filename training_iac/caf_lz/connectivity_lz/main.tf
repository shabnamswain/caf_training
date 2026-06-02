###############################################################################
# Connectivity Landing Zone - Root Module
# Shared LZ - one hub per subscription (no user_alias in the name).
# Hub VNet + AzureBastionSubnet + Public IP + Bastion + Route Table.
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
# CAF naming: <type>-<workload>-<env>-<region>-<instance>
###############################################################################
locals {
  name_suffix = "${var.workload}-${var.environment}-${var.location_short}-${var.instance}"

  rg_name          = "rg-${local.name_suffix}"
  hub_vnet_name    = "vnet-hub-${local.name_suffix}"
  pip_bastion_name = "pip-bas-${local.name_suffix}"
  bastion_name     = "bas-${local.name_suffix}"
  route_table_name = "rt-${local.name_suffix}"
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
# Hub Virtual Network (with AzureBastionSubnet + workload subnet)
###############################################################################
module "hub_vnet" {
  source = "../../modules/virtual_network"

  name                = local.hub_vnet_name
  resource_group_name = module.rg.name
  location            = module.rg.location
  address_space       = var.hub_vnet_address_space

  subnets = {
    # Subnet name MUST be exactly 'AzureBastionSubnet' for Bastion to deploy.
    AzureBastionSubnet = {
      address_prefixes = [var.bastion_subnet_prefix]
    }
    snet-workload = {
      address_prefixes = [var.workload_subnet_prefix]
    }
  }

  tags = var.tags
}

###############################################################################
# Public IP for Bastion (Standard SKU, Static - required by Bastion)
###############################################################################
module "pip_bastion" {
  count = var.deploy_bastion ? 1 : 0

  source = "../../modules/public_ip"

  name                = local.pip_bastion_name
  resource_group_name = module.rg.name
  location            = module.rg.location

  tags = var.tags
}

###############################################################################
# Azure Bastion Host
###############################################################################
module "bastion" {
  count = var.deploy_bastion ? 1 : 0

  source = "../../modules/bastion_host"

  name                 = local.bastion_name
  resource_group_name  = module.rg.name
  location             = module.rg.location
  sku                  = var.bastion_sku
  subnet_id            = module.hub_vnet.subnet_ids["AzureBastionSubnet"]
  public_ip_address_id = module.pip_bastion[0].id

  tags = var.tags
}

###############################################################################
# Route Table (demo: optional default route to an NVA)
###############################################################################
module "route_table" {
  source = "../../modules/route_table"

  name                = local.route_table_name
  resource_group_name = module.rg.name
  location            = module.rg.location

  routes = var.default_route_next_hop_ip == "" ? {} : {
    to-firewall = {
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.default_route_next_hop_ip
    }
  }

  tags = var.tags
}

###############################################################################
# Associate the route table with the workload subnet
###############################################################################
resource "azurerm_subnet_route_table_association" "workload" {
  subnet_id      = module.hub_vnet.subnet_ids["snet-workload"]
  route_table_id = module.route_table.id
}
