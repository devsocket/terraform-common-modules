# Module: management/log_analytics

Creates a Log Analytics workspace with optional solutions.
Acts as the central observability sink for AKS, App Gateway, Key Vault,
Storage and all other platform services.

## Resources Created
- `azurerm_resource_group`
- `azurerm_log_analytics_workspace`
- `azurerm_log_analytics_solution` — ContainerInsights (optional)
- `azurerm_log_analytics_solution` — SecurityInsights (optional)

## Usage
```hcl
module "log_analytics" {
  source = "../../../modules/management/log_analytics"

  resource_group_name       = "rg-management-monitoring"
  location                  = "eastus"
  workspace_name            = "law-management-devsocket"
  retention_in_days         = 30
  enable_container_insights = true
  enable_security_insights  = false

  tags = {
    environment = "management"
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
| workspace_name | string | — | Workspace name |
| retention_in_days | number | 30 | Log retention (30–730) |
| enable_container_insights | bool | true | Enable ContainerInsights solution |
| enable_security_insights | bool | false | Enable SecurityInsights solution |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| workspace_id | Resource ID of the workspace |
| workspace_name | Name of the workspace |
| workspace_customer_id | Customer ID used in AKS + diagnostics |
| primary_shared_key | Shared key (sensitive) |
| resource_group_name | Resource group name |

## Notes
- `primary_shared_key` is marked sensitive — won't appear in plan output
- `workspace_customer_id` is the GUID used in diagnostic settings, not the ARM resource ID
- ContainerInsights is enabled by default as AKS depends on it
- Never add a `backend.tf` to this folder — modules do not manage state