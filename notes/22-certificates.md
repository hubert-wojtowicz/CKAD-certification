# What to check on certs:
1. Certificate path
2. CN name
3. ALT name
4. Organization
5. Issuer
6. Expiration 


openssl x509 -in /etc/kubernetes/pki/apiserver.cert -text -noout

# cluster created with kubeadm
cat /etc/kubernetes/manifests/kube-apiserver.yaml

retrieve info from certificate

kubectl logs etcd-master

# cluster created manually
cat /etc/systemd/system/kube-apiserver.service

services are configured as OS services you can retrieve logs with:

jornualctl -u etcd.service -l

# when services down

docker logs <container-id>