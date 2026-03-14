output "vnet_id" {
    description = "Resource ID of the Spoke Vnet."
    value = azurerm_virtual_network.this.id
}

output "vnet_name" {
    description = "Name of spoke Vnet"
    value = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
    description = "Address space of Spoke Vnet."
    value = azurerm_virtual_network.this.address_space
}

output "resource_group_name" {
    description = "Resouce group where spoke networking resources live"
    value = azurerm_resource_group.this.name
}

output "aks_subnet_id" {
    description = "AKS node pool subnet ID. Pass to azurm_kubernetes_cluster_default_node_pool.vnet_subnet.id"
    value = azurerm_subnet.aks.id
}

output "aks_subnet_name" {
    description = "Aks node pool subnet name"
    value = azurerm_subnet.aks.name
}

output "appgw_subnet_id" {
    description = "Application Gateway subnet ID. Pass to azurerm_application_gateway.vnet_subnet_id"
    value = azurerm_subnet.appgw.id
}

output "appgw_subnet_name" {
    description = "Application Gateway subnet name"
    value = azurerm_subnet.appgw.name
}

output "private_endpoints_subnet_id" {
    description = "Private endpoints subnet ID. Pass to private endpoint azurerm_private_endpoint.subnet_id"
    value = azurerm_subnet.private_endpoints.id
}

output "private_endpoints_subnet_name" {
    description = "Private endpoints subnet name"
    value = azurerm_subnet.private_endpoints.name
}

# Route table 
output "route_table_id" {
    description = "Route table ID. Pass to azurerm_subnet_route_table_association.route_table_id"
    value = azurerm_route_table.this.id
}

output "route_table_name" {
    description = "Route table name"
    value = azurerm_route_table.this.name
}

# Peering
output "spoke_to_hub_peering_id" {
    description = "Resource ID of the spoke-to-Hub peering. useful for dependency chaining"
    value = azurerm_virtual_network_peering.spoke_to_hub.id
}


output "hub_to_spoke_peering_id" {
    description = "Resource ID of the Hub-to-spoke peering. useful for dependency chaining"
    value = azurerm_virtual_network_peering.hub_to_spoke.id
}