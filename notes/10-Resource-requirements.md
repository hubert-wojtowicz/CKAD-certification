# Resource requirements
## Possibilities to set request and limits
1. define request and limits inside container
2. use LimitRange to set default requests and limits for every Pod within namespace
3. use RequestQuota to establish namespace collective for all Pods limits and requests

```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
    resources:
      request:
        memory: "1Gi" # Gi, Mi, Ki, G, M, K
        cpu: 1 # min 1m (milicore)
      limits:
        memory: "2Gi"
        cpu: 2
```
- no exceeding of cpu possible - cpu limit is throttle
- exceeding of memory limit terminate pod
- default limits for container are established by:
```yml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi
    defaultRequest:
      memory: 256Mi
    type: Container
```
and
```yml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1
    defaultRequest:
      cpu: 0.5
    type: Container
```