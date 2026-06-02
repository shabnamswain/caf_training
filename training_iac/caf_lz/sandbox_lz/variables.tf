###############################################################################
# Sandbox Landing Zone - Input Variables
# All values are supplied from landingzone_tfvars/sandbox.tfvars
###############################################################################

variable "subscription_id" {
  description = "Azure Subscription ID where the sandbox landing zone is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all sandbox resources (e.g. eastus, westeurope)."
  type        = string
}

variable "location_short" {
  description = "Short code for the Azure region used in CAF names (e.g. eus, weu)."
  type        = string
}

variable "workload" {
  description = "Short workload / project code used in CAF names (e.g. trn for training)."
  type        = string
}

variable "environment" {
  description = "Environment code used in CAF names (e.g. sbx, dev, prd)."
  type        = string
}

variable "user_alias" {
  description = "Per-trainee unique alias (e.g. u01..u10). Makes all resource names unique per student."
  type        = string
}

variable "instance" {
  description = "Instance number suffix used in CAF names (e.g. 001)."
  type        = string
  default     = "001"
}

variable "vnet_address_space" {
  description = "Optional override for the sandbox VNet address space. Leave empty to auto-derive from user_alias (user01 -> 10.1.0.0/16, user02 -> 10.2.0.0/16, ...)."
  type        = list(string)
  default     = []
}

variable "storage_account_tier" {
  description = "Storage account tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication" {
  description = "Storage account replication type (LRS, GRS, ZRS, etc.)."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Common tags applied to every resource in the sandbox landing zone."
  type        = map(string)
  default     = {}
}

variable "enable_diagnostics" {
  description = "Send sandbox VNet and Storage diagnostics to the Platform LZ Log Analytics workspace. Requires platform_lz to be applied first."
  type        = bool
  default     = false
}

variable "platform_state_resource_group_name" {
  description = "Resource group of the shared azurerm state backend (where platform.tfstate lives). Used when enable_diagnostics = true."
  type        = string
  default     = "rg-tfstate"
}

variable "platform_state_storage_account_name" {
  description = "Storage account of the shared azurerm state backend."
  type        = string
  default     = "sttfstatetrn001"
}

variable "platform_state_container_name" {
  description = "Blob container of the shared azurerm state backend."
  type        = string
  default     = "tfstate"
}

variable "platform_state_key" {
  description = "Blob key of the platform LZ state."
  type        = string
  default     = "platform.tfstate"
}
