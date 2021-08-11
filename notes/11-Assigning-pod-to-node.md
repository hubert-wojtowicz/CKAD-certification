# NodeAffinity - Connects pods to nodes with specified labels.
`kubectl get nodes node01 --show-labels` - help to identify labels applied to node without reading (filtered) state spec of node

```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
  affinity:
    nodeAffinity:
      requireDuringSchedulingIgnoreDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: size
            operator: In
            values:
            - Large
            - Medium
```
alternative:
```yml
...
          - key: size
            operator: NotIn
            values:
            - small
```

```yml
...
          - key: size
            operator: Exists
```
Node Affinity Types:
- Available
  - (required|preferred)DuringSchedulingIgnoreDuringExecution
- Planned
  - requiredDuringSchedulingRequiredDuringExecution

# Node selector
## Pod definition 
```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
  nodeSelector:
    size: Large
```
`k label node <node-name> <label-key>=<label-value>`

## Limitations
1. Not possible to use logical operator like `or`, `and`, `not` etc.


# Taints and Tolerations 
- bug and person with anti-mosquito remedy - pod and node
- Pod has (in)tolerations established
- Node has taints established
- if we put taint on node, pods without tolerations are not scheduled there 
- this concept does not help to force the particular pod to land on particular node - rater exclude pods from nodes. For assignment pod to node there is NodeAffinity. 
- master nodes has taint set by default to protect management software. See: `k describe node kubemaster | grep Taint`

`k taint nodes <node-name> key=value[:NoSchedule|PreferNoSchedule|NoExecute]`
Taint-effect define what happen if pod does not tolerate taints:
1. NoSchedule - pod will not be scheduled on the node
2. PreferNoSchedule - schedule will try not to schedule on the node, but that's not guaranteed
3. NoExecute - no schedule new pods on the node and evict existing pods if they are intolerant

example:
`k taint node node1 app=blue:NoExecute` - means all pods with labels app=blue will be scheduled on node1 and other pods that exist there will be evicted.
equivalent:
```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
  tolerations:
  - key: app
    operator: "Equal"
    value: blue
    effect: NoExecute
```

To remove taint place minus at the end:
`k taint node node1 app=blue:NoExecute-`