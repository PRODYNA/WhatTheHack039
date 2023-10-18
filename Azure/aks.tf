// Create Kubernetes cluster (AKS)
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
  // Not using this one, since we are deploying the ingress-nginx ourselves
  http_application_routing_enabled     = false
  azure_policy_enabled                 = true
  enable_host_encryption               = false
  /* Challenge 03 - START - Enable Auto Scaling */
  # Must be removed before challenge 03 to implicitly disable the feature. Will then be enabled in challenge 03.
  enable_auto_scaling                  = true
  # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes. Must be set to a number if `enable_auto_scaling` is `false`.
  agents_count                         = null
  agents_min_count                     = 1
  agents_max_count                     = 2
  /* Challenge 03 - END - Enable Auto Scaling */
  agents_max_pods                      = 100
  agents_pool_name                     = "exnodepool"
  agents_availability_zones            = []
  agents_type                          = "VirtualMachineScaleSets"
  agents_size                          = "standard_d4ds_v4"
  /* Challenge 03 - START - Enable Log Analytics features (workspace and solution) */
  # Must be `false` before challenge 03 to explicitly disable the feature. Will then be enabled in challenge 03.
  log_analytics_workspace_enabled      = true
  cluster_log_analytics_workspace_name = "${local.common-name}-aks"
  /* Challenge 03 - END - Enable Log Analytics features (workspace and solution) */
  attached_acr_id_map                  = {
    "hack_acr" : azurerm_container_registry.hack.id
  }

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  /* Challenge 05 - START - Add second node pool */
  node_pools = {
    alpha = {
      name                = "alpha"
      vm_size             = "standard_d2ds_v4"
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 3
      vnet_subnet_id      = module.network.vnet_subnets[2]
      node_labels         = {
        "nodepool" = "alpha"
      }
    }
  }
  /* Challenge 03 - END - Enable Azure Policy add-on profile */

  ingress_application_gateway_enabled          = false
  ingress_application_gateway_name             = "${local.common-name}-agw"
  ingress_application_gateway_subnet_id        = module.network.vnet_subnets[1]
  network_contributor_role_assigned_subnet_ids = {
    aks-agw-snet = module.network.vnet_subnets[1]
  }

  key_vault_secrets_provider_enabled = true
  oidc_issuer_enabled                = true

  network_policy             = "azure"
  net_profile_dns_service_ip = "10.0.0.10"
  net_profile_service_cidr   = "10.0.0.0/16"

  /* Challenge 03 - START - Enable Prometheus add-on profile */
  monitor_metrics = {
  }
  /* Challenge 03 - END - Enable Prometheus add-on profile */

  /* Challenge 07 - START - Enable Open Service Mesh add-on profile */
  open_service_mesh_enabled = true
  /* Challenge 07 - END - Enable Open Service Mesh add-on profile */

  depends_on = [module.network]
}

// wait 2 minutes for the cluster to be ready
resource "time_sleep" "wait_2_minutes" {
  depends_on = [
    module.aks
  ]
  create_duration = "2m"
}

// Load the credentials into the local kubeconfig
resource "null_resource" "get-credentials" {
  provisioner "local-exec" {
    command = "az aks get-credentials -g ${azurerm_resource_group.hack.name} -n ${local.common-name} --overwrite-existing"
  }
  depends_on = [
    time_sleep.wait_2_minutes
  ]
}

// Create a managed identity
resource "azurerm_user_assigned_identity" "hack" {
  resource_group_name = azurerm_resource_group.hack.name
  location            = azurerm_resource_group.hack.location
  name                = "${local.common-name}-mi"
}

// Assign role Key Vault Secrets User to the managed identity
resource "azurerm_role_assignment" "aks-keyvault" {
  scope                = azurerm_key_vault.hack.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.hack.principal_id
}

// Create a credential for the managed identity
resource "azurerm_federated_identity_credential" "hack-credential" {
  name                = "${local.common-name}-credential"
  resource_group_name = azurerm_resource_group.hack.name
  audience            = ["api://AzureADTokenExchange"] // should be this value, documented here https://learn.microsoft.com/en-us/graph/api/application-post-federatedidentitycredentials?view=graph-rest-1.0&tabs=http
  issuer              = module.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.hack.id
  subject             = "system:serviceaccount:hack:aks-keyvault"
  // must match the namespace and the name of the service account
}
