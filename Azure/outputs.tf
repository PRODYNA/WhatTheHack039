// The common name of all the resources
output "hack_common_name" {
  value = azurerm_resource_group.hack.name
}

// The login password for the database
output "sql_server_password" {
  value     = // TODO: Write down the randomply generated database password to the output
  sensitive = true
}
