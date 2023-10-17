# Challenge 03 - AKS Monitoring

[< Previous Challenge](./Challenge-02.md) - **[Home](../README.md)** - [Next Challenge >](./Challenge-04.md)

## Introduction

This challenge will cover monitoring in AKS, using open source components such as Prometheus and Azure services such as Azure Monitor.

## Description

- Implement Prometheus/Grafana 
- You can access container logs via Azure Monitor
- Increase the CPU utilization of the API container with the `pi` API endpoint, and see the corresponding metric increase in Prometheus and/or Azure Monitor
- Implement a mechanism so that Kubernetes increases the amount of API pods when CPU utilization goes high
- If you didn't do it already, configure a mechanism that scales the cluster automatically in and out depending on the required capacity

## Success Criteria

- You can display cluster metrics graphically
- You can show live container logs with Azure Container Insights
- Verify that the cluster auto-scales when there are not enough CPU resources
- Participants can explain the autoscaling event using AKS metrics

## Learning Resources

These docs might help you achieving these objectives:

- [AKS Overview](https://docs.microsoft.com/azure/aks/)
- [Azure Monitor for Containers](https://docs.microsoft.com/azure/azure-monitor/insights/container-insights-overview)
- [Prometheus](https://prometheus.io/)
- [HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

### CPU utilization

Using the API of the solution you can create CPU utilization with these commands, that leverage the `pi` endpoint of the API (calculate pi number with x digits).

```bash
digits=20000  # Test with a couple of digits first (like 10), and then with more (like 20,000) to produce real CPU load
# Determine endpoint IP depending of whether the cluster has outboundtype=uDR or not
aks_outbound=$(az aks show -n aks -g $rg --query networkProfile.outboundType -o tsv)
if [[ "$aks_outbound" == "userDefinedRouting" ]]; then
  endpoint_ip=$azfw_ip
  echo "Using Azure Firewall's IP $azfw_ip as endpoint..."
else
  endpoint_ip=$nginx_svc_ip
  echo "Using Ingress Controller's IP $nginx_svc_ip as endpoint..."
fi
# Tests
echo "Testing if API is reachable (no stress test yet)..."
curl -k "https://${endpoint_ip}.nip.io/api/healthcheck"
curl -k "https://${endpoint_ip}.nip.io/api/pi?digits=5"
function test_load {
  if [[ -z "$1" ]]
  then
    seconds=60
  else
    seconds=$1
  fi
  echo "Launching stress test: Calculating $digits digits of pi for $seconds seconds..."
  for ((i=1; i <= $seconds; i++))
  do
    curl -s -k "https://${endpoint_ip}.nip.io" >/dev/null 2>&1
    curl -s -k "https://${endpoint_ip}.nip.io/api/pi?digits=${digits}" >/dev/null 2>&1
    sleep 1
  done
}
test_load 120 &
```

You can check the increased CPU utilization in Azure Monitor in Prometheus.