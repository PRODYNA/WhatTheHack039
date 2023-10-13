/*
resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  chart = "ingress-nginx"
  name  = "ingress-nginx"
  namespace = kubernetes_namespace.ingress-nginx.metadata[0].name
  repository = "https://kubernetes.github.io/ingress-nginx"
  version          = "4.7.0"
  create_namespace = false

  values = [
    file("helm/ingress-nginx.yaml")
  ]
}
*/