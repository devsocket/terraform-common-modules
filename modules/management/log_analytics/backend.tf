terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0, < 4.0.0"
    }
  }

  backend "azurerm" {
    # Values populated from bootstrap — update these to match your bootstrap output
    # resource_group_name  = "rg-tfstate-devsocket"
    # storage_account_name = "stgtfstatedevsocket"
    # container_name       = "tfstate"
    key = "shared/monitoring/log-analytics.tfstate"
  }
}

provider "azurerm" {
  features {}
  # Uses ARM_SUBSCRIPTION_ID env var — set to devsocket-management-sub ID
  # subscription_id = var.management_subscription_id
}
