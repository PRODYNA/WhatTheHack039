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
resource "azurerm_mssql_database" "hack" {
  name           = "mydb"
  server_id      = azurerm_mssql_server.hack.id
  max_size_gb    = 1
  sku_name       = "Basic"
  zone_redundant = false
}

// Open database to VNets
resource "azurerm_mssql_firewall_rule" "public" {
  name             = "public"
  server_id        = azurerm_mssql_server.hack.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}