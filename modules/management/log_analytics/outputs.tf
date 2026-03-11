output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "primary_shared_key" {
  description = "Primary shared key of the Log Analytics workspace. Used for AKS OMS agent."
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "workspace_customer_id" {
  description = "Workspace (customer) ID — used in diagnostic settings and AKS."
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "resource_group_name" {
  description = "Name of the resource group where the workspace was created."
  value       = azurerm_resource_group.this.name
}
