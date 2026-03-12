resource "azurerm_resource_group" "this" {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

resource "azurerm_virtual_network" "this" {
    name = var.vnet_name
    address_space = var.vnet_address_space
    location = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "aks" {
    name = var.aks_subnet_name
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes = [var.aks_subnet_cidr]
}

resource "azurerm_subnet" "appgw" {
  name = var.gateway_subnet_name
  resource_group_name = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = [var.gateway_subnet_cidr]
}

resource "azurerm_subnet" "private_endpoints" {
    name = var.private_endpoint_subnet_name
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
    address_prefixes = [var.private_endpoints_subnet_cidr]

    private_endpoint_network_policies = "Enabled"
}

# Route Table

resource "azurerm_route_table" "this" {
  name =   var.route_table_name
    resource_group_name = azurerm_resource_group.this.name
    location = azurerm_resource_group.this.location
    tags = var.tags
    disable_bgp_route_propagation = var.disable_bgp_route_propogation
}

# Associate route table to subnets
resource "azurerm_subnet_route_table_association" "aks" {
    subnet_id = azurerm_subnet.aks.id
    route_table_id = azurerm_route_table.this.id
}

resource "azurerm_subnet_route_table_association" "appgw" {
    subnet_id = azurerm_subnet.appgw.id
    route_table_id = azurerm_route_table.this.id
}

resource "azurerm_subnet_route_table_association" "private_endpoints" {
    subnet_id = azurerm_subnet.private_endpoints.id
    route_table_id = azurerm_route_table.this.id
}

# Vnet peering
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
    name = "peer-${var.vnet_name}-to-${var.hub_vnet_name}"  
    resource_group_name = azurerm_resource_group.this.name
    virtual_network_name = azurerm_virtual_network.this.name
    remote_virtual_network_id = var.hub_vnet_id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit = false
    use_remote_gateways = false
}


resource "azurerm_virtual_network_peering" "hub_to_spoke" {
    name = "peer-${var.hub_vnet_name}-to-${var.vnet_name}"  
    resource_group_name = var.hub_resource_group_name
    virtual_network_name = var.hub_vnet_name
    remote_virtual_network_id = azurerm_virtual_network.this.id

    allow_virtual_network_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit = false
    use_remote_gateways = false
}