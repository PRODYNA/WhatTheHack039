resource "random_integer" "random" {
  min = 1000
  max = 9999
}

locals {
  common-name              = "hack${random_integer.random.result}"
  sql-password-secret-name = "sql-server-password"
}

# Resource group for all hack related resources
resource "azurerm_resource_group" "hack" {
  name     = local.common-name
  location = var.default_location
}

