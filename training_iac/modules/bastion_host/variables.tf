variable "name" {
  description = "Azure Bastion host name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that owns the Bastion host."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sku" {
  description = "Bastion SKU (Basic or Standard). Standard unlocks file copy, tunneling, IP connect, etc."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "sku must be Basic or Standard."
  }
}

variable "subnet_id" {
  description = "Resource ID of the AzureBastionSubnet (must be named exactly 'AzureBastionSubnet', /26 or larger)."
  type        = string
}

variable "public_ip_address_id" {
  description = "Resource ID of a Standard SKU, Static-allocation Public IP."
  type        = string
}

variable "ip_configuration_name" {
  description = "Name of the ip_configuration block."
  type        = string
  default     = "configuration"
}

variable "tags" {
  description = "Tags applied to the Bastion host."
  type        = map(string)
  default     = {}
}
