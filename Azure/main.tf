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
  vnet_name                                             = local.common-name
  address_space                                         = "10.52.0.0/16"
  subnet_prefixes                                       = ["10.52.0.0/24", "10.52.1.0/24"]
  subnet_names                                          = ["aks", "aks-agw"]
  depends_on                                            = [azurerm_resource_group.hack]
  subnet_enforce_private_link_endpoint_network_policies = {
    "aks" : true
    "aks-agw" : false
  }
  use_for_each = false
}

module "aks" {
  source                               = "Azure/aks/azurerm"
  resource_group_name                  = azurerm_resource_group.hack.name
  location                             = azurerm_resource_group.hack.location
  node_resource_group                  = "${azurerm_resource_group.hack.name}-aks-resources"
  client_id                            = ""
  client_secret                        = ""
  kubernetes_version                   = "1.27"
  orchestrator_version                 = "1.27"
  automatic_channel_upgrade            = "patch"
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
  agents_availability_zones            = []
  agents_type                          = "VirtualMachineScaleSets"
  agents_size                          = "standard_d4ds_v4"
  cluster_log_analytics_workspace_name = "${local.common-name}-aks"
  attached_acr_id_map                  = {
    "hack_acr" : azurerm_container_registry.hack.id
  }

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  ingress_application_gateway_enabled          = true
  ingress_application_gateway_name             = "${local.common-name}-agw"
  ingress_application_gateway_subnet_id        = module.network.vnet_subnets[1]
  network_contributor_role_assigned_subnet_ids = {
    aks-agw-snet = module.network.vnet_subnets[1]
  }

  network_policy             = "azure"
  net_profile_dns_service_ip = "10.0.0.10"
  net_profile_service_cidr   = "10.0.0.0/16"

  depends_on = [module.network]
}

resource "azurerm_role_assignment" "application_gateway_subnet_network_contributor_vnet" {
  principal_id         = module.aks.ingress_application_gateway.ingress_application_gateway_identity[0].object_id
  scope                = module.network.vnet_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "application_gateway_subnet_network_contributor_subnet" {
  principal_id         = module.aks.ingress_application_gateway.ingress_application_gateway_identity[0].object_id
  scope                = module.network.vnet_subnets[1]
  role_definition_name = "Network Contributor"
}