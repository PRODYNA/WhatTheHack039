// TODO: Create a configmap named "api" in the namespace hack with the following data:
// SQL_SERVER_FQDN     = data.azurerm_mssql_server.hack.fully_qualified_domain_name
// SQL_SERVER_USERNAME = data.azurerm_mssql_server.hack.administrator_login
// SQL_ENGINE          = "sqlserver"

// TODO: reate a secret "api" with the following data:
// SQL_SERVER_PASSWORD = data.terraform_remote_state.azure.outputs.sql_server_password

// TODO: Create a deployment named "api" in the namespace hack with the following data:
// image = "${data.terraform_remote_state.azure.outputs.hack_common_name}.azurecr.io/hack/sqlapi:1.0"
// container port is 8080
// service_account_name = "default"
// Mount the environment from the configmap "api"
// Mount the environment from the secret "api"
// Tip: See a similar deployment in hack_web.tf

// TODO: Create a service named "api" in the namespace hack with the following data:
// target_port = 8080

// TODO: Create an ingress named "api" in the namespace hack with the following data:
// host = local.public_hostname
// path = "/api"
// ingress_class_name = "nginx"
