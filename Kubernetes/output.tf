output "ingress_public_ip" {
  value = data.kubernetes_service.ingress-nginx-controller.status[0].load_balancer[0].ingress[0].ip
}
