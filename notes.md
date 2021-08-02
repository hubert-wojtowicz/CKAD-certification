continue: https://bec.udemy.com/course/certified-kubernetes-application-developer/learn/lecture/12299468#questions

# 2021-08-02 21:42

## cron jobs


```yml
apiVersion: batch/v1beta1
kind: CronJob
metadata: 
  name: reporting-cron-job
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    completions: 3
    parallelism: 3
    template:
      spec:
        containers:
        - name: math-add
          image: ubuntu
          command: ['expr', '3', '+', '2']
        restartPolicy: Never # by default `allays` so without setting this container never reach state Completed, but recreate every time process end
```

## jobs
- `kubectl create job throw-dice-job --image kodekloud/throw-dice --dry-run=client -o yaml`
- this is one time run process calculating expression
```yml
apiVersion: v1
kind: Pod
metadata: 
  name: math-pod
spec:
  containers:
  - name: math-add
    image: ubuntu
    command: ['expr', '3', '+', '2']
  restartPolicy: Never # by default `allays` so without setting this container never reach state Completed, but recreate every time process end
```
- job is abstraction over such processes that complete one by one in pipeline (chain) 

```yml
apiVersion: batch/v1
kind: Job
metadata: 
  name: math-add-job
spec:
  completions: 3
  parallelism: 3
  template:
    spec:
      containers:
      - name: math-add
        image: ubuntu
        command: ['expr', '3', '+', '2']
      restartPolicy: Never # by default `allays` so without setting this container never reach state Completed, but recreate every time process end
```
- to se output of job we need to log stdout of pod `kubectl log pod <name>`...


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


## labels and selectors
- `kubectl get pods --selector app=App1`

## Monitor and debug applications
- Kubelet component on node called cAdvisor is responsible for sending data for aggregation
- Metric Server - in memory cluster wide solution for retrieving recent metrics
  - to enable in minikube `minikube addons enable metric-server`
  - to enable independently `git clone https://github.com/kubernetes-sigs/metrics-server.git && kubectl create -f deploy/1.8+/`
  - to use 
    - `kubectl top node`
    - `kubectl top pod`
- Other solutions:
  - Prometheus
  - Elastic Stack
  - Datadog
  - dynatrace
### tricks
- `kubectl create -f .` - runs against all files in directory
- `watch "kubectl top node"` - real-life statistics

## Container logging
- `docker run -d kodekloud/event-simulator` - detached mode
- `docker logs -f ecf` - attach to stdout
- `kubectl logs -f <pod-name>` - get pods log from stdout, `-f` gives live experience
- if there are more containers in pod: `kubectl logs -f <pod-name> <container-name>`

## Liveness probes
Used for application is not in locked state.

```yml
  livenessProbe:
    httpGet:
      path: /api/ready
      port: 8080
```

## Readiness probes
### Pod status
1pat. Pending (first created)
2. Container Creating (scheduled)
3. Running 

### Pod conditions (true|false)
1. PodScheduled - scheduled on the node
2. Initialized
3. ContainersReady - when all containers in pod are ready
4. Ready - running and ready to accept user traffic

### example from `kubectl describe pod`
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
## reading documentation
- `k explain  pods.spec.containers.securityContext | less` - gives documentation that fits this key
- `kubectl explain  pods.spec.containers.securityContext --recursive | less` - gives documentation that fits this key
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/


# 2021-08-01

# Multi-Container Pods
## Patterns:
1. Ambassador - for example app that manages configuration of service connections (like different databases per environment)
2. Adapter - for example normalization of logs before sending to log aggregation server
3. Sidecar - logger agent next to application instance

Pod share:
- network 
- storage
- lifecycle

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

## Resource requirements
#### Possibilities to set request and limits
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

