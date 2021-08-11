All Allow - rule for cluster VN that pod can reach any pod within cluster (with IP, pod names, svc)

## NetworkPolicy
1. Ingress traffic
2. Egress traffic

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabel:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          name: api-pod
      namespaceSelector:  # if I will add this line prefixed with "-" at the same level as podSelector then we will get "or" operator.
        matchLabels:      # if this will not be added we will have access from all namespaces
          name: prod      #
    - ipBlock:
        cdir: 192.168.5.10/32
    ports:
    - protocol: TCP
      port: 3306
  egress:
  - to:
    - ipBlock:
        cdir: 192.167.5.10/32
    ports:
    - protocol: TCP
      port: 80

```

Solution supporting NetworkPolicies:
- Kube-router
- Calico
- Romana
- Weave-net
Not supporting NetworkPolicies (object can be created, but will not generate an effect):
- Flannel