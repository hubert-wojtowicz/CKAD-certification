Whenever request is done to kube-apiserver (might be rest or kubectl) first user is authenticated by user credentials, then it is checked wether user has required permissions to perform particular action on resource with particular verb.
That's not all steps in request check pipeline. 
There is next step called Admission Controller.

kubectl (request to kube-apiserver) -> authentication -> authorization -> admission controller -> precessing action.

Admission Controller check body of request. Examples:
- only permit images from particular registry
- only images without latest tag
- do not run image as root user
- limit to particular linux capability only
- pod allays has labels

Example of pre-build admission controllers:
- AlwaysPullImages - pull image on every pod creation
- DefaultStorageClass - automatically adds storage class to pvc if no specified
- EventRateLimit
- NamespaceExist - check wether ns exists (there is disabled by default NamespaceAutoProvision)

kube-apiserver -h | grep enable-admission-plugins

/etc/kubernetes/manifests/kube-apiserver.yaml

Types of Admission Controllers
- Mutating Admission Controller
- Validating Admission Controller
- mixed

Custom Admission Controllers are plugged into pipeline with webhooks:
- Mutating Admission Controller Webhook
- Validating Admission Controller Webhook

Webhook pass Admission Review object (JSON) and respond with Admission Review result object.
Webhook must implement endpoint:
POST ~/validate
or
POST ~/mutate

Admission Controller order - first run mutating then validating.


example of registering Admission Controller:
```yml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration # or MutatingWebhookConfiguration
metadata:
    name: "pod-policy.example.com"
webhooks:
- name: "pod-policy.example.com"
  clientConfig:
    #url: "https://external-server.example.com" - if webhook is outside cluster
    service:
      namespace: "webhook-namespace"
      name: "webhookservice"
    caBundle: "Ci0tLS0tQk.....tLS0K" # certificate bundle
  rules: # when call this server - we may not want to call every time :)
    - apiGroups: [""]
      apiVersion: ["v1"]
      operations: ["CREATE"]
      resources: ["pods"]
      scope: "Namespaced"
```