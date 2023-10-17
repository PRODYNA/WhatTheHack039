# Container group for API and web
resource "azurerm_container_group" "hack_sqlapi" {
  name                = "sqlapi"
  resource_group_name = azurerm_resource_group.hack.name
  location            = azurerm_resource_group.hack.location
  os_type             = "Linux"
  ip_address_type     = "Public"

  image_registry_credential {
    server   = azurerm_container_registry.hack.login_server
    username = azurerm_container_registry.hack.admin_username
    password = azurerm_container_registry.hack.admin_password
  }

  container {
    name   = "sqlapi"
    image  = "${azurerm_container_registry.hack.login_server}/hack/sqlapi:1.0"
    cpu    = 0.25
    memory = 0.5

    ports {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {
      SQL_SERVER_USERNAME = azurerm_mssql_server.hack.administrator_login
      SQL_SERVER_PASSWORD = azurerm_mssql_server.hack.administrator_login_password
      SQL_SERVER_FQDN     = azurerm_mssql_server.hack.fully_qualified_domain_name
    }
  }

  exposed_port {
    port = 8080
  }

  depends_on = [time_sleep.wait_for_images]
}

resource "null_resource" "curl_command" {
  depends_on = [azurerm_container_group.hack_sqlapi]

  provisioner "local-exec" {
    command = "curl -s -X GET http://${azurerm_container_group.hack_sqlapi.ip_address}:8080/api/ip"
  }
}

data "external" "curl_output" {
  depends_on = [null_resource.curl_command]
  program    = ["sh", "-c", "curl -s -X GET http://${azurerm_container_group.hack_sqlapi.ip_address}:8080/api/ip"]
}

output "json_data" {
  value = data.external.curl_output.result
}

resource "azurerm_mssql_firewall_rule" "hack" {
  name             = "sqlapi"
  server_id        = azurerm_mssql_server.hack.id
  start_ip_address = data.external.curl_output.result.my_public_ip
  end_ip_address   = data.external.curl_output.result.my_public_ip
}

resource "azurerm_container_group" "hack_web" {
  name                = "web"
  resource_group_name = azurerm_resource_group.hack.name
  location            = azurerm_resource_group.hack.location
  os_type             = "Linux"
  ip_address_type     = "Public"

  image_registry_credential {
    server   = azurerm_container_registry.hack.login_server
    username = azurerm_container_registry.hack.admin_username
    password = azurerm_container_registry.hack.admin_password
  }

  container {
    name   = "web"
    image  = "${azurerm_container_registry.hack.login_server}/hack/web:1.0"
    cpu    = 0.25
    memory = 0.5

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      API_URL = "http://${azurerm_container_group.hack_sqlapi.ip_address}:8080"
    }
  }

  exposed_port {
    port = 80
  }

  depends_on = [time_sleep.wait_for_images]
}