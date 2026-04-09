variable "location" {
  description = "Azure region for all the resources in this module "
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for all the resources in this module "
  type        = string
}

variable "public_ip" {
  description = "Public IP of the Application Gateway frontend"
  type        = string
}

variable "waf_policy_name" {
  description = "name of WAF policy name resource"
  type        = string
}

variable "waf_policy_mode" {
  description = "WAF policy mode to be used"
  type        = string
  default     = "Detection"

  validation {
    condition     = contains(["Prevention", "Detection"], var.waf_policy_mode)
    error_message = "WAF policy must be eiuther Prevention or Detection"
  }

}

variable "waf_rule_set_version" {
  description = "OWASP rule set version, current version is 3.2 and its recommended to use."
  type        = string
  default     = "3.2"

  validation {
    condition     = contains(["3.2", "3.1", "3.0"], var.waf_rule_set_version)
    error_message = "Only OWASP rule set version 3.2 and above are supported for Application Gateway WAF v2"
  }
}

variable "app_gateway_name" {
  description = "name of the Application Gateway resource"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Application Gateway. Only WAF_v2 is supported in this module as it is required for AGIC and autoscaling capabilities."
  type        = string
  default     = "WAF_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "Only SKU WAF_v2 is supported for Application Gateway in this module"
  }
}

variable "sku_tier" {
  description = "SKU tier for the Application Gateway. Determines available features and pricing. Refer to https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ApplicationGateway/ for guidance on selecting the appropriate SKU tier for your workload."
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "Only SKU Standard_v2 and WAF_v2 are supported for Application Gateway in this module"
  }
}

variable "capacity" {
  description = "Capacity for the Application Gateway. Determines the number of instances available. use > 2 for HA"
  type        = number
  default     = 1

  validation {
    condition     = var.capacity >= 1 && var.capacity <= 10
    error_message = "Capacity for Application Gateway must be between 2 and 10"
  }
}
#Networking
variable "subnet_id" {
  description = "Subnet ID for the Application Gateway. must be a /24 or larger subnet for WAF v2 autoscaling capabilities"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Application Gateway diagnostics logs. If not provided, diagnostics will not be enabled for the Application Gateway."
  type        = string
  default     = null
}


variable "tags" {
  description = "Tags to apply to all resources in this module."
  type        = map(string)
  default     = {}
}