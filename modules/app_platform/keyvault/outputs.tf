output "resource_group_name" {
    description = "Resource group where Key Vault was created."
    value       = azurerm_resource_group.this.name
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault. Used for role assignments and diagnostic settings."
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault e.g. https://devsocket-kv.vault.azure.net/. Used by applications and AKS workload identity to fetch secrets."
  value       = azurerm_key_vault.this.vault_uri
}

output "tenant_id" {
  description = "Tenant ID the Key Vault is associated with. Useful for workload identity configuration."
  value       = azurerm_key_vault.this.tenant_id
}

output "diagnostic_setting_id" {
  description = "Resource ID of the diagnostic setting. Null when log_analytics_workspace_id was not provided."
  value       = var.log_analytics_workspace_id != null ? azurerm_monitor_diagnostic_setting.this[0].id : null
}
