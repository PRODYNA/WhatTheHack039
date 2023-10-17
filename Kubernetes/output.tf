// Output the public IP of the ingress controller
output "ingress_public_ip" {
  value = local.ingress_ip
}

// Output of the public IP for the load balancer pointing directlry to Web
/*
output "web_public_ip" {
  value = kubernetes_service.api.status[0].load_balancer[0].ingress[0].ip
}
*/

// Output of the URL for accessing the Web app directly via load balancer
/*
output "web_public_url" {
  value = "http://${kubernetes_service.web.status[0].load_balancer[0].ingress[0].ip}"
}
*/

// Output of the health check status
/*
output "api_public_url_healthcheck" {
  value = "http://${kubernetes_service.api.status[0].load_balancer[0].ingress[0].ip}:8080/api/healthcheck"
}
*/

// The URL for accessing the Web app via the ingress controller
output "ingress_web_url" {
  value = "http://${local.public_hostname}"
}

// The URL for accessing the API via the ingress controller
output "ingress_api_healthcheck_url" {
  value = "http://${local.public_hostname}/api/healthcheck"
}
