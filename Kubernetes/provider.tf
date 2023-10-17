terraform {
  required_providers {
    // needed for generic azure things
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.75"
    }

    // needed for kubernetes things
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4"
    }

    // needed for helm things
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }

    // needed for special metadata which cannot be handled by the kubernetes provider
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.0.3"
    }

    // For executing local scripts
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

  }

  // sticking to the last "nice" version
  required_version = "= 1.5.5"
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}
