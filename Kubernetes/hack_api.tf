// Create a configmap for the APi with non-sensitive information
resource "kubernetes_config_map" "hack_api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.hack.metadata.0.name
    labels    = {
      run = "api"
    }
  }
  data = {
    SQL_SERVER_FQDN     = data.azurerm_mssql_server.hack.fully_qualified_domain_name
    SQL_SERVER_USERNAME = data.azurerm_mssql_server.hack.administrator_login
    SQL_ENGINE          = "sqlserver"
    USE_SSL             = "no"
  }
}

// Create a secret for the API with sensitive information
/*
resource "kubernetes_secret" "hack_api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.hack.metadata[0].name
    labels = {
      run = "api"
    }
  }
  data = {
    SQL_SERVER_PASSWORD = data.terraform_remote_state.azure.outputs.sql_server_password
  }
}
*/

// Deployment of the API
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
    // Challenge 03 - START - Disable fixed number of replicas
    replicas = null
    // Challenge 03 - END - Disable fixed number of replicas

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
        service_account_name = "aks-keyvault"

        container {
          image = "${data.terraform_remote_state.azure.outputs.hack_common_name}.azurecr.io/hack/sqlapi:1.0"
          name  = "api"
          port {
            container_port = 8080
          }

          // use environment from the configmap
          env_from {
            config_map_ref {
              name = kubernetes_config_map.hack_api.metadata.0.name
            }
          }

          // use environment from the secret
          /*
          env_from {
            secret_ref {
              name = kubernetes_secret.hack_api.metadata.0.name
            }
          }
          */

          // Mount the secret as a volume, the directory contains a file with the name SQL_SERVER_PASSWORD
          volume_mount {
            mount_path = "/secrets"
            name       = "secrets-inline"
            read_only  = true
          }

          // Override the command to use the secret
          command = [
            "sh", "-c", "SQL_SERVER_PASSWORD=$(cat /secrets/SQL_SERVER_PASSWORD) python3 sql_api.py"
          ]

          // Challenge 03 - START - Define resource limits for the API
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "0.25"
              memory = "256Mi"
            }
          }
          // Challenge 03 - END - Define resource limits for the API
        }

        // Define the volume that connects to the keyVault
        volume {
          name = "secrets-inline"
          csi {
            driver            = "secrets-store.csi.k8s.io"
            read_only         = true
            volume_attributes = {
              secretProviderClass = data.terraform_remote_state.azure.outputs.hack_common_name
            }
          }
        }

        restart_policy = "Always"
      }
    }
  }

  wait_for_rollout = true
  depends_on       = [
    kubectl_manifest.secretproviderclass
  ]
}

// Service for the API
resource "kubernetes_service" "api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.hack.metadata.0.name
  }

  spec {
    selector = {
      run = kubernetes_deployment.hack_api.spec.0.template.0.metadata.0.labels.run
    }

    // LoadBalancer or ClusterIP, use ClusterIP for allow access only via Ingress Controller
    type = "ClusterIP"

    port {
      port        = 8080
      target_port = 8080
    }
  }

  wait_for_load_balancer = true
}

// Ingress for the Web App
resource "kubernetes_ingress_v1" "api" {
  metadata {
    name        = "api"
    namespace   = kubernetes_namespace.hack.metadata.0.name
  }
  spec {
    rule {
      host = local.public_hostname
      http {
        path {
          backend {
            service {
              name = kubernetes_service.api.metadata.0.name
              port {
                number = 8080
              }
            }
          }
          path = "/api"
        }
      }
    }
    ingress_class_name = "nginx"
  }

  depends_on = [
    helm_release.ingress-nginx
  ]
}

// Challenge 03 - START - Add horizontal pod autoscaler for the API
// Horizontal pod autoscaler (HPA) for the API
resource "kubernetes_horizontal_pod_autoscaler_v2" "hack_api" {
  metadata {
    name      = "api"
    namespace = kubernetes_namespace.hack.metadata.0.name
  }
  spec {
    max_replicas = 10
    min_replicas = 1
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 50
        }
      }
    }
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = "api"
    }
  }
}
// Challenge 03 - END - Add horizontal pod autoscaler for the API
