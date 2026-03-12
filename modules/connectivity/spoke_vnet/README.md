# Module: connectivity/spoke_vnet

Creates a Spoke Virtual Network with subnets for AKS, App Gateway, and Private
Endpoints. Establishes bidirectional VNet peering with the Hub. Attaches an
empty Route Table to all subnets ready for future Firewall or NVA routing.

## Resources Created
- `azurerm_resource_group`
- `azurerm_virtual_network`
- `azurerm_subnet` — AKS node pool
- `azurerm_subnet` — App Gateway
- `azurerm_subnet` — Private Endpoints
- `azurerm_route_table`
- `azurerm_subnet_route_table_association` × 3
- `azurerm_virtual_network_peering` — spoke to hub
- `azurerm_virtual_network_peering` — hub to spoke

## Usage
```hcl
module "spoke_vnet" {
  source = "../../../modules/connectivity/spoke_vnet"

  resource_group_name   = "rg-connectivity-spoke-dev"
  location              = "eastus"
  vnet_name             = "vnet-spoke-dev-devsocket"
  vnet_address_space    = ["10.1.0.0/16"]

  aks_subnet_name       = "snet-aks"
  aks_subnet_cidr       = "10.1.0.0/22"

  appgw_subnet_name     = "snet-appgw"
  appgw_subnet_cidr     = "10.1.4.0/24"

  private_endpoints_subnet_name = "snet-privateendpoints"
  private_endpoints_subnet_cidr = "10.1.5.0/27"

  hub_vnet_id             = ""
  hub_vnet_name           = "vnet-hub-devsocket"
  hub_resource_group_name = "rg-connectivity-hub"

  route_table_name              = "rt-spoke-dev"
  disable_bgp_route_propagation = false

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "spoke-network"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| vnet_name | string | — | Spoke VNet name |
| vnet_address_space | list(string) | ["10.1.0.0/16"] | VNet address space |
| aks_subnet_name | string | "snet-aks" | AKS subnet name |
| aks_subnet_cidr | string | "10.1.0.0/22" | AKS subnet CIDR |
| appgw_subnet_name | string | "snet-appgw" | App Gateway subnet name |
| appgw_subnet_cidr | string | "10.1.4.0/24" | App Gateway subnet CIDR |
| private_endpoints_subnet_name | string | "snet-privateendpoints" | Private endpoints subnet name |
| private_endpoints_subnet_cidr | string | "10.1.5.0/27" | Private endpoints subnet CIDR |
| hub_vnet_id | string | — | Hub VNet resource ID (required) |
| hub_vnet_name | string | — | Hub VNet name (required) |
| hub_resource_group_name | string | — | Hub VNet resource group (required) |
| route_table_name | string | "rt-spoke-dev" | Route table name |
| disable_bgp_route_propagation | bool | false | Disable BGP route propagation |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | Spoke VNet resource ID |
| vnet_name | Spoke VNet name |
| vnet_address_space | Confirmed address space |
| resource_group_name | Resource group name |
| aks_subnet_id | AKS subnet ID → azurerm_kubernetes_cluster |
| aks_subnet_name | AKS subnet name |
| appgw_subnet_id | App Gateway subnet ID → azurerm_application_gateway |
| appgw_subnet_name | App Gateway subnet name |
| private_endpoints_subnet_id | Private endpoints subnet ID → azurerm_private_endpoint |
| private_endpoints_subnet_name | Private endpoints subnet name |
| route_table_id | Route table ID |
| route_table_name | Route table name |
| spoke_to_hub_peering_id | Spoke → Hub peering ID |
| hub_to_spoke_peering_id | Hub → Spoke peering ID |

## Notes
- Hub peering inputs are required — no defaults. Caller must pass hub outputs explicitly
- Route table is created empty — add routes when Firewall or NVA is introduced
- `private_endpoint_network_policies` is set to `Enabled` on the private endpoints subnet
- AKS subnet uses `/22` by default — do not reduce below `/24` or pod IP exhaustion will occur
- App Gateway subnet uses `/24` — Microsoft recommendation for WAF v2 autoscaling