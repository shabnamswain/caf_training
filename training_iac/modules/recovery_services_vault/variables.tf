variable "name" {
  description = "Recovery Services Vault name (2-50 chars, must start with a letter, alphanumeric + hyphens)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,49}$", var.name))
    error_message = "Vault name must be 2-50 chars, start with a letter, contain only letters/digits/hyphens."
  }
}

variable "resource_group_name" {
  description = "Resource group that owns the vault."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "Vault SKU (Standard or RS0)."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "RS0"], var.sku)
    error_message = "sku must be Standard or RS0."
  }
}

variable "storage_mode_type" {
  description = "Storage replication mode (GeoRedundant, LocallyRedundant, ZoneRedundant)."
  type        = string
  default     = "GeoRedundant"

  validation {
    condition     = contains(["GeoRedundant", "LocallyRedundant", "ZoneRedundant"], var.storage_mode_type)
    error_message = "storage_mode_type must be GeoRedundant, LocallyRedundant, or ZoneRedundant."
  }
}

variable "soft_delete_enabled" {
  description = "Whether soft delete is enabled on the vault."
  type        = bool
  default     = true
}

variable "cross_region_restore_enabled" {
  description = "Enable cross-region restore. Requires storage_mode_type = GeoRedundant."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether the vault is reachable from the public internet."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to the vault."
  type        = map(string)
  default     = {}
}
