resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}