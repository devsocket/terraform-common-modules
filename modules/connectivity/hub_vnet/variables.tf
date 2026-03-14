variable "resource_group_name" {
  description = "Name of the resource group where the hub virtual network will be created."
  type        = string
}

variable "location" {
  description = "Azure region for all the resources in this module "
  type        = string
}
variable "vnet_name" {
  description = "Name of the hub virtual network."
  type        = string
}
variable "vnet_address_space" {
  description = "Address space for the hub virtual network. Should not overlap with any of the spoke virtual networks."
  type        = list(string)
  default = [ "10.0.0.0/16" ]
}
variable "management_subnet_name" {
  description = "Name of the management subnet (used for Jumpbox / ops tooling)"
  type = string
  default = "ManagementSubnet"
}
variable "management_subnet_cidr" {
  description = "Address prefix for the management subnet."
  type = string
  default = "10.0.1.0/24"
}
variable "enable_gateway_subnet" {
  description = "Whether to create a Gateway subnet for future VPN or ExpressRoute connectivity."
  type = bool
  default = false
}
variable "gateway_subnet_cidr" {
  description = "CIDR for gateway subnet. required if enable_gateway_subnet is set to true"
  type = string
  default = "10.0.255.0/27"
}
variable "tags" {
  description = "Tags to apply to all resources in this module."
    type        = map(string)
    default = {}
}