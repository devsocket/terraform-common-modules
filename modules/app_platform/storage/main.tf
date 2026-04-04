resource "azurerm_resource_group" "this"{
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

# Storage account
resource "azurerm_storage_account" "this" {
    name = var.storage_account_name
    resource_group_name = azurerm_resource_group.this.name
    location = var.location
    account_tier = var.account_tier
    account_replication_type = var.account_replication_type
    account_kind = var.account_kind
    access_tier = var.access_tier

    https_traffic_only_enabled = var.https_traffic_only_enabled
    min_tls_version = var.min_tls_version
    public_network_access_enabled = var.public_network_access_enabled
    allow_nested_items_to_be_public = var.allow_nested_items_to_be_public

    blob_properties {
        #Enable soft delete for blobs - 7 days retention matches key vault
        #Protects against accidental deletions during demo operations
        delete_retention_policy {
            days = 7
        }

        #Enabled versioning for blob changes tracking
        versioning_enabled = false
    }

    tags = var.tags
}

# Blob containers 
resource "azurerm_storage_container" "this" {
    for_each = var.containers

    name = each.key
    storage_account_name = azurerm_storage_account.this.name
    container_access_type = each.value
}

#Life cycle policy
# Only created when enable_lifecycle_policy = true
# Applies a single rule that deletes blobs after lifecycle_delete_after_days
# Can be extended with additional rules for tiering to Cool/Archive
resource "azurerm_storage_management_policy" "this" {
    count = var.enable_lifecycle_policy ? 1 : 0
    storage_account_id = azurerm_storage_account.this.id

    rule {
        name = "delete-old-blobs"
        enabled = true

        filters {
            blob_types = ["blockBlob"]
        }

        actions {
            base_blob {
                delete_after_days_since_modification_greater_than  = var.lifecycle_deletion_after_days
            }

            snapshot {
                delete_after_days_since_creation_greater_than = var.lifecycle_deletion_after_days
            }
        }
    }
}

#Diagnostic settigns

# Storage diagnostics are more granular than Key Vault
# Each service (blob, queue, table, file) needs its own diagnostic setting
# For this demo we only wire blob since that is what AKS and the app use

resource "azurerm_monitor_diagnostic_setting" "blob" {
    count  = var.log_analytics_workspace_id != null ? 1:0

    name = "diag-${var.storage_account_name}-blob"
    target_resource_id = "${azurerm_storage_account.this.id}/blobService/default"
    log_analytics_workspace_id = var.log_analytics_workspace_id

    enabled_log{
        category = "StorageRead"
    }
    enabled_log{
        category = "StorageWrite"
    }
    enabled_log{
        category = "StorageDelete"
    }
    enabled_log{
        category = "Transaction"
    }
}