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

resource "kubernetes_manifest" "secretproviderclass" {
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind = "SecretProviderClass"
    metadata = {
      name = data.terraform_remote_state.azure.outputs.hack_common_name
      namespace = kubernetes_namespace.hack.metadata[0].name
    }
    spec = {
      provider = "azure"
      parameters = {
        usePodIdentity = "false"
        clientID = data.terraform_remote_state.azure.outputs.keyvault_client_id
        keyvaultName = data.terraform_remote_state.azure.outputs.hack_common_name
        cloudName = ""
        objects = jsonencode(
          [
            {
              objectName = data.terraform_remote_state.azure.outputs.sql_server_password_name
              objectType = "secret"
              objectVersion = ""
            }
          ]
        )
      }
    }

    /*
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-wi # needs to be unique per namespace
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    clientID: "${USER_ASSIGNED_CLIENT_ID}" # Setting this to use workload identity
    keyvaultName: ${KEYVAULT_NAME}       # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: secret1
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: key1
          objectType: key
          objectVersion: ""
    tenantId: "${IDENTITY_TENANT}"        # The tenant ID of the key vault
    */
  }
}