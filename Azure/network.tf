// Create the Vnet with the subnets
module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.hack.name
  vnet_name           = local.common-name
  address_space       = "10.52.0.0/16"
  subnet_prefixes     = ["10.52.0.0/24", "10.52.1.0/24"]
  subnet_names        = ["aks", "aks-agw"]
  depends_on          = [azurerm_resource_group.hack]
  subnet_enforce_private_link_endpoint_network_policies = {
    "aks" : true
    "aks-agw" : false
  }
  use_for_each = false
}
