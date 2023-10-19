locals {
  public_hostname = "hack.${local.ingress_ip}.traefik.me"
}

// Create namespace hack
resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"

    // TODO: Uncomment the following lines after service mesh was configured following the steps in the ../Challenge_Resources/Challenge_07/README.md
    #    annotations = {
    #      "openservicemesh.io/sidecar-injection" : "enabled"
    #    }
    #    labels = {
    #      "openservicemesh.io/monitored-by" : "osm"
    #    }
  }
}

// Create service account for accessing the keyvault
resource "kubernetes_manifest" "aks-keyvault" {
  manifest = {
    apiVersion = "v1"
    kind       = "ServiceAccount"
    metadata   = {
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
resource "kubectl_manifest" "secretproviderclass" {
  yaml_body = <<YAML
apiVersion: secrets-store.csi.x-k8s.io/v1
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
    tenantId: ${data.terraform_remote_state.azure.outputs.tenant_id}
YAML
}

