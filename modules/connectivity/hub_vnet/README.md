# terraform-common-modules/modules/connectivity/hub_vnet/README.md

# Module: connectivity/hub_vnet

This module creates the Hub Virtual Network and subnets for a Hub & Spoke topology.
NSGs are intentionally excluded — attach them separately via the `connectivity/nsg` module.

## Resources Created
- `azurerm_resource_group`
- `azurerm_virtual_network`
- `azurerm_subnet` — ManagementSubnet
- `azurerm_subnet` — GatewaySubnet (optional, off by default)

## Usage
```hcl
module "hub_vnet" {
  source = "../../../modules/connectivity/hub_vnet"

  resource_group_name    = "rg-connectivity-hub"
  location               = "eastus"
  vnet_name              = "vnet-hub-devsocket"
  vnet_address_space     = ["10.0.0.0/16"]
  management_subnet_name = "ManagementSubnet"
  management_subnet_cidr = "10.0.1.0/24"
  enable_gateway_subnet  = false

  tags = {
    environment = "connectivity"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| vnet_name | string | — | Hub VNet name |
| vnet_address_space | list(string) | ["10.0.0.0/16"] | VNet address space |
| management_subnet_name | string | "ManagementSubnet" | Management subnet name |
| management_subnet_cidr | string | "10.0.1.0/24" | Management subnet CIDR |
| enable_gateway_subnet | bool | false | Create GatewaySubnet |
| gateway_subnet_cidr | string | "10.0.255.0/27" | GatewaySubnet CIDR |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | Hub VNet resource ID |
| vnet_name | Hub VNet name |
| vnet_address_space | Confirmed address space from Azure |
| resource_group_name | Resource group name |
| management_subnet_id | ManagementSubnet resource ID |
| management_subnet_name | ManagementSubnet name |
| gateway_subnet_id | GatewaySubnet ID or null if disabled |

## Notes
- GatewaySubnet name is hardcoded — Azure requires this exact name it fails otherwise
- NSGs are not created here — attach them separately to keep this module focused on topology
- Address space `10.0.0.0/16` should not overlap with any spoke VNet as this is reserved for Hub Vnet