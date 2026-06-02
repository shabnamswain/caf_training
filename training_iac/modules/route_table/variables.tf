variable "name" {
  description = "Route table name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that owns the route table."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "bgp_route_propagation_enabled" {
  description = "Whether BGP route propagation from a virtual network gateway is enabled."
  type        = bool
  default     = true
}

variable "routes" {
  description = <<-EOT
    Map of routes to attach to the table. Key = route name. Example:
      routes = {
        to-firewall = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.3.4"
        }
      }
    next_hop_type values: VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, None.
    next_hop_in_ip_address is required only when next_hop_type = VirtualAppliance.
  EOT
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the route table."
  type        = map(string)
  default     = {}
}
