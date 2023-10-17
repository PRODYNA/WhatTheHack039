locals {
  public_hostname = "hack.${local.ingress_ip}.traefik.me"
}

// Create namespace hack
resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}

// Create service account for accessing the keyvault
// TODO: Understand that we are adding a new service principal, see HINT below
resource "kubernetes_manifest" "aks-keyvault" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata   = {
      // HINT: This a a new service principal that is allowd to access the keyvault. The name is used in the  federated identity credential, see Azure/aks.tf for that
      name        = "aks-keyvault"
      namespace   = kubernetes_namespace.hack.metadata[0].name
      annotations = {
        "azure.workload.identity/client-id" = data.terraform_remote_state.azure.outputs.keyvault_client_id
      }
    }
  }
}

// Create role binding for the service account
// Note: We need to use the kubectl_manifest resource due to the complex | syntax which kubernetes_manifest does not handle
// TODO: Be aware that we are a secretProviderClass, see the HINTs below
resource "kubectl_manifest" "secretproviderclass" {
  yaml_body = <<YAML
apiVersion: secrets-store.csi.x-k8s.io/v1
# HINT: Be aware of this new CRD
kind: SecretProviderClass
metadata:
  name: ${data.terraform_remote_state.azure.outputs.hack_common_name}
  namespace: ${kubernetes_namespace.hack.metadata[0].name}
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: ${data.terraform_remote_state.azure.outputs.keyvault_client_id}
    keyvaultName: ${data.terraform_remote_state.azure.outputs.hack_common_name}
    cloudName: ""
    objects: |
      array:
        - |
          objectName: ${data.terraform_remote_state.azure.outputs.sql_server_password_name}
          objectType: secret
          objectVersion: ""
          objectAlias: SQL_SERVER_PASSWORD
          # HINT: We are mapping the keyvault secret to the environment variable SQL_SERVER_PASSWORD
    tenantId: ${data.terraform_remote_state.azure.outputs.tenant_id}
YAML
}
