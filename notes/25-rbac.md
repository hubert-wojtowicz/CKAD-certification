kubectl auth can-i create nodes --as dev-user --namespace test

master node exposes following routes:
- /metrics
- /healthz
- /version
- /api      (core)
- /apis     (names)
- /logs

/api and /apis are responsible for cluster functionalities

- /apis (below are API Groups)
    - /apps 
        -/v1 (below are resources)
            - /deployments (below are verbs)
                - /list
                - /get
                - /create
                - /delete
                - /update
                - /watch
            - /replicas
            - /statefulset
    - /extensions
    - /networking
    - /storage.k8s.io
    - /authentication.k8s.io
    - /certificates.k8s.io

Authorization mechanism
- Node - kublet access kube-api - for example:
    - read
        - services
        - endpoint
        - Nodes
        - Pods
    - write
        - node status
        - pod status
        - events
    kublet should be part of system node-group and have a name prefixed with system:node:nodeName
- Attribute Based Authorization Control (ABAC)
    Policies for each and every user as json file read by kube-api.
- Role Based Authorization Control (RBAC)
    User is associated with role. Less changes.
- Webhook
- Always allow (default)
- Always deny

When there is multiple authorization mechanism at least one must pass to grant access.

Creating Role:
```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
    name: developer
rules:
    - apiGroups: [""] # for core group leave apiGroup
      resources: ["pods"]
      verbs: ["list", "get", "create", "update", "delete"]
    - apiGroups: [""] # for core group leave apiGroup
      resources: ["pods"]
      verbs: ["list", "get", "create", "update", "delete"]
      resourceNames: ["blue", "orange"] # optional indication of resources to be more specific
```
Creating user role-binding:
```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
    name: devuser-developer-binding
subjects:
    - kind: User
      name: dev-user
      apiGroup: rbac.authorization.k8s.io/v1
roleRef:
    kind: Role
    name: developer
    apiGroup: rbac.authorization.k8s.io/v1
```
kubectl get roles
kubectl get rolebinding
kubectl describe role developer
kubectl describe rolebinding devuser-developer-binding

kubectl auth can-i create deployments

impersonification:
kubectl auth can-i create deployments -as dev-user
kubectl auth can-i create deployments -as dev-user --namespace test


Resources can be categorized as:
- cluster scope (`kubectl api-resources --namespaced=false`)
    - nodess
    - pv
    - clusterroles
    - clusterrolebindings
    - certificatesigningrequests
    - namespaces
- namespace scope (`kubectl api-resources --namespaced=true`)
    - pod
    - role
    - rolebinding

Creating Cluster Role:
```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
    name: cluster-administrator
rules:
    - apiGroups: [""] # for core group leave apiGroup
      resources: ["nodes"]
      verbs: ["list", "get", "create", "delete"]
```

Creating Cluster Role Binding:
```yml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
    name: cluster-admin-role-binding
subjects:
    - kind: User
      name: cluster-admin
      apiGroup: rbac.authorization.k8s.io/v1
roleRef:
    kind: ClusterRole
    name: cluster-administrator
    apiGroup: rbac.authorization.k8s.io/v1
```

We can create ClusterRole to namespaced scope object and then role spans across all namespaces. 