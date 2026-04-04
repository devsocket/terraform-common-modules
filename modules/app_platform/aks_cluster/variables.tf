variable "location" {
    description = "Azure region for all the resources in this module "
    type        = string
}

variable "resource_group_name" {
    description = "Name of the resource group"
    type        = string
}

variable "cluster_name" {
  description = "name of the AKS cluster"
  type = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster FQDN. must be unique with in the region"
  type = string
}

variable "kubernetes_version" {
    description = "Version of Kubernetes to use for the AKS cluster. Use 'az aks get-versions -l <region> -o table' to see available versions in a region."
    type = string
    default = null
}

variable "sku_tier" {
    description = "SKU tier for the AKS cluster. Determines available features and pricing. Refer to https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS/ for guidance on selecting the appropriate SKU tier for your workload."
    type = string
    default = "Free"

    validation {
      condition = contains(["Free", Standard], var.sku_tier)
      error_message = "Invalid tier specified"
    }
}

variable "node_pool_name" {
  description = "Name of the node pool"
  type = string
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type = number
  default = 1
}

variable "vm_size" {
  description = "VM size for default node pool"
  type = string
  default = "Standard_B2s"
}

variable "os_disk_size_gb" {
    description = "Size of the OS disk for the node pool"
    type = number
    default = 30
}

variable "max_pods" {
    description = "Maximum number of pods that can run on a node in the node pool. This setting helps optimize IP address utilization. Refer to https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS/ for guidance on selecting the appropriate max pods setting for your workload."
    type = number
    default = 30
}

variable "node_labels" {
    description = "Map of node labels to apply to all nodes in the node pool. Useful for organizing and selecting nodes for deployments."
    type = map(string)
    default = {}
}

# Networking variables

variable "vnet_subnet_id" {
  description = "AKS node pool subnet ID. must be in spoke VNet. required by Azure CNI"
  type = string
}

variable "network_plugin" {
  description = "Network plugin to use for the AKS cluster. Determines the networking model used by the cluster."
  type = string
  default = "azure"

  validation {
    condition = contains(["azure", "calico"], var.network_plugin)
    error_message = "Network plugin must be either 'azure' or 'calico'"
  }
}

variable "network_policy" {
  description = "Network Policy engine to use for the AKS cluster. Controls pod-to-pod communication."
  type = string
  default = "azure"

  validation {
    condition = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be either 'azure' or 'calico'"
  }
}

variable "service_cidr" {
  description = "CIDR for kubernetes service IPs, Must not overlap with VNet Cidrs"
  type = string
  default = "172.16.0.0/16"
}


variable "dns_service_ip" {
  description = "IP address for the Kubernetes DNS service. Must be with in service CIDR"
  type = string
  default = "172.16.0.10"
}

# AGIC

variable "enable_agic" {
    description = "Whether to enable AGIC add-on for the cluster. Requires application gateway and subnet to be configured in the spoke VNet."
    type = bool
    default = true
}

variable "app_gateway_id" {
  description = "Resource ID of teh application Gateway for AGIC. required when 'enable_agic' is true."
  type = string
  default = null
}

# Workload identity

variable "enable_workload_identity" {
  description = "Enable workload identity and OIDC issuer. required for pod-level key vault access"
  type = bool
  default = true
}

# Diagnostics
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace to use for cluster diagnostics. If not provided, diagnostics will not be configured."
  type = string
  default = null
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources in this module."
    type        = map(string)
    default = {}
}