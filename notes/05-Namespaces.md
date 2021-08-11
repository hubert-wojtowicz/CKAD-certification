# Namespaces

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
