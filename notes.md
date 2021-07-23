continue: https://bec.udemy.com/course/certified-kubernetes-application-developer/learn/lecture/14112621#questions
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
