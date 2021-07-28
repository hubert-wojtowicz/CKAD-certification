continue: https://bec.udemy.com/course/certified-kubernetes-application-developer/learn/lecture/12970872#questions

# 2021-07-28

## tricks
- `grep -B 3 -A 2 foo README.txt` - find foo and display result with 3 before and 2 after lines
- `grep -C 3 foo README.txt`- find foo and display result with 3 before and after lines
- `grep -F -e '' -e 'foo' README.txt` - highlight in context of whole file (https://unix.stackexchange.com/a/340417)
- `kubectl exec -it my-k8s-pod ls /var/run/secret/kubernetes.io/serviceaccount` - run command without entering shell, list all 3 secrects defined by sa

## service account
- `k create serviceaccount <sa-name>`
- `k get serviceaccount`
- `k describe serviceaccount <sa-name>`

- creation of sa automatically generate `token` (Berer token for REST calls to kubernetes-api) that is stored as secret
- if app is hosted in k8s then do not export token, just mount it as volume
- there is `defult` serviceaccount (very basic privileges) in every namespace that is mounted to every pod on creation (you can prevent mouting it with adding to declarative version following property `automountServiceAccountToken:false`)

```
apiVersion: v1
type: Pod
metadata:
  name: ubuntu
spec:
  containers:
  - name: ubuntu
    image: ubuntu
    command: ["sleep", 3600]
  serviceAccount: dashboard-sa # mount additional sa beside defult one
```
- if edit deployment it will trigger new rollot of pods


## security context
### docker security
 - `ps aux` list only processes saw inside namespace - id of processes is different for parent namespace
 - by default all processes inside docker are run with root user, this behaviour can be overriden with `docker run --user=1000 ubuntu sleep 3600` or with command `docker run ubuntu sleep 3600` and dockerfile :
 ```
 FROM ubuntu
 ...
 USER 1000
 ```
 - to limit root user allowed actions inside docker there are `linux capabilities` implented
  - to add capabilities `docker run --cap-add MAC_ADMIN ubuntu`
  - to add all capabilities `docker run --privileged ubuntu`
### pod security
#### container settings override pod settings
#### pod settings example:
```
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
#### container settigs examople
```
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
      capabilities: # only suppported on this level
        add: ["MAC_ADMIN"]
```

## environment variebles in kubernetes

### pass by docker command i.e.: `docker run -e APP_COLOR=pink simple-webapp-color`
### pass by pod definition:
#### with value
```
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
```
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
```
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
```
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
```
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
- environment varieble from secret
```
envFrom:
  - (secret|configMap)Ref:
      name: <name>
```

- single environment varieble
```
env:
  - name: DB_Passwod
    valueFrom:
      (secret|configMap)KeyRef:
        name: <name>
        key: <value|base64-value>
```

- from volume
```
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
- to override it `doceker run ubuntu-sleeper sleep 5` need to repeat sleep comand-this can be avoided with `ENTRYPOINT`

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
- then `doceker run ubuntu-sleeper` sleeps 2 units
- then `doceker run ubuntu-sleeper 5` sleeps 5 units

```
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

- defaulte namespace
- internal use namespaces:
  - kube-system - resources for internal use like pods, services, dns etc
  - kube-public - resources that should be availiable for all users
- can create custom namespace
- namespaces can have
  - set of policies who can do what
  - resources limitation storage, RAM, CPU
  - objects can refere to each other stright by name within same namespace
  - to target object from different namespace add suffix `<name>.<namespace>.svc.cluster.local` (this is thanks to whewn service is created DNS is added automatically)
    - `cluster.local` is default domain of kubernetes cluster
    - `svc` stands for service
- to create resource in different ns you add this info in command like:
  - `kubectl create -f pod-def.yml --namespace=<namespacce>`
  - you can use metadata section to provide namespace info - add line `namespace: <namespace-name>` under metadata
- create namespace:
  - with declarative apprach

    ```yml
    apiVersion: v1
    kinf: namespace
    metadata:
      name: dev
    spec: # oprional
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
`kubectl get replicaset`
`kubectl delete replicaset <name>`
`kubectl replace -f replicaset-definition.yml`
`k scale --replicas=5 rs/new-replica-set`

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
- ReplicaSet - newest object to handle spec behing pod replication. It cam also handle pods that are already created, that's why there is optional `selector` property in definition

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
## other
- access to KodeKloud

## theory recap
- contol plane components:
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
- cat /etc/passwd | awk -F ":" '{print $1"\t"$6"\t"$7}'
- awk -F "/" '/^\// {print $NF}' /etc/shells | uniq

## kubectl
- ``kubectk run ngnix --image ngnix``
