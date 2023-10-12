terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }

  required_version = "= 1.5.5"
}

provider "azurerm" {
  features {}
}

