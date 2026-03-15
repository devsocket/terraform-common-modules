variable "resource_group_name" {
  description = "Name of the resource group where the spoke virtual network will be created."
  type        = string
}

variable "location" {
    description = "Azure region for all the resources in this module "
    type        = string
}

# ACR details
variable "acr_name" {
    description = "Name of the Azure Container Registry instance to create. Must be globally unique."
    type = string

    validation {
      condition = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
      error_message = "ACR name must be 5 to 50 character length and only lowercadse Alpha Numerics"
    }
}

variable "sku" {
    description = "ACR SKU, Basic for demo, Premium required for private endpoints and gep-replication and high concurrency"
    type = string
    default = "Basic"

    validation {
        condition = contains(["Basic", "Standard", "Premium"], var.sku)
        error_message = "Invalid ACR SKU specified, allowed are 'BASIC', 'STANDARD' or 'PREMIUM' only."
    }
}

variable "admin_enabled" {
    description = "Enable Admin user on registry. disabled by default, use managed entities to pull images from ACR"
    type = bool
    default = false
}

variable "geo_replication_locations" {
    description = "List of Azure regions for geo-replication. Only applicable if sku is Premium."
    type = list(string)
    default = []
}

# ACR Pull Role Assignment details
variable "enable_aks_pull_access" {
    description = "Create AcrPull role assignment for AKS kubelet identity. Set to true once AKS is deployed"
    type = bool
    default = false
}

variable "aks_kubelet_identity_object_id" {
    description = "Object ID of AKS kubelet managed identity. Required when enable_aks_pull_access is true"
    type = string
    default = null
}

# Tags
variable "tags" {
    description = "Tags to apply to all resources created by this module"
    type = map(string)
    default = {}
}
