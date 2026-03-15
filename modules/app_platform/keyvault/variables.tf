variable "resource_group_name" {
    description = "Resource Group Name where the key vault deployed."
    type = string
}

variable "location" {
    description = "Azure Region that the key vault is deployed to."
    type = string
    default = "canadacentral"
}

variable "tenant_id" {
    description = "Azure AD tenant ID, required for Key Vault configuration"
    type = string
}

variable "key_vault_name" {
    description = "Key Vault name, should be globally unique, lowercase alpha numeric, 5 to 50 chars."
    type = string
    
    validation {
        condition = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
        error_message = "Invalid Key Vault Name. should be lower case alpha numeric and between 5 to 50 chars."
    }
}

variable "sku" {
    description = "Key vault SKU or Tier. for demo purpuse Standard, for HSM backed kets use Premium"
    type = string

    validation {
        condition = contains(["standard", "premium"], var.sku)
        error_message = "Invalid sku selected, allowed are Standard or Premium only."
    }
}

variable "soft_delete_protection_days" {
    description = "Number of days that the deleted data will be available before deleting permanantly."
    type = number
    default = 7

    validation {
        condition = var.soft_delete_protection_days >= 7 && var.soft_delete_protection_days <= 14
        error_message = "Given soft delete period is too long than allowed." 
    }
}

variable "purge_protection_enabled" {
    description  = "Purge Protection Enabled (forbid deletion). WARNING — once enabled cannot be disabled. Set false for demo to allow clean destroy."
    type = bool
    default = false
}


# Network Access
variable "public_network_access_enabled" {
    description = "Allow public access when accessing Key Vault. Set to false when using private endpints"
    type = bool
    default = true
}


# Role Assignments

variable "role_assignments" {
    description = "Map of role assignments to create on this key vault. Key is label, value is object with role and principle_id"
    type = map(object({
        role = string
        principle_id = string
    }))

    default = {}

    #Example
    # role_assignments = {
    #  "aks-workload" = {
    #    role = "Key Vault Secrets User"
    #   principle_id = "<managed_object_id>"
    # }
    #}

}

# Diagnostics 
variable "log_analytics_workspace_id" {
    description = "Log Analytics workspace resourc ID for diagnostic settings. leave null to skip diagnostics"
    type = string
    default = null
}

variable "tags" {
    description = "Tags applied to all resources in this deployment"
    type = map(string)
    default = {}
}
