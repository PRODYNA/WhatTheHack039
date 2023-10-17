// Create namespace for ingress-nginx
resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"

    annotations = {
      "openservicemesh.io/sidecar-injection" : "disabled"
    }
    labels = {
      "openservicemesh.io/monitored-by" : "osm"
    }
  }
}

// Deploy ingress-nginx via Helm
resource "helm_release" "ingress-nginx" {
  chart            = "ingress-nginx"
  name             = "ingress-nginx"
  namespace        = kubernetes_namespace.ingress-nginx.metadata[0].name
  repository       = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.7.0"
  create_namespace = false

  values = [
    file("helm/ingress-nginx.yaml")
  ]

  wait = true
}

// Read out the ingress-nginx service IP
data "kubernetes_service" "ingress-nginx-controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
  }
  depends_on = [
    helm_release.ingress-nginx
  ]
}

// Create a local variable for the ingress-nginx service IP
locals {
  ingress_ip = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].ip
}
