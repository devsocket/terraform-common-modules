variable "resource_group_name" {
    type = string
    description = "Name of the resource group to create the Storage Account."
}

variable "location" {
    type = string
    description = "Azure Region that the Storage Account will be deployed to."
}

variable "storage_account_name" {
    type = string
    description = "Storage account name to interact with. should be unique globally. 3-24 chars, lowercase alpha numerics only."

    validation {
        condition = can(regex("^[a-z0-9]{3-24}$", var.storage_account_name))
        error_message = "Storage account must be of 3-35 lowercase alpha numerics only."
    }
}

variable "account_tier" {
    description = "Storage account tier name, Standard for general purpose and premium for high performance"
    type = string

    validation {
        condition = contains(["Standard, Premium"], var.account_tier)
        error_message = "Invalid account tier. allowed Standard or Premium only."
    }

}

variable "account_replication_type" {
    type = string
    description = "Replication Type. use LRS for dev. allowed are LRS, GRS, ZRS, GZRS, RA-GZRS"
    validation {
        condition = contains(["LRS", "ZRS", "GRS", "GZRS", "RAGZRS"], var.account_repliaction_type)
        error_message = "Invalid replication type mentioned."
    }
}

variable "account_kind" {
    description = "Storage account kind. StandardV2 is recommended for general purposes."
    type = string
    default = "StandardV2"
}

variable "access_tier" {
    description = "Access tier for storage blob. Hot for frequently access data, cool for infrequent."
    type = string
    default = "Hot"

    validation {
        condition = contains(["Hot", "Cool"], var.access_tier)
        error_message = "Invalid Access Tier."
    }
}

# Security
variable "https_traffic_only_enabled" {
    description = "Enforce Https traffic only."
    type = bool
    default = true
}

variable "min_tls_version" {
    description = "Minimum TLS version. TLS1.2 is the current recommended version."
    type = string
    default = "TLS1.2"
}

variable "public_network_access_enabled" {
    description = "Allow public network access. True for basic demo, use private endpoint for security."
    type = bool
    default = true
}

variable "allow_nested_items_to_be_public" {
    description = "Allow blob public access. disabled by default - blobs shouldn't be allowed to access publicly"
    type = bool
    default = false
}

# Blob containers
variable "containers" {
    description = "Map of containers to create. Key is the container name, value is the access type"
    type = map(string)
    default = {}
     # Example:
  # containers = {
  #   "app-data"  = "private"
  #   "app-logs"  = "private"
  # }
}

# Life cycle policy
variable "enable_lifecycle_policy {
    description = "Enable blob lifecycle management policy."
    type = bool
    default = false
}

variable "lifecycle_deletion_after_days" {
    description = "Delete blob after these many days. applicable when enable_lifecycle_policy is set to true"
    type = number
    default = 30
}

variable "log_analytics_workspace_id" {
    description = "Log Analytics workspace resource ID for diagnostics settings. leave to null to skip diagnostics"
    type = string
    default = null
}

# tags
variable "tags" {
    description = "tags applicable to all resource created by this module"
    type = map(string)
    default = {}
}

