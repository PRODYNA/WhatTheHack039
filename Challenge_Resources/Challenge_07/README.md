# OSM Setup

OSM Setup according to https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-about
and https://release-v1-2.docs.openservicemesh.io/docs/demos/ingress_k8s_nginx/

Add ingress namespace to OSM

```shell
osm namespace add ingress-nginx --mesh-name osm --disable-sidecar-injection
```

Add application namespace to OSM

```shell
osm namespace add hack --mesh-name osm 
```

Restart deployments in namespace to enable sidecar injection.

```shell
kubectl rollout restart -n hack deployments
```

<mark>At this point the application becomes unavailable since ingress is not allowed to access the web
application.<mark>

Add Ingress backend to OSM to allow ingress to access the web application again.

```shell
kubectl apply -f - <<EOF
kind: IngressBackend
apiVersion: policy.openservicemesh.io/v1alpha1
metadata:
  name: web
  namespace: hack
spec:
  backends:
  - name: web
    port:
      number: 80 # targetPort of web service
      protocol: http
  sources:
  - kind: Service
    namespace: ingress-nginx
    name: ingress-nginx-controller
EOF
```

Enable secured connections between ingress and web application.

```shell
kubectl edit meshconfig osm-mesh-config -n kube-lsb_release -a

# TODO Patch
# kubectl patch sa default --type='json' -p='[{"op": "add", "path": "/spec/certificate", "value": {"name": "whatever" } }]'
```

```yaml
certificate:
  ingressGateway:
    secret:
      name: osm-nginx-client-cert
      namespace: kube-system # replace <osm-namespace> with the namespace where OSM is installed
    subjectAltNames:
      - ingress-nginx.ingress-nginx.cluster.local
    validityDuration: 24h
```

```shell
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    # proxy_ssl_name for a service is of the form <service-account>.<namespace>.cluster.local
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_ssl_name "default.hack.cluster.local";
    nginx.ingress.kubernetes.io/proxy-ssl-secret: "kube-system/osm-nginx-client-cert"
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "on"
  name: web
  namespace: hack
spec:
  ingressClassName: nginx
  rules:
  - host: hack.20.8.64.96.traefik.me
    http:
      paths:
      - backend:
          service:
            name: web
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
  tls:
  - hosts:
    - hack.20.8.64.96.traefik.me
    secretName: web-tls
EOF
```    

```shell
kubectl apply -f - <<EOF
kind: IngressBackend
apiVersion: policy.openservicemesh.io/v1alpha1
metadata:
  name: web
  namespace: hack
spec:
  backends:
  - name: web
    port:
      number: 80 # targetPort of web service
      protocol: https
    tls:
      skipClientCertValidation: false
  sources:
  - kind: Service
    namespace: ingress-nginx
    name: ingress-nginx-controller
  - kind: AuthenticatedPrincipal
    name: ingress-nginx.ingress-nginx.cluster.local
EOF
```



