data "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = data.terraform_remote_state.azure.outputs.hack_common_name
  name                = data.terraform_remote_state.azure.outputs.hack_common_name
}

data "azurerm_mssql_server" "hack" {
  resource_group_name = data.terraform_remote_state.azure.outputs.hack_common_name
  name                = data.terraform_remote_state.azure.outputs.hack_common_name
}