# 2021-07-29
## vim
- `<n>h`, `<n>j`, `<n>k`, `<n>l` - left, down, up, right, where `<n>` is repeat number
- `G` - end of file
- `g` - beginning of file
- `<n>{`, `<n>}` - skip blok of code up and down, where `<n>` is repeat number
- `<n>dd`, `u` - delete and undo delete of line
- `yy` - copy line to clipboard
- `p` - paste clipboard
- `V` - visual mode 
- `o` (or `O`) - put you in the INSERT mode line below (above)
- `w`, `b` - go next word up and backward 
- `W`, `B` - go next whitespace up and backward 
- `:30` go to line 30
- `0` - move cursor to beginning of line
- `^` - move cursor to beginning of line (skipping spaces)
- `$` - move to end of line
- `t<c>` - set cursor one character before c in line (`f<c>` on the character)
- `cw` - change word (forward) that starts on prompt
- `dw` - delete wort
- `D` - delete rest of the line
- `C` - delete rest of the line and go to insert mode 
- `ct<c>` change line until you will find `<c>` character for example `ct}`. `;` allows to jump to next found occurrence
- `*` move to next occurrence of prompted word
- `z` move prompted element to center of screen
- `a` - set insert mode on next character
- `A` - set insert mode at the end of the line
- `<n>x` - delete (forward) `<n>` characters prompt is over
- `<n>~` - for `<n>` chars (forward) capitalize if lowercase, lowercase if capital
- `.` - repeat last command for example `3xj.` remove 3 characters go line down and repeat the same operation
- `<n>r` - replace `<n>` letters
- `R` - override letters starting from cursor
- `<n>>`, `<n><` - move block right or left `<n>` times

continue learning vim: https://youtu.be/IiwGbcd8S7I?t=2414

## tricks
- `kubectl get secret sa-token -o jsonpath='{.data.token}' | base64 --decode` - get decoded Bearer from SA

# 2021-07-28

