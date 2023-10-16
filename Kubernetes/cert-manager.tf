#// Create a namespace for cert-manager
#resource "kubernetes_namespace" "cert-manager" {
#  metadata {
#    name = "cert-manager"
#    labels = {
#      "name" = "cert-manager"
#    }
#  }
#}
#
#// Install the Cert Manager using the Helm chart
#resource "helm_release" "cert-manager" {
#  chart      = "cert-manager"
#  repository = "https://charts.jetstack.io"
#  name       = "cert-manager"
#  namespace  = kubernetes_namespace.cert-manager.id
#  version    = "v1.11.1"
#  wait       = true
#
#  values = [
#    file("helm/cert-manager.yaml")
#  ]
#}
