terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 3.90.0, < 4.0.0"
    }
  }

}