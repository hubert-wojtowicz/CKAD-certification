## Storage classes
```yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```
## Volumes

```yml
apiVersion: v1
kind: Pod
metadata:
  name: random-numbers-generator
spec:
  containers:
  - image: alpine
    name: alpine
    command: ["/bin/sh","-c"]
    args: ["shuf -i 0-100 -n 1 >> /opt/number.out;"]
    volumeMounts: 
    - mountPath: /opt
      name: data-volume
  volumes:
  - name: data-volume
    hostPath:
      path: /data     # path on node
      type: Directory
```
Kubernetes support storage:
1. NFS 
2. GlusterFS
3. Flocker
4. ceph
5. scaleio
6. aws
7. azure disk
8. google persistance disk

Example:
```yml
  volumes:
  - name: data-volume
    awsElasticBlockStore:
      volumeId: <volume-id>
      fsType: ext4
```

## Persistent Volumes (PVX)
Pool of storage volume that can be allocated wit Persistent Volume Claim (PVC).
```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: myvolume
spec: 
  accessModes:
    - ReadWriteOnce # | ReadOnlyMany | ReadWriteMany
  capacity: 
    storage: 1Gi
  awsElasticBlockStore:
    volumeId: <volume-id>
    fsType: ext4
```
### Access modes:
- RWO - ReadWriteOnce
- ROX - ReadOnlyMany
- RWX - ReadWriteMany
- RWOP - ReadWriteOncePod

## Persistent Volume Claim (PVC)

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: myclaim
spec: 
  accessModes:
    - ReadWriteOnce # | ReadOnlyMany | ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  resources:
    requests:
      storage: 500Mi
```

## Using PVC in volume
```yml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: myfrontend
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: myclaim
```
