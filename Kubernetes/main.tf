resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}

# SQL API Deployment and Service
resource "kubernetes_deployment" "hack_api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.hack.metadata.0.name
    labels    = {
      run                   = "api"
      aadpodidentitybinding = "app1-identity"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        run = "api"
      }
    }

    strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          run = "api"
        }
      }

      spec {
        container {
          image = "${data.terraform_remote_state.azure.outputs.hack_common_name}.azurecr.io/hack/sqlapi:1.0"
          name  = "api"
          port {
            container_port = 8080
          }

          env {
            name  = "SQL_SERVER_FQDN"
            value = data.azurerm_mssql_server.hack.fully_qualified_domain_name
          }
          env {
            name  = "SQL_SERVER_USERNAME"
            value = data.azurerm_mssql_server.hack.administrator_login
          }
          env {
            name  = "SQL_SERVER_PASSWORD"
            value = data.terraform_remote_state.azure.outputs.mssql_server_administrator_login_password
          }
          env {
            name  = "SQL_ENGINE"
            value = "sqlserver"
          }
          env {
            name  = "USE_SSL"
            value = "no"
          }
        }

        restart_policy = "Always"
      }
    }
  }

  wait_for_rollout = false
}

resource "kubernetes_service" "api" {
  metadata {
    name        = "api"
    namespace   = kubernetes_namespace.hack.metadata.0.name
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    }
  }

  spec {
    selector = {
      run = kubernetes_deployment.hack_api.spec.0.template.0.metadata.0.labels.run
    }

    type = "ClusterIP"

    port {
      port        = 8080
      target_port = 8080
    }
  }
}

# Web App Deployment and Service

resource "kubernetes_deployment" "hack_web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.hack.metadata.0.name
    labels    = {
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
            value = "http://api.default.svc.cluster.local:8080"
          }
        }

        restart_policy = "Always"
      }
    }
  }
  wait_for_rollout = false
}

resource "kubernetes_service" "web" {
  metadata {
    name        = "web"
    namespace   = kubernetes_namespace.hack.metadata.0.name
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    }
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
}