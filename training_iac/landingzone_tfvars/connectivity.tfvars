###############################################################################
# Connectivity Landing Zone - Shared tfvars (one hub per subscription)
#
# Produced resource names (CAF-derived in main.tf):
#   Resource Group       : rg-trn-conn-eus-001
#   Hub VNet             : vnet-hub-trn-conn-eus-001
#   Public IP (Bastion)  : pip-bas-trn-conn-eus-001
#   Bastion Host         : bas-trn-conn-eus-001
#   Route Table          : rt-trn-conn-eus-001
#
# Cost note: Azure Bastion (Basic SKU) bills hourly. Destroy when not in use,
# or set deploy_bastion = false to skip the meter while keeping the VNet.
###############################################################################

subscription_id = "58974d62-0f68-4856-8152-953266b7f10b"

location       = "eastus"
location_short = "eus"

workload    = "trn"      # training
environment = "conn"     # connectivity
instance    = "001"

# Hub VNet: must NOT overlap any sandbox VNet (sandboxes use 10.NN.0.0/16, NN >= 1).
hub_vnet_address_space = ["10.0.0.0/16"]
bastion_subnet_prefix  = "10.0.1.0/26"   # /26 minimum for Bastion
workload_subnet_prefix = "10.0.2.0/24"

deploy_bastion = true
bastion_sku    = "Basic"

# Leave empty for no default route. Set to an NVA private IP (e.g. "10.0.3.4")
# to teach forced-tunneling via a route table.
default_route_next_hop_ip = ""

tags = {
  environment = "connectivity"
  managed_by  = "terraform"
}
