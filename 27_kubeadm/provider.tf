terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm" # Specify the provider for Azure
        version = "~> 3.0" # Specify the version of the Azure provider
    }
  }
    # Specify the required version of Terraform
  required_version = ">= 1.9.0" # Specify the required version of Terraform
}

provider "azurerm" {
  features {} # This block is required to enable the Azure provider features
  use_cli = true
  skip_provider_registration = true # Skip provider registration to avoid issues with Azure provider registration
}