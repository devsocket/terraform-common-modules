resource "azurerm_resource_group" this {
    name = var.resource_group_name
    location = var.location
    tags = var.tags
}

# Key Vault
resource "azurerm_key_vault" "this" {
    name = var.key_vault_name
    location = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name
    tenant_id = var.tenant_id
    sku_name = var.sku

    #RBAC mode - access policies are disabled entirely
    # Access is manged via azurerm_role_assignment resources included
    enable_rbac_athorization = true

    soft_delete_protection_days = var.soft_delete_protection_days
    purge_protection_enabled = var.purge_protection_enabled
    public_network_access_enabled  = var.public_network_access_enabled

    tags = var.tags
}

# Role Assignments
# for_each over the role_assignments map
# Each entry creates one role assignment on the Key Vault scope
# Key is used as a stable identifier in Terraform state
resource "azurerm_role_assignments" "this" {
    for_each = var.role_assignments

    scope = azurerm_key_vault.this.id
    role_definition_name = each.value.role
    principle_id = each.value.principle_id

}

# Diagnostic Settings
# Only created when log_analytics_workspace_id is provided
# Sends all Key Vault audit logs and metrics to Log Analytics
# Covers: AuditEvent, AzurePolicyEvaluationDetails, AllMetrics

resource "azurerm_monitor_diagnostic_setting" "this"{
    count = var.log_analytics_workspace_id != null ? 1:0

    name = "diag-${var.key_vault_name}"
    target_resource_id = azurerm_key_vault.this.id
    log_analytics_workspace_id = var.log_analytics_workspace_id

    enabled_log {
        category = "AuditEvent"
    }

    enabled_log {
        category = "AzurePolicyEvaluationDetails"
    }

    metric {
        category = "AllMetrics"
        enabled = true
    }

}
