# Monitor and debug applications
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

# Container logging
- `docker run -d kodekloud/event-simulator` - detached mode
- `docker logs -f ecf` - attach to stdout
- `kubectl logs -f <pod-name>` - get pods log from stdout, `-f` gives live experience
- if there are more containers in pod: `kubectl logs -f <pod-name> <container-name>`