locals {
  // The name of the database user
  database_user = "azure"
}

// random password for the database server
resource "random_password" "database_password" {
  length           = 16
  special          = false
  override_special = "_%@"
}

// SQL Server
resource "azurerm_mssql_server" "hack" {
  name                         = local.common-name
  resource_group_name          = azurerm_resource_group.hack.name
  location                     = azurerm_resource_group.hack.location
  version                      = "12.0"
  administrator_login          = local.database_user
  administrator_login_password = random_password.database_password.result
}

// SQL database
// TODO Create msssql database with name "mydb" in the server created above
