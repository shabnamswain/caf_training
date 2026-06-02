variable "name" {
  description = "Virtual network name."
  type        = string

  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 64
    error_message = "Virtual network name must be between 2 and 64 characters."
  }
}

variable "resource_group_name" {
  description = "Resource group that owns the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region for the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space (CIDR list) for the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR block."
  }
}

variable "dns_servers" {
  description = "Optional list of custom DNS servers. Empty list uses Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = <<-EOT
    Optional map of subnets to create inside the virtual network.
    Key is the subnet name. Example:
      subnets = {
        snet-app = {
          address_prefixes  = ["10.10.1.0/24"]
          service_endpoints = ["Microsoft.Storage"]
        }
      }
  EOT
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the virtual network."
  type        = map(string)
  default     = {}
}
