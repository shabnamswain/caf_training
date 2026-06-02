variable "name" {
  description = "Log Analytics workspace name (4-63 chars, alphanumeric and hyphens)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{2,61}[a-zA-Z0-9]$", var.name))
    error_message = "Workspace name must be 4-63 chars, alphanumeric/hyphens, starting and ending with alphanumeric."
  }
}

variable "resource_group_name" {
  description = "Resource group that owns the workspace."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "Workspace SKU."
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Data retention in days (30-730)."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "retention_in_days must be between 30 and 730."
  }
}

variable "daily_quota_gb" {
  description = "Daily ingestion cap in GB. Use -1 for unlimited."
  type        = number
  default     = -1
}

variable "tags" {
  description = "Tags applied to the workspace."
  type        = map(string)
  default     = {}
}
