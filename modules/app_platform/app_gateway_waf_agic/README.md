
# Module: app_platform/app_gateway_waf_agic

Creates an Application Gateway WAF v2 with a standalone WAF policy and
public IP. Designed to be managed by AGIC after AKS connects — skeleton
routing configuration is provisioned but ignored on subsequent plans.

## Resources Created
- `azurerm_resource_group`
- `azurerm_public_ip` — Standard SKU, Static
- `azurerm_web_application_firewall_policy` — OWASP 3.2
- `azurerm_application_gateway` — WAF_v2
- `azurerm_monitor_diagnostic_setting` (optional)

## Usage
```hcl
module "app_gateway" {
  source = "../../../modules/app_platform/app_gateway_waf_agic"

  resource_group_name = "rg-appgw-dev"
  location            = "eastus"

  public_ip_name  = "pip-appgw-dev"
  waf_policy_name = "waf-policy-dev"
  waf_policy_mode = "Prevention"
  waf_rule_set_version = "3.2"

  app_gateway_name = "agw-devsocket-dev"
  sku_name         = "WAF_v2"
  sku_tier         = "WAF_v2"
  capacity         = 1

  subnet_id = "<appgw-spoke-subnet-id>"

  log_analytics_workspace_id = "<log-analytics-workspace-id>"

  tags = {
    environment = "dev"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}
```

## Deployment Order

App Gateway must be deployed BEFORE AKS:
```
1. Deploy App Gateway → outputs app_gateway_id
2. Deploy AKS with app_gateway_id → AGIC add-on connects
3. Assign Contributor role to AGIC identity on App Gateway resource group
```

## AGIC Identity Role Assignment

After AKS is deployed, assign Contributor to the AGIC identity:
```hcl
resource "azurerm_role_assignment" "agic_contributor" {
  scope                = module.app_gateway.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = module.aks.agic_identity_object_id
}
```

## lifecycle ignore_changes

The following App Gateway properties are ignored after initial creation
because AGIC manages them dynamically:

- `backend_address_pool`
- `backend_http_settings`
- `http_listener`
- `request_routing_rule`
- `frontend_port`
- `probe`
- `redirect_configuration`
- `ssl_certificate`

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| public_ip_name | string | — | Public IP name |
| waf_policy_name | string | — | WAF policy name |
| waf_policy_mode | string | "Prevention" | Detection or Prevention |
| waf_rule_set_version | string | "3.2" | OWASP rule set version |
| app_gateway_name | string | — | App Gateway name |
| sku_name | string | "WAF_v2" | WAF_v2 or Standard_v2 |
| sku_tier | string | "WAF_v2" | WAF_v2 or Standard_v2 |
| capacity | number | 1 | Capacity units 1-125 |
| subnet_id | string | — | Dedicated App Gateway subnet ID |
| log_analytics_workspace_id | string | null | Log Analytics workspace ID |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| app_gateway_id | App Gateway resource ID → AKS AGIC add-on |
| app_gateway_name | App Gateway name |
| resource_group_name | Resource group name |
| resource_group_id | Resource group ID → AGIC Contributor scope |
| public_ip_address | Frontend public IP → DNS A record |
| public_ip_id | Public IP resource ID |
| waf_policy_id | WAF policy resource ID |
| waf_policy_name | WAF policy name |

## Notes
- App Gateway subnet must be dedicated — no other resources allowed
- Standard SKU public IP required — Basic SKU not supported with v2
- WAF_v2 has a base cost of ~$0.36/hour regardless of traffic
- `lifecycle ignore_changes` is critical — remove it and every plan will show AGIC drift
- AGIC identity Contributor role must be assigned after AKS deploy
- `request_routing_rule` requires unique `priority` — 100 is the skeleton default