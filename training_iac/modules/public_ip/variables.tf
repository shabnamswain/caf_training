variable "name" {
  description = "Public IP name (1-80 chars)."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 80
    error_message = "Public IP name must be between 1 and 80 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group that owns the Public IP."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "Public IP SKU (Basic or Standard). Standard is required for Bastion, Standard LB, etc."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "sku must be Basic or Standard."
  }
}

variable "allocation_method" {
  description = "Allocation method (Static or Dynamic). Standard SKU requires Static."
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "allocation_method must be Static or Dynamic."
  }
}

variable "zones" {
  description = "Optional list of availability zones (e.g. [\"1\",\"2\",\"3\"]). Empty list = no zonal pinning."
  type        = list(string)
  default     = []
}

variable "domain_name_label" {
  description = "Optional DNS label for the public IP (creates <label>.<region>.cloudapp.azure.com)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the Public IP."
  type        = map(string)
  default     = {}
}
