# Services
- service has cluster io of the service

## ports
1. TargetPort - port on pod (target from service perspective)
2. Port - on the service
3. NodePort - node public port to access service from outside. High port only 30000-32767

## types
1. NodePort
2. ClusterIp
3. LoadBalancer

### NodePort 
```yml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  type: NodePort
  ports:
  - targetPort: 80
    port: 80
    nodePort: 30008
  selector:
    app: myapp
    type: front-end
```
- if selector selects more than one pod - it will use random algorithm to balance load
- service spans all nodes to select pods and allocate port on all nodes!
### ClusterIp 
```yml
apiVersion: v1
kind: Service
metadata:
  name: back-end-service
spec:
  type: ClusterIp
  ports:
  - targetPort: 80
    port: 80
  selector:
    app: myapp
    type: back-end
```

`kubectl expose deployment ingress-controller --name ingress --port 80 --target-port 80 --type NodePort`