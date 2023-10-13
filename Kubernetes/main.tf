resource "kubernetes_namespace" "hack" {
  metadata {
    name = "hack"
  }
}

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
          image = "${var.hack_common_name}.azurecr.io/hack/sqlapi:1.0"
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
            value = var.mssql_server_administrator_login_password
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

    type = "LoadBalancer"

    port {
      port        = 8080
      target_port = 8080
    }
  }
}