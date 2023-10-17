// Deployment for the Web App
resource "kubernetes_deployment" "hack_web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.hack.metadata.0.name
    labels = {
      run = "web"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        run = "web"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          run = "web"
        }
      }

      spec {
        container {
          image = "${data.terraform_remote_state.azure.outputs.hack_common_name}.azurecr.io/hack/web:1.0"
          name  = "web"
          port {
            container_port = 80
          }

          env {
            name  = "API_URL"
            value = "http://api.hack.svc.cluster.local:8080"
          }
        }

        restart_policy = "Always"
      }
    }
  }
  wait_for_rollout = true
}

// Service for the Web App
resource "kubernetes_service" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.hack.metadata.0.name
  }

  spec {
    selector = {
      run = kubernetes_deployment.hack_web.spec.0.template.0.metadata.0.labels.run
    }

    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
    }
  }

  wait_for_load_balancer = true
}

// Ingress for the Web App
resource "kubernetes_ingress_v1" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.hack.metadata.0.name
  }
  spec {
    rule {
      host = local.public_hostname
      http {
        path {
          backend {
            service {
              name = kubernetes_service.web.metadata.0.name
              port {
                number = 80
              }
            }
          }

          path = "/"
        }
      }
    }
    ingress_class_name = "nginx"
  }

  depends_on = [
    helm_release.ingress-nginx
  ]

}
