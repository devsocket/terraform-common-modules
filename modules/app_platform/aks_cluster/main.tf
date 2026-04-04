resource "azurerm_resource_group" "this" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.dns_prefix
  kubernetes_version = var.kubernetes_version
  sku_tier = var.sku_tier

  default_node_pool {
    name       = var.node_pool_name
    node_count = var.node_count
    vm_size    = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    max_pods = var.max_pods

    # Place nodes in the AKS subnet of the spoke VNet
    # Azure CNI allocates pod IPs directly from this subnet
    vnet_subnet_id = var.vnet_subnet_id

    node_labels = var.node_labels

    upgrade_settings {
      max_surge = "10%"
    }
  }

 # System-assigned managed identity
  # Azure automatically creates and manages the identity lifecycle
  identity {
    type = "SystemAssigned"
  }

 # Network profile
    network_profile {
        network_plugin = var.network_plugin
        network_policy = var.network_policy
        service_cidr   = var.service_cidr
        dns_service_ip = var.dns_service_ip
    }

    # Managed AGIC add-on for ingress, only available in certain regions and requires at least 3 nodes in the default node pool
    # Requires App Gateway to exist first — pass app_gateway_id from App Gateway module
    dynamic "ingress_application_gateway" {
      for_each = var.enable_agic && var.app_gateway_id != null   ? [1] : []
        content {
            gateway_id = var.app_gateway_id
        }
    }

    #Workload identity
    # Enable pod-level AD identity
    # Pods can authenticate to Azure AD and access resources like Key Vault without needing cluster-level managed identity permissions
    oidc_issuer_enabled = var.enable_workload_identity
    workload_identity_enabled = var.enable_workload_identity

    # OMS agent add-on for monitoring and log analytics, requires Log Analytics workspace to be created in the same region
    # Pass workspace ID from remote state or outputs of the monitoring module
    dynamic "oms_agent" {
      for_each = var.log_analytics_workspace_id != null ? [1] : []
        content {
            log_analytics_workspace_id = var.log_analytics_workspace_id
        }
    }

    #Azure Policy
    # Enforce policies at the cluster level, such as allowed container registries or required tags on resources created by the cluster
    # Requires Azure Policy add-on to be enabled in the subscription and appropriate policies assigned

    azure_policy_enabled = true

  tags = var.tags
}

resource "azurerm_monitoring_diagnostic_setting" "this" {
    for_each = var.log_analytics_workspace_id != null ? 1: 0

    name = "diag-${var.cluster_name}"
    target_resource_id = azurerm_kubernetes_cluster.this.id
    log_analytics_workspace_id = var.log_analytics_workspace_id

    enabled_log {
        category = "kube-apiserver"
    }

    enabled_log {
        category = "kube-controller-manager"
    }

    enabled_log {
        category = "kube-scheduler"
    }

    enabled_log {
        category = "kube-audit"
    }

    enabled_log {
        category = "kube-audit-admin"
    }

    enabled_metric {
        category = "AllMetrics"
    }

    enabled_log {
        category = "guard"
    }
}