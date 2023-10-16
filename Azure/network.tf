// Create the Vnet with the subnets
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

#// Permissions for the AKS service principal to access the Vnet
#resource "azurerm_role_assignment" "application_gateway_subnet_network_contributor_vnet" {
#  principal_id         = module.aks.ingress_application_gateway.ingress_application_gateway_identity[0].object_id
#  scope                = module.network.vnet_id
#  role_definition_name = "Network Contributor"
#}
#
#// Permissions for the AKS service principal to access the subnet
#resource "azurerm_role_assignment" "application_gateway_subnet_network_contributor_subnet" {
#  principal_id         = module.aks.ingress_application_gateway.ingress_application_gateway_identity[0].object_id
#  scope                = module.network.vnet_subnets[1]
#  role_definition_name = "Network Contributor"
#}
