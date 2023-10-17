// Read out my current tenant id
data "azurerm_client_config" "current" {}

// TODO: Create a keyvault with
// - name: local.common-name
// - location: var.default_location
// - resource_group_name: azurerm_resource_group.hack.name
// - sku_name: "standard"
// - tenant_id: The local tenant id
// - purge_protection_enabled: false
// - enable_rbac_authorization: true

// TODO: Assign the role Key Vault Secrets Officer our service principal

// TODO: Write the database password to the keyvault
// - name: local.sql-password-secret-name
