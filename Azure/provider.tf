terraform {
  required_providers {

    // Needed for Azure things
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }

    // Random number generator
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    // For executing local scripts
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = "= 1.5.5"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

