resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.workspace_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days

  tags = var.tags
}

# ContainerInsights — required for AKS monitoring
resource "azurerm_log_analytics_solution" "container_insights" {
  count = var.enable_container_insights ? 1 : 0

  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}

# SecurityInsights (Sentinel lite) — useful for demo security posture
resource "azurerm_log_analytics_solution" "security_insights" {
  count = var.enable_security_insights ? 1 : 0

  solution_name         = "SecurityInsights"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }

  tags = var.tags
}
