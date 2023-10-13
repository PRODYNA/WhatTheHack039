output "hack_common_name" {
    value = azurerm_resource_group.hack.name
}

output "mssql_server_administrator_login_password" {
  value = azurerm_mssql_server.hack.administrator_login_password
  sensitive = true
}
