
## Pod replication:

## kubectl
- `k scale --replicas=5 rs/new-replica-set`

- `kubectl get replicaset`
- `kubectl delete replicaset <name>`
- `kubectl replace -f replicaset-definition.yml`

## k8s objects
### ReplicationController
```yml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myapp-rc
  labels:
    app: myapp
    type: front-end
spec:
  template:
    metadata:
      name: myapp-pod
      labels: 
        app: myapp
        type: front-end
    spec:
      containers:
      - name: nginx-container
        image: nginx
  replicas: 3

```
### ReplicaSet - newer approach for replication
- ReplicaSet - newest object to handle spec behind pod replication. It cam also handle pods that are already created, that's why there is optional `selector` property in definition

```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-rs
  labels:
    app: myapp
    type: front-end
spec:
  template:
    metadata:
      name: myapp-pod
      labels: 
        app: myapp
        type: front-end
    spec:
      containers:
      - name: nginx-container
        image: nginx
  replicas: 3
  selector:
    matchLabels:
      type: front-end

```