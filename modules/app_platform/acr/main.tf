resource "resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "this" {
  name = var.acr_name
  resource_group_name = var.resource_group_name
  location = var.location
  sku = var.sku
  admin_enabled = var.admin_enabled

# Geo Replication, only applicable when using PREMIUM tier
    dynamic "georeplications" {
        for_each = var.geo_replication_locations
        content {
            location = georeplications.value
            zone_redundancy_enabled = false
        }
    }

    tags = var.tags
}

# AKS Pull Role Assignment 

# Grant AKS Kubelet identity the AcrPull role on this registry
# Only created when enable_aks_pull_access = true and kubelet Identity is provided
# This allows AKS nodes to pull images without Admin credentials (follows Least privilege principle)

resource "azurerm_role_assignment" "aks_acr_pull" {
    count  = var.enable_aks_pull_access && var.aks_kubelet_identity_object_id != null ? 1: 0

    scope = azurerm_container_registry.this.id
    role_definition_name = "AcrPull"
    principal_id = var.aks_kubelet_identity_object_id
}
