data "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = var.hack_common_name
  name                = var.hack_common_name
}

data "azurerm_mssql_server" "hack" {
  resource_group_name = var.hack_common_name
  name                = var.hack_common_name
}