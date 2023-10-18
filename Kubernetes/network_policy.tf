// Challenge-05 - START - Add a kubernetes network policies to limit resource access

// Create a policy to allow access to web only the ingress-nginx namespace
resource "kubernetes_network_policy_v1" "allow_web" {
  metadata {
    name      = "allow-web"
    namespace = kubernetes_namespace.hack.metadata.0.name
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {
        run = "web"
      }
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.ingress-nginx.metadata.0.name
          }
        }
      }
    }
  }
}

// Create a policy to allow access to api only from web and the ingress-nginx namespace
resource "kubernetes_network_policy_v1" "allow_api" {
  metadata {
    name      = "allow-api"
    namespace = kubernetes_namespace.hack.metadata.0.name
  }
  spec {
    policy_types = ["Ingress"]
    pod_selector {
      match_labels = {
        run = "api"
      }
    }
    ingress {
      from {
        pod_selector {
          match_labels = {
            run = "web"
          }
        }
      }
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = kubernetes_namespace.ingress-nginx.metadata.0.name
          }
        }
      }
    }
  }
}
// Challenge-05 - END - Add a kubernetes network policies to limit resource access