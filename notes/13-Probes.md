# Liveness probes
Used for application is not in locked state.

```yml
  livenessProbe:
    httpGet:
      path: /api/ready
      port: 8080
```

# Readiness probes
## Pod status
1pat. Pending (first created)
2. Container Creating (scheduled)
3. Running 

## Pod conditions (true|false)
1. PodScheduled - scheduled on the node
2. Initialized
3. ContainersReady - when all containers in pod are ready
4. Ready - running and ready to accept user traffic

## example from `kubectl describe pod`
```
...
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
```
By default application is ready as soon as container process started. But some application takes time to warm up. That why we create ReadinessProbe

```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
  readinessProbe:
    httpGet:
      path: /api/ready
      port: 8080
    initialDelaySeconds: 10 
    periodSeconds: 5
    failureThreshold: 8 # default 3
```
There are other types:

- script probe:
```yml
  readinessProbe:
    tcpSocket:
      port: 3306
```

- command probe:
```yml
  readinessProbe:
    exec:
      command:
      - cat
      - /app/is_ready
```