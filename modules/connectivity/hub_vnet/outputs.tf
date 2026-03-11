output "vnet_id" {
  description = "Resource ID of the Hub Vnet. Used by perring and DNS zone link modules"
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the Hub Vnet. Used by perring and DNS zone link modules"
  value = azurerm_virtual_network.this.name
}
output "vnet_address_space" {
  description = "Address space of the hub VNet. Useful for spoke UDR and NSG rule references"
  value = azurerm_virtual_network.this.address_space
}
output "resource_group_name" {
  description = "Name of the resource group where the Hub Vnet is deployed. Used by perring and DNS zone link modules"
  value = azurerm_resource_group.this.name
}
output "management_subnet_id" {
  description = "Resource ID of the ManagementSubnet. Used for jumpbox NIC or Bastion association"
  value = azurerm_subnet.management.id
}

output "managememt_subnet_name" {
  description = "Management Subnet's name"
  value = azurerm_subnet.management.name
}
output "gateway_subnet_id" {
  description = "Resource ID of the GatewaySubnet. Used for VPN or ExpressRoute gateway association"
    value = var.enable_gateway_subnet ? azurerm_subnet.gateway[0].id : null
}