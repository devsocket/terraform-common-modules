# Module: connectivity/private_dns

Creates Azure Private DNS zones for privatelink services and links them to
hub and spoke VNets. Required before deploying any private endpoints — without
DNS zone links, private endpoint hostnames will not resolve correctly.

## Resources Created
- `azurerm_resource_group`
- `azurerm_private_dns_zone` × N (one per zone in dns_zones list)
- `azurerm_private_dns_zone_virtual_network_link` — hub × N zones
- `azurerm_private_dns_zone_virtual_network_link` — spoke × N zones × M spokes

## Usage
```hcl
module "private_dns" {
  source = "../../../modules/connectivity/private_dns"

  resource_group_name = "rg-connectivity-dns"
  location            = "eastus"

  dns_zones = [
    "privatelink.azurecr.io",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net"
  ]

  hub_vnet_id        = "<hub_vnet_resource_id>"
  hub_vnet_link_name = "vnetlink-hub"

  spoke_vnet_links = {
    "dev" = "<dev_spoke_vnet_resource_id>"
  }

  spoke_vnet_link_name_prefix = "vnetlink-spoke"
  enable_auto_registration    = false

  tags = {
    environment = "connectivity"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "private-dns"
  }
}
```

## Referencing Zone IDs in Private Endpoint Modules
```hcl
# ACR private endpoint example
resource "azurerm_private_endpoint" "acr" {
  ...
  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [module.private_dns.zone_ids["privatelink.azurecr.io"]]
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| dns_zones | list(string) | [acr, kv, blob] | DNS zone names to create |
| hub_vnet_id | string | — | Hub VNet resource ID |
| hub_vnet_link_name | string | "vnetlink-hub" | Hub VNet link name prefix |
| spoke_vnet_links | map(string) | {} | Map of spoke label to VNet ID |
| spoke_vnet_link_name_prefix | string | "vnetlink-spoke" | Spoke VNet link name prefix |
| enable_auto_registration | bool | false | Enable VM auto-registration |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| zone_ids | Map of zone name → resource ID |
| zone_names | Map of zone name → confirmed name |
| resource_group_name | Resource group name |
| hub_vnet_link_ids | Map of zone name → hub link ID |
| spoke_vnet_link_ids | Map of composite key → spoke link ID |

## Notes
- Always set `enable_auto_registration = false` for privatelink zones
- Deploy this before any private endpoints — they depend on zone IDs from this module
- Adding a new spoke later is just adding an entry to `spoke_vnet_links` map
- Adding a new zone later is just appending to `dns_zones` list