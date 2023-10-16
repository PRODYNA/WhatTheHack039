# ACR and images
resource "azurerm_container_registry" "hack" {
  name                = local.common-name
  resource_group_name = azurerm_resource_group.hack.name
  location            = azurerm_resource_group.hack.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "null_resource" "build_api" {
  provisioner "local-exec" {
    command = "az acr build -r ${azurerm_container_registry.hack.name} -t hack/sqlapi:1.0 ./Resources/api"
  }
}

resource "null_resource" "build_web" {
  provisioner "local-exec" {
    command = "az acr build -r ${azurerm_container_registry.hack.name} -t hack/web:1.0 ./Resources/web"
  }
}
