resource "random_integer" "random" {
  min = 1000
  max = 9999
}

locals {
  common-name = "hack${random_integer.random.result}"
}

# Resource group for all hack related resources
resource "azurerm_resource_group" "hack" {
  name     = local.common-name
  location = var.default_location
}

# ACR and images
resource "azurerm_container_registry" "hack" {
  name                = local.common-name
  resource_group_name = azurerm_resource_group.hack.name
  location            = var.default_location
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

# SQL Server and database
resource "azurerm_mssql_server" "hack" {
  name                         = local.common-name
  resource_group_name          = azurerm_resource_group.hack.name
  location                     = azurerm_resource_group.hack.location
  version                      = "12.0"
  administrator_login          = "azure"
  administrator_login_password = "Microsoft123!"
}

resource "azurerm_mssql_database" "hack" {
  name           = "mydb"
  server_id      = azurerm_mssql_server.hack.id
  max_size_gb    = 1
  sku_name       = "Basic"
  zone_redundant = false
}

module "network" {
  source                                                = "Azure/network/azurerm"
  resource_group_name                                   = azurerm_resource_group.hack.name
  address_space                                         = "10.52.0.0/16"
  subnet_prefixes                                       = ["10.52.0.0/16"]
  subnet_names                                          = ["subnet1"]
  depends_on                                            = [azurerm_resource_group.hack]
  subnet_enforce_private_link_endpoint_network_policies = {
    "subnet1" : true
  }
  use_for_each = false
}

module "aks" {
  source                               = "Azure/aks/azurerm"
  resource_group_name                  = azurerm_resource_group.hack.name
  client_id                            = ""
  client_secret                        = ""
  kubernetes_version                   = "1.26.6"
  orchestrator_version                 = "1.26.6"
  prefix                               = "default"
  cluster_name                         = local.common-name
  network_plugin                       = "azure"
  vnet_subnet_id                       = module.network.vnet_subnets[0]
  os_disk_size_gb                      = 50
  sku_tier                             = "Free" # defaults to Free
  rbac_aad                             = false
  role_based_access_control_enabled    = false
  rbac_aad_admin_group_object_ids      = null
  rbac_aad_managed                     = false
  private_cluster_enabled              = false
  http_application_routing_enabled     = true
  azure_policy_enabled                 = true
  enable_auto_scaling                  = true
  enable_host_encryption               = false
  agents_min_count                     = 1
  agents_max_count                     = 1
  agents_count                         = null
  # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                      = 100
  agents_pool_name                     = "exnodepool"
  agents_availability_zones            = ["1", "2"]
  agents_type                          = "VirtualMachineScaleSets"
  agents_size                          = "standard_dc2s_v2"
  cluster_log_analytics_workspace_name = "${local.common-name}-aks"

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  ingress_application_gateway_enabled     = true
  ingress_application_gateway_name        = "${local.common-name}-aks"
  ingress_application_gateway_subnet_cidr = "10.52.1.0/24"

  network_policy             = "azure"
  net_profile_dns_service_ip = "10.0.0.10"
  net_profile_service_cidr   = "10.0.0.0/16"

  depends_on = [module.network]
}