# Module: app_platform/key_vault

Creates an Azure Key Vault with RBAC authorization mode, soft delete,
optional role assignments, and optional Log Analytics diagnostic settings.

## Resources Created
- `azurerm_resource_group`
- `azurerm_key_vault`
- `azurerm_role_assignment` × N (one per entry in role_assignments map)
- `azurerm_monitor_diagnostic_setting` (optional)

## Usage
```hcl
data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "github.com/devsocket/terraform-common-modules/modules/app_platform/key_vault"

  resource_group_name = "rg-shared-keyvault"
  location            = "eastus"
  key_vault_name      = "devsocket-kv"
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = true

  role_assignments = {
    "aks-workload" = {
      role         = "Key Vault Secrets User"
      principal_id = "<aks-workload-identity-object-id>"
    }
  }

  log_analytics_workspace_id = "<log-analytics-workspace-resource-id>"

  tags = {
    environment = "shared"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}
```

## Key Vault RBAC Roles Reference

| Role | Use Case |
|------|----------|
| Key Vault Administrator | Full control — assign to operators |
| Key Vault Secrets Officer | Read/write secrets — assign to CI/CD |
| Key Vault Secrets User | Read secrets only — assign to AKS workload identity |
| Key Vault Crypto Officer | Read/write keys — assign to encryption services |
| Key Vault Reader | Read metadata only — assign to auditors |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| key_vault_name | string | — | Vault name — globally unique, 3-24 chars |
| sku_name | string | "standard" | standard or premium |
| tenant_id | string | — | Azure AD tenant ID |
| soft_delete_retention_days | number | 7 | Retention 7-90 days |
| purge_protection_enabled | bool | false | Enable purge protection |
| public_network_access_enabled | bool | true | Allow public access |
| role_assignments | map(object) | {} | RBAC role assignments |
| log_analytics_workspace_id | string | null | Log Analytics workspace ID |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | Key Vault resource ID |
| key_vault_name | Key Vault name |
| key_vault_uri | Vault URI for application config |
| resource_group_name | Resource group name |
| tenant_id | Tenant ID |
| diagnostic_setting_id | Diagnostic setting ID or null |

## Notes
- `purge_protection_enabled` defaults to false for demo destroy compatibility
- Set `purge_protection_enabled = true` in production — cannot be undone
- `tenant_id` should come from `data.azurerm_client_config.current.tenant_id` in the caller
- RBAC mode means access policies are completely ignored — use role assignments only
- Soft deleted vaults persist for `soft_delete_retention_days` after destroy — purge manually if needed