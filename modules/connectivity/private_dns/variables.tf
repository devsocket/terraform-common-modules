variable "resource_group_name" {
  description = "Name of the resource group to create for private dns zones"
  type = string
}

variable "location" {
    description = "Azure region where this resource will be deployed"
    type = string
}

#--- DNS Zones -----
variable "dns_zones" {
    description = "List of private DNS zone names to create."
    type = list(string)
    default = [
        "privatelink.azurecr.io",
        "privatelink.vaultcore.azure.net",
        "privatelink.blob.core.windows.net"
    ]

    validation {
        condition = length(var.dns_zones) > 0
        error_message = "Atleast one DNZ zone must be present"
    }
}

# Hub Vnet Link
variable "hub_vnet_id" {
    description = "Resource ID of the hub Vnet. DNS zones will be linked here so that hub an resolve private endpoints."
    type = string
}

variable "hub_vnet_link_name" {
    description = "Prefix for hub vnet link names. final will be like <prefix>-<zone_name>"
    type = string
    default = "vnetlink-hub"
}

# -- Spoke vnet links
variable "spoke_vnet_links" {
    description = "Map of spoke Vnets to link to each DNS zone. Key is a short label and value is the spoke Vnet Resource ID"
    type = map(string)
    default = {}

    # e.g,
#    spoke_vnet_links = {
 #       dev = "/subscription/..../resourceGroups/..../providers/Microsoft.Network/virtualNetworks/vnet-spoke-dev"
  #  }
}

variable "spoke_vnet_link_name_prefix" {
    description = "Prefix for spoke Vnet link names. Final will be <prefix>-<spoke_key>-<zone_name>."
    type = string
    default = "vnetlink-spoke"
}

# Registration 
variable "enable_auto_registration" {
    description = "Enable auto-registration of the VM DNS records in the zone. Should be false for the privatelink zones, as they manage their records via private endpoints"
    type = bool
    default = false
}

# Tags
variable "tags" {
    description = "Tags applicable for all resources in this deployment"
    type = map(string)
    default = {}
}