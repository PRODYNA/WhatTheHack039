# OSM Setup

OSM Setup according to https://learn.microsoft.com/en-us/azure/aks/open-service-mesh-about
and https://release-v1-2.docs.openservicemesh.io/docs/demos/ingress_k8s_nginx/. In the project the OSM integration is
activated through ../../Azure/aks.tf.

## Add Namespaces and connect them

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

In order to connect the ingress controller with the application components OSM IngressBackends must be deployed.

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

```shell
kubectl apply -f - <<EOF
kind: IngressBackend
apiVersion: policy.openservicemesh.io/v1alpha1
metadata:
  name: api
  namespace: hack
spec:
  backends:
  - name: api
    port:
      number: 8080 # targetPort of web service
      protocol: http
    tls:
      skipClientCertValidation: false
  sources:
  - kind: Service
    namespace: ingress-nginx
    name: ingress-nginx-controller
EOF
```

## Enable mTLS between ingress and the application components

As a first step the OSM configuration must be extended by certificate we are going to use in the ingress controller.
This is done by patching the meshconfig resource.

```shell
kubectl patch -n kube-system meshconfigs.config.openservicemesh.io osm-mesh-config --type='json' -p='[{"op": "add", "path": "/spec/certificate", "value": {  "certKeyBitSize": 2048,  "serviceCertValidityDuration": "24h",  "ingressGateway": {    "secret": {      "name": "osm-nginx-client-cert",      "namespace": "kube-system"    },    "subjectAltNames": [      "ingress-nginx.ingress-nginx.cluster.local"    ],    "validityDuration": "24h"  }} }]'
```

It will add the following section below spec.certificate: (see YAML below).

```yaml
ingressGateway:
secret:
  name: osm-nginx-client-cert
  namespace: kube-system # replace <osm-namespace> with the namespace where OSM is installed
subjectAltNames:
  - ingress-nginx.ingress-nginx.cluster.local
validityDuration: 24h
```

For verification run

```shell
 kubectl edit -n kube-system meshconfigs.config.openservicemesh.io osm-mesh-config
```

Change the ingress controllers of web and api to operate on the HTTPS protocol and user the new SSL certificate. The
following patches will add the required
annotations.

```shell
kubectl patch ingress -n hack web --type='json' -p='[{"op": "add", "path": "/metadata/annotations", "value": {  "cert-manager.io/cluster-issuer": "letsencrypt-prod",  "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS",  "nginx.ingress.kubernetes.io/configuration-snippet": "proxy_ssl_name \"default.hack.cluster.local\";\n",  "nginx.ingress.kubernetes.io/proxy-ssl-secret": "kube-system/osm-nginx-client-cert",  "nginx.ingress.kubernetes.io/proxy-ssl-verify": "on"} }]'
```

```shell
kubectl patch ingress -n hack api --type='json' -p='[{"op": "add", "path": "/metadata/annotations", "value": {  "cert-manager.io/cluster-issuer": "letsencrypt-prod",  "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS",  "nginx.ingress.kubernetes.io/configuration-snippet": "proxy_ssl_name \"aks-keyvault.hack.cluster.local\";\n",  "nginx.ingress.kubernetes.io/proxy-ssl-secret": "kube-system/osm-nginx-client-cert",  "nginx.ingress.kubernetes.io/proxy-ssl-verify": "on"} }]'
```

The following lines will be added to the ingress controller of web.

```yaml
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    # proxy_ssl_name for a service is of the form <service-account>.<namespace>.cluster.local
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_ssl_name "default.hack.cluster.local";
    nginx.ingress.kubernetes.io/proxy-ssl-secret: "kube-system/osm-nginx-client-cert"
    nginx.ingress.kubernetes.io/proxy-ssl-verify: "on"
```

Change IngressBackend definitions to use https and a AuthenticatedPrincipal as source.
https://release-v0-11.docs.openservicemesh.io/docs/guides/traffic_management/ingress/#ingressbackend-api

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

```shell
kubectl apply -f - <<EOF
kind: IngressBackend
apiVersion: policy.openservicemesh.io/v1alpha1
metadata:
  name: api
  namespace: hack
spec:
  backends:
  - name: api
    port:
      number: 8080 # targetPort of web service
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