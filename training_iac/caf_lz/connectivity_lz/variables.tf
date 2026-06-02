###############################################################################
# Connectivity Landing Zone - Input Variables
# All values are supplied from landingzone_tfvars/connectivity.tfvars
###############################################################################

variable "subscription_id" {
  description = "Azure Subscription ID where the connectivity landing zone is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all connectivity resources."
  type        = string
}

variable "location_short" {
  description = "Short code for the Azure region used in CAF names (e.g. eus)."
  type        = string
}

variable "workload" {
  description = "Workload code used in CAF names (e.g. trn)."
  type        = string
}

variable "environment" {
  description = "Environment code used in CAF names (e.g. conn for connectivity)."
  type        = string
}

variable "instance" {
  description = "Instance number suffix used in CAF names (e.g. 001)."
  type        = string
  default     = "001"
}

variable "hub_vnet_address_space" {
  description = "Address space (CIDR list) for the hub VNet."
  type        = list(string)
}

variable "bastion_subnet_prefix" {
  description = "CIDR for the AzureBastionSubnet. Must be /26 or larger."
  type        = string
}

variable "workload_subnet_prefix" {
  description = "CIDR for the demo workload subnet that the route table can be attached to."
  type        = string
}

variable "deploy_bastion" {
  description = "Whether to deploy an Azure Bastion host (cost ~USD 0.19/hr). Set false to save money during teardown windows."
  type        = bool
  default     = true
}

variable "bastion_sku" {
  description = "Bastion SKU (Basic or Standard)."
  type        = string
  default     = "Basic"
}

variable "default_route_next_hop_ip" {
  description = "Optional NVA IP for the default route (0.0.0.0/0). Empty string means no default route is created."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags applied to every resource."
  type        = map(string)
  default     = {}
}
