// The common name of all the resources
output "hack_common_name" {
  value = azurerm_resource_group.hack.name
}

// The login password for the database
output "mssql_server_administrator_login_password" {
  value     = azurerm_mssql_server.hack.administrator_login_password
  sensitive = true
}

// The AKS OIDC issuer URL
output "aks_oidc_isser_url" {
  value = module.aks.oidc_issuer_url
}

// The keyvault client id
output "keyvault_client_id" {
  value = azurerm_user_assigned_identity.hack.client_id
}
