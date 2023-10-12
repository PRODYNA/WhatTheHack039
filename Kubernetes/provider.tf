terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4"
    }
  }

  required_version = "= 1.5.5"
}

provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = var.hack_common_name
  name                = var.hack_common_name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

