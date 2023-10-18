# Challenge 05

For testing purposes deploy a new pod into the cluster

```shell
kubectl run curl -n hack --image=curlimages/curl --labels="app=curl" sleep 999999
```

Try to access the API from the new pod and wait for the timeout. You may also force quite via Crtl+C ;-)

```shell
kubectl exec -n hack -it curl -- sh -c 'curl http://api.hack.svc.cluster.local:8080/api/healthcheck'
```

Re-label the pod to be able to access the API

```shell
kubectl label --overwrite pods -n hack  curl run=web
```

Try to curl again

```shell
kubectl exec -n hack -it curl -- sh -c 'curl http://api.hack.svc.cluster.local:8080/api/healthcheck'
```

Delete the pod

```shell
kubectl delete pod -n hack curl --now
```