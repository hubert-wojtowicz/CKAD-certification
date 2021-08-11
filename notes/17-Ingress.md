# Ingress 
## kubectl
- `kubectl (get|create|describe) ingress`
## Benefits
- define one single endpoint for public use at the same time allow scale number of applications served form cluster under one domain
- allows easily add new services via simple adding new Ingress object
- centralize TLS cert management
- all resources to achieve mentioned goals defined with cluster primitives 


## Components
1. Ingress Controller - it is proxy service that configure TLS and monitor routers, exposed via NodePort service to outside world
2. Ingress Resources - define routes mapping
    - based on domain name
    - based on routes override

### Ingress Controller
1. nginx
2. HAProxy
3. Traefik
4. Istio
### Ingress Resources
- override routes
- remember to deploy service `default-http-backend:80` to handle not matched routes!

```yml
apiVersioning: extension/v1beta1
kind: Deployment
metadata:
  name: nginx-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      name: nginx-ingress
  template:
    metadata:
      labels:
        name: nginx-ingress
    spec:
      containers:
      - name: nginx-ingress-controller
        image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
      args:
      - /nginx-ingress-controller
      - --configmap=$(POD_NAMESPACE)/nginx-configuration
      env:
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      ports:
      - name: http
        containerPort: 80
      - name: https
        containerPort: 443
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    targetPort: 443
    protocol: TCP
    name: https
  selector:
    name: nginx-ingress
---
## example when no rules - just one backend
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-wear
spec:
  backend:
    wear-service: wear-service
      servicePort: 80
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-wear
spec:
  rules:
  - http:
      paths:
      - path: /wear
          backend:
            wear-service: wear-service
            servicePort: 80 
      - path: /watch
          backend:
            wear-service: watch-service
            servicePort: 80 
--- # option
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-wear
spec:
  rules:
  - host: wear.my-online0store.com
    http:
      paths:
      - backend:
          wear-service: wear-service
          servicePort: 80
  - host: watch.my-online0store.com
    http:
      paths:
      - backend:
          wear-service: watch-service
          servicePort: 80 
```