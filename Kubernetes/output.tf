output "ingress_public_ip" {
  value = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].ip
}

output "web_public_ip" {
  value = kubernetes_service.api.status[0].load_balancer[0].ingress[0].ip
}

output "web_public_url" {
  value = "http://${kubernetes_service.web.status[0].load_balancer[0].ingress[0].ip}"
}

output "api_public_url_healthcheck" {
  value = "http://${kubernetes_service.api.status[0].load_balancer[0].ingress[0].ip}:8080/healthcheck"
}
