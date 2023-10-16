#// Create namespace for the CSI driver
#resource "kubernetes_namespace" "csi-secrets-store-provider-azure" {
#  metadata {
#    name = "csi-secrets-store-provider-azure"
#  }
#}
#
#// Install the Azure Key Vault CSI driver using Helm
#resource "helm_release" "keyvault-csi-driver" {
#  name = "keyvault-csi-driver"
#  repository = "https://azure.github.io/secrets-store-csi-driver-provider-azure/charts"
#  chart = "csi-secrets-store-provider-azure"
#  namespace = kubernetes_namespace.csi-secrets-store-provider-azure.metadata[0].name
#}
