locals {
  clusterissuer_name = "letsencrypt-prod"
}

// Create a namespace for cert-manager
resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "name" = "cert-manager"
    }
  }
}

// Install the Cert Manager using the Helm chart
// TODO: Enable this to install the cert-manager using helm
#resource "helm_release" "cert-manager" {
#  chart      = "cert-manager"
#  repository = "https://charts.jetstack.io"
#  name       = "cert-manager"
#  namespace  = kubernetes_namespace.cert-manager.id
#  version    = "v1.13.1"
#  wait       = true
#
#  values = [
#    file("helm/cert-manager.yaml")
#  ]
#}

// Create a clusterissuer for the cert-manager
// TODO: Enable this for configuring the clusterissuer
#resource "kubectl_manifest" "clusterissuer" {
#  yaml_body = <<YAML
#apiVersion: cert-manager.io/v1
#kind: ClusterIssuer
#metadata:
#  name: letsencrypt-prod
#spec:
#  acme:
#    email: ${var.email_address}
#    preferredChain: ""
#    privateKeySecretRef:
#      name: ${local.clusterissuer_name}
#    server: https://acme-v02.api.letsencrypt.org/directory
#    solvers:
#    - http01:
#        ingress:
#          ingressClassName: nginx
#YAML
#  depends_on = [
#    helm_release.cert-manager
#  ]
#}
