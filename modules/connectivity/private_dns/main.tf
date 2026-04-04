resource "azurerm_resource_group" "this" {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

# Private DNS Zones
# for_each over the DNS_ZONES list
#toset() converts the list to a set - required by for_each
# each.key and each.value are both the zone name e.g "privatelink.azurecr.io"
resource "azurerm_private_dnz_zone" "this" {
    for_each = toset(var.dns_zones)

    name = each.key
    resource_group_name = var.resource_group.this.name

    tags = var.tags
}

# Hub Vnet Links

#One link per DNS zone to the HUb Vnet
# for_each loops over the dns zone names
# Link name pattern: vnetlink-hub-privatelink.azurecr.io

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
    for_each = toset(var.dns_zones)

    name = "${var.hub_vnet_link_name}-${each.key}"
    resource_group_name = var.resource_group.this.name
    private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
    virtual_network_id = var.hub_vnet_id
    registration_enabled = var.enable_auto_registration

    tags = var.tags
}

# Spoke Vnet Links
# This is a two-dimensional loop - one link per zone per spoke
# for_each use setproduct() function two create all possible zone+spoke combinations
# e.g if zones = [acr, kv, blob] and spokes = {dev, prod}
# then result = acr+dev, acr+prod, kv+dev, kv+prod, blob+dev, blob+prod

locals {
    # Build a flatmap of all zone+spoke combinations
    # Key format : "<spoke_key>-<zone_name>", e.g: "dev-privatelink.azurecr.io"
    spoke_zone_links = {
        for pair in setproduct(keys(var.spoke_vnet_links), var.dns_zones) :
        "${pair[0]}-${pair[1]}" => {
            spoke_key = pair[0]
            zone_name = pair[1]
            vnet_id = var.spoke_vnet_links[pair[0]]
        }
    }
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
    for_each = local.spoke_zone_links

    name = "${var.spoke_vnet_link_name_prefix}-${each.key}"
    resource_group_name = azurerm_resource_group.this.name
    private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_name].name
    virtual_network_id = each.value.vnet_id
    registration_enabled = var.enable_auto_registration

    tags = var.tags
}