## tricks
- `grep -B 3 -A 2 foo README.txt` - find foo and display result with 3 before and 2 after lines
- `grep -C 3 foo README.txt`- find foo and display result with 3 before and after lines
- `grep -F -e '' -e 'foo' README.txt` - highlight in context of whole file (https://unix.stackexchange.com/a/340417)
- `kubectl exec -it my-k8s-pod ls /var/run/secret/kubernetes.io/serviceaccount` - run command without entering shell, list all 3 secrets defined by sa

## service account
- `k create serviceaccount <sa-name>`
- `k get serviceaccount`
- `k describe serviceaccount <sa-name>`

- creation of sa automatically generate `token` (Bearer token for REST calls to kubernetes-api) that is stored as secret
- if app is hosted in k8s then do not export token, just mount it as volume
- there is `default` serviceaccount (very basic privileges) in every namespace that is mounted to every pod on creation (you can prevent mouthing it with adding to declarative version following property `automountServiceAccountToken:false`)

```yml
apiVersion: v1
type: Pod
metadata:
  name: ubuntu
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep", 3600]
  serviceAccount: dashboard-sa # mount additional sa beside default one
```
- if edit deployment it will trigger new rollout of pods


## security context
### docker security
 - `ps aux` list only processes saw inside namespace - id of processes is different for parent namespace
 - by default all processes inside docker are run with root user, this behavior can be override with `docker run --user=1000 ubuntu sleep 3600` or with command `docker run ubuntu sleep 3600` and dockerfile :
 ```
 FROM ubuntu
 ...
 USER 1000
 ```
 - to limit root user allowed actions inside docker there are `linux capabilities` implemented
  - to add capabilities `docker run --cap-add MAC_ADMIN ubuntu`
  - to add all capabilities `docker run --privileged ubuntu`
### pod security
#### container settings override pod settings
#### pod settings example:
```yml
apiVersion: v1
type: Pod
metadata:
  name: ubuntu
spec:
  securityContext:
    runAsUser: 1000 # id
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep", 3600]
```
#### container settings example
```yml
apiVersion: v1
type: Pod
metadata:
  name: ubuntu
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep", "3600"]
    securityContext:
      runAsUser: 1000 # id
      capabilities: # only supported on this level
        add: ["MAC_ADMIN"]
```

## environment variables in kubernetes

### pass by docker command i.e.: `docker run -e APP_COLOR=pink simple-webapp-color`
### pass by pod definition:
#### with value
```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
    ports:
    - containerPort: 8080
    env:
      - name: APP_COLOR
        value: pink
```
#### with config maps:
```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
    ports:
    - containerPort: 8080
    envFrom:
      - configMapKeyRef:
          name: config-map-name
```
#### with secret:
```yml
apiVersion: v1
type: Pod
metadata:
  name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
    ports:
    - containerPort: 8080
    envFrom:
      - secretKeyRef:
          name: config-map-name
```
## config map 

### imperative command
#### from k-v pair
```
kubectl create configmap <config-name> \
  --from-literals=<key_1>=<value_1>
  ...
  --from-literals=<key_n>=<value_n>
```
#### from k-v pair from file
```
kubectl create configmap <config-name> 
  --from-file=<path-to-file>
```
#### get sec
### declarative representation
```yml
apiVersion: v1
type: ConfigMap
metadata:
  name: app-config
data:
  Key_1: val_1
  ...
  Key_n: val_n
```

## secret
### imperative command
##### from k-v pair
```
kubectl create secret generic <config-name> \
  --from-literals=<key_1>=<value_1>
  ...
  --from-literals=<key_n>=<value_n>
```

example: `k create secret generic db-secret --from-literal=DB_Host=sql01 --from-literal=DB_User=root --from-literal=DB_Password=password123`
#### from k-v pair from file
```
kubectl create secret <config-name> 
  --from-file=<path-to-file>
```
#### get secret value
- `kubectl get secrets`
- `kubectl describe secrets` - values hidden
- `kubectl describe secrets app-secret -o yaml` - to see values
- `echo -m 'paswd' | base64` - create base64 encoded text
- `echo -m 'cGFzd3JK' | base64 --decode` - decode base64 text
### declarative representation
```yml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
  Key_1: base64_val_1
  ...
  Key_n: base64_val_1
immutable: true
```

## ways of injecting into pod ConfigMaps and Secrets
- environment variable from secret
```yml
envFrom:
  - (secret|configMap)Ref:
      name: <name>
```

- single environment variable
```yml
env:
  - name: DB_Passwod
    valueFrom:
      (secret|configMap)KeyRef:
        name: <name>
        key: <value|base64-value>
```

- from volume
```yml
volumes:
- name: <app-volume-name>
  (secret|configMap):
    (secret|configMap)Name: <app-(secret|configMap)-name>
```
When there is many key they are injected as separate files.
# 2021-07-27
## pod

You CANNOT edit specifications of an existing POD other than the below.
- spec.containers[*].image
- spec.initContainers[*].image
- spec.activeDeadlineSeconds
- spec.tolerations

## docker 
```
FROM ubuntu:14.04
RUN \
...
ADD ..
ADD ..
ADD ..
ENV HOME /root
WORKDIR /root
CMD["sleep", "2"]
```
- then `doceker run ubuntu-sleeper` sleeps 2 units
- to override it `docker run ubuntu-sleeper sleep 5` need to repeat sleep command-this can be avoided with `ENTRYPOINT`

```
FROM ubuntu:14.04
RUN \
...
ADD ..
ADD ..
ADD ..
ENV HOME /root
WORKDIR /root
ENTRYPOINT["sleep"]
CMD["2"]
```
- then `docker run ubuntu-sleeper` sleeps 2 units
- then `docker run ubuntu-sleeper 5` sleeps 5 units

```yml
apiVersion: v1
kind: pod
metadata:
  name: ubuntu-sleeper-pod
spec:
  spec:
    containers:
    - image: ubuntu-sleeper
      name: ubuntu-sleeper-pod
      command: ["sleep2.0"] # override entrypoint instruction in docker
      args: ["10"] # override args instruction in docker
```


# 2021-07-26
`kubectl expose pod <pod-name> --name `

# 2021-07-23
## tricks
- `kubectl get all [--all-namespaces]`
- `kubectl [command] [TYPE] [NAME] [--dru-run] -o <json|name|wide|yaml>`
- `k get ns --no-header | wc -l` - calculate lines of output
- `kubectl run nginx --image=nginx` - run pod

---
| No.| Kubectl apply                                                                                                  | Kubectl create                                                                                                | kubectl replace |
| ---| ---                                                                                                            | ---                                                                                                           | ---             |
| 1. | It directly updates in the current live source, only the attributes which are given in the file.               | It first deletes the resources and then creates it from the file provided.                                    | NA              |
| 2. | The file used in apply can be an incomplete spec                                                               | The file used in create should be complete                                                                    | NA              |
| 3. | Apply works only on some properties of the resources                                                           | Create works on every property of the resources                                                               | NA              |
| 4. | You can apply a file that changes only an annotation, without specifying any other properties of the resource. | If you will use the same file with a replace command, the command would fail, due to the missing information. | NA              |

## kubectl 
- `kubectl create deployment <deployment-name> --image=<image>`
- `kubectl scale deployment --replicas=3 <deployment-name>`


## k8s objects
### Namespaces

- default namespace
- internal use namespaces:
  - kube-system - resources for internal use like pods, services, dns etc
  - kube-public - resources that should be available for all users
- can create custom namespace
- namespaces can have
  - set of policies who can do what
  - resources limitation storage, RAM, CPU
  - objects can refer to each other straight by name within same namespace
  - to target object from different namespace add suffix `<name>.<namespace>.svc.cluster.local` (this is thanks to when service is created DNS is added automatically)
    - `cluster.local` is default domain of kubernetes cluster
    - `svc` stands for service
- to create resource in different ns you add this info in command like:
  - `kubectl create -f pod-def.yml --namespace=<namespace>`
  - you can use metadata section to provide namespace info - add line `namespace: <namespace-name>` under metadata
- create namespace:
  - with declarative approach

    ```yml
    apiVersion: v1
    kind: namespace
    metadata:
      name: dev
    spec: # optional
      hard:
        pods: "10"
        request.cpu: "4"
        request.memory: 5Gi
        limit.cpi: "10"
        limit.memory: 10Gi
    ```

  - with imperative approach `kubectl create namespace dev`
- `kubectl config set-context $(kubectl config current-context) --namespace=<target-namespace>` - change namespace

### Deployments
- capability to upgrade underlying instances
- keep history of upgrade
- enable rollbacks


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
# 2021-07-22

## Pod replication:

# tricks
- `kubectl get pod | awk -vORS=, 'NR!=1 {print $1}'`
- `kubectl delete pods -l app=my-app`

## kubectl
- `kubectl get replicaset`
- `kubectl delete replicaset <name>`
- `kubectl replace -f replicaset-definition.yml`
- `k scale --replicas=5 rs/new-replica-set`

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

# 2021-07-21

## tricks
```
$ cat > pod-def.yaml 
<paste definition here>
```
- `kubectl describe pod <name> | grep -i image` - finds line with 'image' (-i ignore case)

## kubectl

- ``kubectl create -f definition.yml``
- ``kubectl apply -f definition.yml`` - what is difference?
- ``kubectl describe <object> <object-name>``
- ``kubectl get pods -o wide`` - to se pod underlying nodes
- ``kubectl run [-i] [--tty] --attach <name> --image=<image>``
- ``kubectl run <name> --image=<image> --dry-run=client -o yaml > pod.yaml``

# 2021-07-20:
## theory recap
- control plane components:
  - kube-scheduler - watches for newly created Pods with no assigned node, and selects a node for them to run on
  - kube-apiserver 
  - kube-controller-manager
  - cloud-controller-manager - plane component that runs controller processes.
  - cloud-controller-manager
- worker node
  - kubelet
  - kube-proxy
[<img src="https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg">](https://kubernetes.io/docs/concepts/overview/components/)
## awk command:
- `cat /etc/passwd | awk -F ":" '{print $1"\t"$6"\t"$7}'`
- `awk -F "/" '/^\// {print $NF}' /etc/shells | uniq`

## kubectl
- ``kubectl run ngnix --image ngnix``
