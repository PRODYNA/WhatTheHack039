// Read out my current tenant id
data "azurerm_client_config" "current" {}

// Create keyvault
resource "azurerm_key_vault" "hack" {
  name                     = local.common-name
  location                 = var.default_location
  resource_group_name      = azurerm_resource_group.hack.name
  sku_name                 = "standard"
  tenant_id                = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled = false
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
  }
  enable_rbac_authorization = true
}

// Assign role Key Vault Secrets Officer to the service principal
resource "azurerm_role_assignment" "hack" {
  scope                = azurerm_key_vault.hack.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

// TODO: write secret into the keyvault
// Write the database password to the keyvault
resource "azurerm_key_vault_secret" "mssql_server_administrator_login_password" {
  name         = "mssql-server-administrator-login-password"
  value        = azurerm_mssql_server.hack.administrator_login_password
  key_vault_id = azurerm_key_vault.hack.id

  depends_on = [
    azurerm_role_assignment.hack
  ]
}
