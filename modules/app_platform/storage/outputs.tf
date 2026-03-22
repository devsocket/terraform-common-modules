output "storage_account_id" {
    description = "Resource ID of the storage account. used for Role assignments and diagnostic settings."
    value = azurerm_storage_account.this.id
}

output "storage_account_name" {
    description = "name of storage account. referenced in application config and AKS persistence volume claims."
    value = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
    description = "Primary blob service URL. referenced by apps access blob to wrte."
    value = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
    description = "Primary access key for storage account. Sesitive-use managed identities where possible."
    value = azurerm_storage_account.this.primary_access_key
    sensitive = true
}

output "primary_connection_string"{
description= "Primary connection string. Sensitive- store in keyVault, never in app config directly."
value = azurerm_storage_account.this.primary_connection_string
sensitive = true
}

output "resource_group_name" {
    description = "Resource group name where the resources of this module are deployed"
    value = azurerm_resource_group.this.name
}

output "container_ids" {
    description  = "Map of container names to resource IDs. Empty map when no containers were created."
    value ={
        for name, container in azurerm_storage_container.this : 
        name => container.id
    }
}

output "container_names" {
    description = "List of created container names"
    value = keys(azurerm_storage_container.this)
}