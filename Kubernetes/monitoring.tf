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

// TODO: Deploy the kube-prometheus-stack helm chart into the hack-monitoring namespace with the following values:
// namespace = hack-monitoring
// version as defiined in the helm_chart_version_kube-prometheus variable
// repository = https://prometheus-community.github.io/helm-charts
