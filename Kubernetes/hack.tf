locals {
  public_hostname = "hack.${local.ingress_ip}.traefik.me"
}

// Create namespace hack
resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}


