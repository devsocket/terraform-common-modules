output "zone_ids" {
    description = "Map of DNS zone name to resource ID. key is zone name e.g., 'privatelink.azurerm.io' consumed by private endpoint moudles."
    value = {
        for zone_name, zone in azurerm_private_dns_zone.this :
        zone_name => zone.id
    }
}

output "zone_names" {
    description = "Map of DNS zone name to zone name as confirmed by Azure. Useful for private endpoint dns_zone_group blocks."
    value = {
        for zone_name, zone in azurerm_private_dns_zone.this:
        zone_name => zone.name
    }
}

output "resource_group_name" {
    description = "Resource groups where DNS zones are created"
    value = azurerm_resource_group_name.this.name
}

# Vnet links

output "hub_vnet_link_ids" {
    description = "Map of zone name to hub VNet link resource ID."
    value = {
        for zone_name, link in azurerm_private_dns_zone_virtual_network_link.hub :
        zone_name => link.id
    }
}

output "spoke_vnet_link_ids" {
    description = "Map of composite key (<spoke_key>-<zone_name>) to spoke Vnet link resource ID"
    value = {
        for key, link in azurerm_private_dns_zone_virtual_network_link.spoke :
        key => link.id
    }
}