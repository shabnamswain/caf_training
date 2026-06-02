###############################################################################
# Platform Landing Zone - Input Variables
# All values are supplied from landingzone_tfvars/platform.tfvars
###############################################################################

variable "subscription_id" {
  description = "Azure Subscription ID where the platform landing zone is deployed."
  type        = string
}

variable "location" {
  description = "Azure region for all platform resources (e.g. eastus, westeurope)."
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
  description = "Environment code used in CAF names (e.g. plat, prd)."
  type        = string
}

variable "instance" {
  description = "Instance number suffix used in CAF names (e.g. 001)."
  type        = string
  default     = "001"
}

variable "log_analytics_retention_in_days" {
  description = "Log Analytics workspace retention in days (30-730)."
  type        = number
  default     = 30
}

variable "recovery_vault_storage_mode_type" {
  description = "Recovery Services Vault storage replication mode."
  type        = string
  default     = "GeoRedundant"
}

variable "key_vault_sku_name" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "standard"
}

variable "key_vault_purge_protection_enabled" {
  description = "Whether purge protection is enabled on the Key Vault (irreversible once true)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to every resource in the platform landing zone."
  type        = map(string)
  default     = {}
}
