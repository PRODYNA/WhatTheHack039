// Create the Vnet with the subnets
module "network" {
  source              = "Azure/network/azurerm"
  vnet_name           = local.common-name
  // TODO: Create network in the same resource group. Use address space 10.52.0.0./16 and create two subnets
  // 1. aks - 10.52.0.0/24
  // 2. aks-agw - 10.52.1.0./24
  // Enforce private link endpoint network policies for aks subnet
}
