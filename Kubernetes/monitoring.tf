variable "helm_chart_version_kube-prometheus" {
  description = "The version of the helm chart to use"
  type        = string
  default     = "51.8.0"
}

resource "kubernetes_namespace" "hack_monitoring" {
  metadata {
    name = "hack-monitoring"
  }
}

resource "helm_release" "kube-prometheus" {
  namespace  = resource.kubernetes_namespace.hack_monitoring.metadata.0.name
  name       = "kube-prometheus-stack"
  version    = var.helm_chart_version_kube-prometheus
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}