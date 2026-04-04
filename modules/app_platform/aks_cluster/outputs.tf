output "cluster_id" {
    description = "Resource ID of the AKS cluster. Used for role assignments and monitoring configurations."
  value = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  description = "Resource group where AKS was created."
  value = azurerm_resource_group.this.name
}

output "kube_config_raw" {
  description = "Raw kubeconfig for cluster access. Sensitive - do not log or store in plain text"
  value = azurerm_kubernetes_cluster.this.kube_config_raw
    sensitive = true
}

output "host" {
  description = "The hostname of the AKS cluster."
  value = azurerm_kubernetes_cluster.this.kube_config[0].host
    sensitive = true
}

# Identity outputs for role assignments and workload identity configuration
output "cluster_identity_principal_id" {
  description = "Principal ID of the cluster's managed identity. Used for role assignments and workload identity configuration"
  value = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity. Used for ACR pull role assignment if enable_aks_pull_access is true"
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "kubelet_identity_client_id" {
  description = "Client ID of the kubelet managed identity. Used for ACR pull role assignment if enable_aks_pull_access is true"
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id 
}


#OIDC issuer URL, used for workload identity configuration in AKS and applications
output "oidc_issuer_url" {
  description = "OIDC issuer URL for the cluster, used for workload identity configuration. Only populated if enable_workload_identity is true"
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

# AGIC
output "agic_identity_object_id" {
  description = "Object ID of the AGIC managed identity. Needs contributor role on App Gateway resource group"
  value = var.enable_agic && var.app_gateway_id != null ? azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id : null
}

# Node resource group where the agent nodes and associated resources like node managed identity and disk are created. Useful for monitoring and role assignments at the node level
output "node_resource_group" {
  description = "Node resource group where the agent nodes and associated resources like node managed identity and disk are created. Useful for monitoring and role assignments at the node level"
  value = azurerm_kubernetes_cluster.this.node_resource_group
}
