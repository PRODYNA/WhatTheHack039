resource "kubernetes_namespace" "persistence" {
  metadata {
    name = "persistence"
  }
}

resource "helm_release" "mysql" {
  name = "hack-mysql"
  repository = "https://marketplace.azurecr.io/helm/v1/repo"
  namespace = kubernetes_namespace.persistence.metadata.0.name
  chart = "mysql"

  values = [
    file("helm/mysql.yaml")
  ]

  set {
    name = "global.storageClass"
    value = local.premium_zrs_storage_class_name
  }

  // We need to wait for the storageclass because we use it
  depends_on = [
    kubectl_manifest.premium-zrs
  ]
}
