// Create namespace hack
resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}