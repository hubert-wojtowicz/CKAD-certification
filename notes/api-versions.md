Versions types:
- Alpha
- Beta
- GA/stable

Query - Preferred Version is settings to use particular version by default when multiple version of same api endpoint is enabled.
Command - Storage Version is settings to use particular version by default when multiple version of same api endpoint **for creating resource** is enabled.

For query action it can be discovered Preferred Version by GET request to kube-apiserver for example GET ~/apis/batch should return Preferred Version.
In case of command to find out similar information ETCD must be quired.
Example:
ETCDCTL_API=3 etcdctl
--endpoints=<val1>
--cacert=<val2>
--cert=<val3>
--key=<val4>
get "/registry/deployments/default/blue" --print-value-only

Enabling api version can be done with kube-apiserver manifest by adding key:
`--runtime-config=batch/v2alpha1,...`


Deprecation - there [are 4 rules](https://kubernetes.io/docs/reference/using-api/deprecation-policy/) of deprecation in k8s.

Version converter [may require to be enabled](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-convert-plugin)
kubectl convert -f <old-file> --output-version <new-api>
