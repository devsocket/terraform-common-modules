variable "resource_group_name" {
  description = "Name of the resource group to create for Log Analytics."
  type        = string
}

variable "location" {
  description = "Azure region for all resources in this module."
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain logs. Minimum 30 for free tier."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "enable_container_insights" {
  description = "Deploy ContainerInsights solution (required for AKS monitoring)."
  type        = bool
  default     = true
}

variable "enable_security_insights" {
  description = "Deploy SecurityInsights solution (Sentinel lite)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
