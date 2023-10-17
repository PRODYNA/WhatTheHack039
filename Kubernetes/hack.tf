locals {
  public_hostname = "hack.${local.ingress_ip}.traefik.me"
}

// TODO: Create namespace "hack"
