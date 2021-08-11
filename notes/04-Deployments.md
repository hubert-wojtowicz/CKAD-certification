# Deployment
- capability to upgrade underlying instances
- keep history of upgrade
- enable rollbacks
- `kubectl scale deployment --replicas=3 <deployment-name>`
- `kubectl expose pod <pod-name> --name `

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
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
# pod

You CANNOT edit specifications of an existing POD other than the below.
- spec.containers[*].image
- spec.initContainers[*].image
- spec.activeDeadlineSeconds
- spec.tolerations

## rolling updates & deployment rollback
- rollout vs versioning:
  - when first create deployment it triggers rollout
  - new rollout creates new deployment revision
  - every change of container version trigger new version

- `kubectl rollout status deployment/myapp-deployment` - see status
- `kubectl rollout history deployment/myapp-deployment` - see revisions and history of deployment

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
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
        image: nginx:1.7.1 # change from 1.7.0 -> 1.7.1 
  replicas: 3
  selector:
    matchLabels:
      type: front-end

```
- `kubectl apply -f deployment-def.yaml` - this will take into account change of image version
- `kubectl set image deployment/myapp-deploy nginx=nginx:1.9.1` - alternative way to change image version
- upgrade create **new replicaset** under the hood to satisfy process
- `kubectl rollout undo deployment/myapp-deployment` - rollback deployment

### switches
- `--record` - safe command used in revision history
- `--revision=<n>` - refer to revision id 

### Deployment strategies
1. Recreate - all down, all new
2. Rolling update - down and up one by one