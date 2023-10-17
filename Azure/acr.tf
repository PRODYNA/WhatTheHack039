// Create azure container registry
resource "azurerm_container_registry" "hack" {
  name                = local.common-name
  resource_group_name = azurerm_resource_group.hack.name
  location            = azurerm_resource_group.hack.location
  sku                 = "Basic"
  admin_enabled       = true
}

// Create the container hack/sqlapi:1.0 directly in the ACR
resource "null_resource" "build_api" {
  provisioner "local-exec" {
    command = "az acr build -r ${azurerm_container_registry.hack.name} -t hack/sqlapi:1.0 ./Resources/api"
  }
}

// Create the container hack/web:10 directly in the ACR
resource "null_resource" "build_web" {
  provisioner "local-exec" {
    command = "az acr build -r ${azurerm_container_registry.hack.name} -t hack/web:1.0 ./Resources/web"
  }
}

resource "time_sleep" "wait_for_images" {
  depends_on      = [null_resource.build_api, null_resource.build_web]
  create_duration = "30s"
}