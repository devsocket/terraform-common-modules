output "acr_id" {
    description = "Resource ID of ACR. Used for role assignment and diagnostic settings."
    value = azurerm_container_registry.this.id
}

ouput "acr_name" {
    description = "Name of ACR, used in AKS node pool configurations and CI/CD pipelines."
    value = azurerm_container_registry.this.name
}

output "login_server" {
    description = "ACR login server URL e.g:, devsocketacr.azurecr.io, used in Kubernetes image references"
    value = azurerm_container_registry.this.login_server
}

output "resource_group_name" {
    description = "Resource Group where ACR is created."
    value = azurerm_resource_group.this.name
}

output "admin_username" {
    description = "ACR admin user name. Empty string when admin_enabled is 'false'"
    value = azurerm_container_registry.this.admin_username
    sensitive = true
}

output "admin_password" {
    description = "ACR admin password. Empty when admin_enabled is 'false'"
    value = azurerm_container_registry.this.admin_password
    sensitive = true
}