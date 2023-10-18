#!/usr/bin/env bash

hack_id=$1

digits=20000  # Test with a couple of digits first (like 10), and then with more (like 20,000) to produce real CPU load
# Determine endpoint IP depending of whether the cluster has outboundtype=uDR or not
if [[ -n $hack_id ]]; then
  aks_outbound=$(az aks show -n $hack_id -g $hack_id --query networkProfile.outboundType -o tsv)
else
  aks_outbound="undefined"
fi

if [[ "$aks_outbound" == "userDefinedRouting" ]]; then
  endpoint_ip=$azfw_ip
  echo "Using Azure Firewall's IP $azfw_ip as endpoint..."
else
  nginx_svc_name=$(kubectl get svc -n ingress-nginx -o json | jq -r '.items[] | select(.spec.type == "LoadBalancer") | .metadata.name')
  nginx_svc_ip=$(kubectl get svc/$nginx_svc_name -n ingress-nginx -o json | jq -rc '.status.loadBalancer.ingress[0].ip' 2>/dev/null)
  endpoint_ip=$nginx_svc_ip
  echo "Using Ingress Controller's IP $nginx_svc_ip as endpoint..."
fi
# Tests
echo "Testing if API is reachable (no stress test yet)..."
curl -k "http://hack.${endpoint_ip}.traefik.me/api/healthcheck"
curl -k "http://hack.${endpoint_ip}.traefik.me/api/pi?digits=5"
function test_load {
  if [[ -z "$1" ]]
  then
    times=10
  else
    times=$1
  fi
  echo "Launching stress test: Calculating $digits digits of pi $times times..."
  for ((i=1; i <= $times; i++))
  do
    curl -s -k "https://hack.${endpoint_ip}.traefik.me" >/dev/null 2>&1
    curl -s -k "https://hack.${endpoint_ip}.traefik.me/api/pi?digits=${digits}" >/dev/null 2>&1 &
    echo -n "."
    sleep 1
  done
  echo ""
  echo "Completed stress test."
}
test_load 50