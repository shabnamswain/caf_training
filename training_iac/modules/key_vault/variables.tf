variable "name" {
  description = "Key Vault name (3-24 chars, must start with a letter, alphanumeric + hyphens, globally unique)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "Key Vault name must be 3-24 chars, start with a letter, end with letter/digit, contain only letters/digits/hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group that owns the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID the Key Vault is bound to."
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention period in days (7-90)."
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "purge_protection_enabled" {
  description = "When true, prevents permanent deletion until the retention period elapses. Cannot be disabled once enabled."
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for data plane access (recommended) instead of legacy access policies."
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets from the vault."
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Allow VMs to retrieve certificates stored as secrets."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow Resource Manager to retrieve secrets during template deployment."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether the Key Vault is reachable from the public internet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the Key Vault."
  type        = map(string)
  default     = {}
}
