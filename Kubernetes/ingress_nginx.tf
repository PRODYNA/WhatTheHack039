// Create namespace for ingress-nginx
resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

// TODO: Deploy the ingress-nginx helm chart version 4.7.0 into the ingress-nginx namespace
// TODO: Use the helm/ingress-nginx.yaml file for the values
// TODO: Wait for the ingress-nginx-controller service to be ready
// TODO: Use the repository https://kubernetes.github.io/ingress-nginx
// TODO: Use the chart name ingress-nginx

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
