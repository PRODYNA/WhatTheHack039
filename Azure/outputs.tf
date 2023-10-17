// The common name of all the resources
output "hack_common_name" {
  value = azurerm_resource_group.hack.name
}

// The login password for the database
output "sql_server_password" {
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

// The keyvault client secret for the SQL database password
output "sql_server_password_name" {
  value = local.sql-password-secret-name
}

// The tenant ID
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
