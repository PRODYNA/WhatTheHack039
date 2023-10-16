// Create namespace hack
resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}

// Create service account for accessing the keyvault
resource "kubernetes_manifest" "aks-keyvault" {
  manifest = {
    apiVersion = "v1"
    kind = "ServiceAccount"
    metadata = {
      name = "aks-keyvault"
      namespace = kubernetes_namespace.hack.metadata[0].name
      annotations = {
        "azure.workload.identity/client-id" = data.terraform_remote_state.azure.outputs.keyvault_client_id
      }
    }
  }
}
