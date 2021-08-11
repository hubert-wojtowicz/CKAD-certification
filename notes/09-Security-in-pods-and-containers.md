
## service account

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