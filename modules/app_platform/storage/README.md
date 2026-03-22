# Module: app_platform/storage

Creates an Azure Storage Account with optional blob containers, lifecycle
management policy, and Log Analytics diagnostic settings.

## Resources Created
- `azurerm_resource_group`
- `azurerm_storage_account`
- `azurerm_storage_container` × N (one per entry in containers map)
- `azurerm_storage_management_policy` (optional)
- `azurerm_monitor_diagnostic_setting` — blob service (optional)

## Usage
```hcl
module "storage" {
  source = "../../../modules/app_platform/storage"

  resource_group_name      = "rg-shared-storage"
  location                 = "eastus"
  storage_account_name     = "devsocketst"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false

  containers = {
    "app-data" = "private"
    "app-logs" = "private"
  }

  enable_lifecycle_policy     = true
  lifecycle_delete_after_days = 30

  log_analytics_workspace_id = "<log-analytics-workspace-resource-id>"

  tags = {
    environment = "shared"
    managed_by  = "terraform"
    project     = "devsocket-landing-zone"
    layer       = "app-platform"
  }
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| resource_group_name | string | — | Resource group name |
| location | string | — | Azure region |
| storage_account_name | string | — | Account name — globally unique, 3-24 chars, lowercase alphanumeric |
| account_tier | string | "Standard" | Standard or Premium |
| account_replication_type | string | "LRS" | LRS, GRS, ZRS etc. |
| account_kind | string | "StorageV2" | Storage account kind |
| access_tier | string | "Hot" | Hot or Cool |
| https_traffic_only_enabled | bool | true | Enforce HTTPS |
| min_tls_version | string | "TLS1_2" | Minimum TLS version |
| public_network_access_enabled | bool | true | Allow public access |
| allow_nested_items_to_be_public | bool | false | Allow blob public access |
| containers | map(string) | {} | Blob containers to create |
| enable_lifecycle_policy | bool | false | Enable lifecycle management |
| lifecycle_delete_after_days | number | 30 | Days before blob deletion |
| log_analytics_workspace_id | string | null | Log Analytics workspace ID |
| tags | map(string) | {} | Resource tags |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | Storage Account resource ID |
| storage_account_name | Storage Account name |
| primary_blob_endpoint | Blob service endpoint URL |
| primary_access_key | Primary access key (sensitive) |
| primary_connection_string | Primary connection string (sensitive) |
| resource_group_name | Resource group name |
| container_ids | Map of container name to resource ID |
| container_names | List of created container names |

## Notes
- Storage account name must be globally unique — prefix with your handle
- Blob soft delete is hardcoded to 7 days — not configurable by design
- Blob versioning is enabled by default — protects against accidental overwrites
- Diagnostic settings target blob sub-resource not the account directly
- Never pass `primary_access_key` or `primary_connection_string` to app config — store in Key Vault
- `allow_nested_items_to_be_public = false` overrides any container-level public access setting