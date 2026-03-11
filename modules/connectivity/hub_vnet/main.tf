resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name = var.vnet_name
  address_space = var.vnet_address_space
  location = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "management" {
  name = var.management_subnet_name
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = [var.management_subnet_cidr]
}

resource "azurerm_subnet" "gateway" {
    count = var.enable.gateway_subnet ? 1 : 0
    name = "GatewaySubnet"
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes = [var.gateway_subnet_cidr]
}