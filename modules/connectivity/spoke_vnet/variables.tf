variable "resource_group_name" {
  description = "Name of the resource group where the spoke virtual network will be created."
  type        = string
}

variable "location" {
    description = "Azure region for all the resources in this module "
    type        = string
}

variable "vnet_name" {
  description = "name of the Spoke VNet"
  type = string
}

variable vnet_address_space {
  description = "Address space for the spoke virtual network. Should not overlap with the hub virtual network or any other spoke virtual networks."
  type        = list(string)
  default = ["10.1.0.0/16"]
}

variable "aks_subnet_name" {
    description = "name of AKS pool subnet"
    type = string
}

variable "aks_subnet_cidr" {
    description = "Address space for the AKS pool subnet"
    type = string
    default = "10.1.0.0/22"
}

variable "gateway_subnet_cidr" {
    description = "CIDR for App Gateway Subnet, recommended is /24 for WAF V2 autoscaling"
    type = string
    default = "10.1.4.0/24"
}

variable "gateway_subnet_name" {
    description = "Application gateway subnet name"
    type = string
    default = "snet-appgw"
}

variable "private_endpoint_subnet_name" {
    description = "Name of private endpoints subnet."
    type = string
    default = "snet-privateendpoints"
}

variable "private_endpoints_subnet_cidr" {
    description = "Cidr for the Private endpoints subnet. /27 sufficient for most workloads"
    type = string
    default = "10.1.5.0/27"
}

# Hub peering details

variable "hub_vnet_id" {
    description = "Resource ID of the Hub Vnet. required for establishing Hub-to-Spoke peering"
    type = string
}

variable "hub_vnet_name" {
    description = "Name of Hub Vnet. required for the peering source name"
    type = string
}

variable "hub_resource_group_name" {
    description = "Resource group of the Hub Vnet. Required for Hub-to-spoke peering resource"
    type = string
}

# UDR table

variable "route_table_name" {
    description = "Name of the route table attached to spoke Vnets"
    type = string
}

variable "disable_bgp_route_propogation" {
    description = "Disable BGP route propogation on the route table. Set true when routing through a Firewall NVA."
    type = bool
    default = false
}

variable "tags" {
    description = "Tags to apply to all resources created by this module"
    type = map(string)
    default = {}
}




