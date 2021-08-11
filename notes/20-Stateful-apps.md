## StatefulSet
- similar to deployment
- preserve order of creation
- name of pods are numbered starting from 0
- you do not need to specify host or sub domain
- by default StatefulSet share sam pvc with replicas
- you can create automatically pvc for each replicas when using `volumeClaimTemplate` property in StatefulSet definition

```yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  labels:
    app: mysql
spec:
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - image: mysql
        name: mysql
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  serviceName: mysql-h # this allows to assign all pods to subdomain based on headless service
  podManagementPolicy: parallel # this allows to create all pods at once but it is not default behavior
```

## headless Service
- created like a normal service
- no load balancing
- use pod name and subdomain to create DNS entry, thus allows to reach pod :) 

example DNS: `<stateful-set-name>.<headless-svc-name>.default.svc.local`
example for mysql cluster:
`mysql-0.mysql-h.default.svc.local`
`mysql-1.mysql-h.default.svc.local`
`mysql-2.mysql-h.default.svc.local`

```yml
apiVersion: v1
kind: Service
metadata:
  name: mysql-h
spec:
  ports:
  - port: 3306
  selector:
    app: mysql
  clusterIP: None ## this distinguish headless service
```
