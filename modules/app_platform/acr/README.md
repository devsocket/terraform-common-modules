# Module: app_platform/acr

Creates an Azure Container Registry for storing and managing container images.
Optionally grants AKS kubelet identity the AcrPull role for passwordless image pulls.

## Resources Created
- `azurerm_resource_group`
- `azurerm_container_registry`
- `azurerm_role_assignment` — AcrPull for AKS kubelet identity (optional)

## Usage
```hcl
module "acr" {
  source = "../../../modules/app_platform/acr"

  resource_group_name = "rg-shared-acr"
  location            = "eastus"
  acr_name            = "devsocketacr"
  sku                 = "Basic"
  admin_enabled       = false

  # Wire up after AKS is deployed
  enable_aks_pull_access         = false
  aks_kubelet_identity_object_id = null

  tags = {
    environment = "shared"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}
```

## Upgrading from Basic to Premium

To enable private endpoint later:
1. Change `sku = "Premium"`
2. Add `network_rule_set` block to restrict access to spoke VNet
3. Deploy private endpoint using `privatelink.azurecr.io` DNS zone
4. Add `georeplications` list if needed

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| acr_name | string | — | Registry name — globally unique, 5-50 chars, lowercase alphanumeric |
| sku | string | "Basic" | Basic, Standard or Premium |
| admin_enabled | bool | false | Enable admin credentials |
| georeplications | list(string) | [] | Regions to replicate to (Premium only) |
| enable_aks_pull_access | bool | false | Create AcrPull role for AKS |
| aks_kubelet_identity_object_id | string | null | AKS kubelet identity object ID |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| acr_id | ACR resource ID |
| acr_name | ACR name |
| login_server | Login server URL e.g. devsocketacr.azurecr.io |
| resource_group_name | Resource group name |
| admin_username | Admin username (sensitive, empty if admin disabled) |
| admin_password | Admin password (sensitive, empty if admin disabled) |

## Notes
- Always use managed identity AcrPull over admin credentials for AKS
- ACR name must be globally unique across all Azure — prefix with your handle
- Basic SKU has no private endpoint, VNet integration or geo-replication support
- Set `enable_aks_pull_access = true` only after AKS is deployed and kubelet identity is known