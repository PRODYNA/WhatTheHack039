# Challenge 03 - AKS Monitoring

[< Previous Challenge](./Challenge-02.md) - **[Home](../README.md)** - [Next Challenge >](./Challenge-04.md)

## Introduction

This challenge will cover monitoring in AKS, using open source components such as Prometheus and Azure services such as
Azure Monitor.

## Description

- Implement Prometheus/Grafana
- You can access container logs via Azure Monitor
- Increase the CPU utilization of the API container with the `pi` API endpoint, and see the corresponding metric
  increase in Prometheus and/or Azure Monitor
- Implement a mechanism so that Kubernetes increases the amount of API pods when CPU utilization goes high
- If you didn't do it already, configure a mechanism that scales the cluster automatically in and out depending on the
  required capacity

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

Using the API of the solution you can create CPU utilization with these commands, that leverage the `pi` endpoint of the
API (calculate pi number with x digits).

In the Challenge Resources directory you can find a bash script to generate load by repeatedly invoking the `pi`
endpoint.

- [/api-load-test.sh](../Challenge_Resources/Challenge_03/api-load-test.sh)

```bash
../Challenge_Resources/Challenge_03/api-load-test.sh
```

You can check the increased CPU utilization in Azure Monitor in Prometheus.