locals {
  # Relative path to Repo A — update to GitHub source when repo is published
  # source = "github.com/devsocket/terraform-common-modules//modules/management/log_analytics?ref=v1.0.0"
  common_modules_path = "../../../../terraform-common-modules/modules"
}

module "log_analytics" {
  source = "../../../../terraform-common-modules/modules/management/log_analytics"

  resource_group_name       = var.resource_group_name
  location                  = var.location
  workspace_name            = var.workspace_name
  retention_in_days         = var.retention_in_days
  enable_container_insights = var.enable_container_insights
  enable_security_insights  = var.enable_security_insights
  tags                      = var.tags
}
