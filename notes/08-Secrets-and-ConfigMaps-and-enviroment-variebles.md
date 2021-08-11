# Pod configuration

## pass by docker command 
`docker run -e APP_COLOR=pink simple-webapp-color`

## pass by pod definition:
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

## with config maps:
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

## with secret:
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

## ConfigMaps 

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

## Secrets
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
