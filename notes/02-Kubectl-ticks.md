# tricks (from most useful to less one)

## mostly used
- `kubectl exec kube -- echo $PWD` - display env variable
- `kubectl get pods --selector app=App1`
- `kubectl exec --stdin --tty shell-demo -- /bin/bash` - exec into pod
- `kubectl exec -it my-k8s-pod ls /var/run/secret/kubernetes.io/serviceaccount` - run command without entering shell, list all 3 secrets defined by sa
- `kubectl create -f .` - runs against all files in directory
- `watch "kubectl top node"` - real-life statistics
- `grep -C 3 foo README.txt`- find foo and display result with 3 before and after lines
- `kubectl describe pod <name> | grep -i image` - finds line with 'image' (-i ignore case)
- `k get ns --no-header | wc -l` - calculate lines of output
- `kubectl get secret sa-token -o jsonpath='{.data.token}' | base64 --decode` - get decoded Bearer from SA

## tricky
- `kubectl delete pods -l app=my-app`
- `kubectl get nodes node01 --show-labels` - help to identify labels applied to node without reading (filtered) state spec of node
- `grep -B 3 -A 2 foo README.txt` - find foo and display result with 3 before and 2 after lines
- `kubectl get all [--all-namespaces]`

## to complex for exam
- `cat /etc/passwd | awk -F ":" '{print $1"\t"$6"\t"$7}'` 
- `awk -F "/" '/^\// {print $NF}' /etc/shells | uniq`
- `kubectl get pod | awk -vORS=, 'NR!=1 {print $1}'`

## curio
- write to file
```
$ cat > pod-def.yaml 
<paste definition here>
```
- `grep -F -e '' -e 'foo' README.txt` - highlight in context of whole file (https://unix.stackexchange.com/a/340417)

- ```for j in `seq 2 6`; do echo "this is line $j"; done;```
- ```while [ 1 -le 2 ]; do echo "test"; sleep 1; done```
- ```for j in `seq 1 3`; do if (($j == 2)); then echo "two!"; else echo $j; fi; sleep 2; done```
- ```x=1; while (( $x < 10 )); do echo $x; x=$(($x+1)); done```


# debugging 
`nc -z -v -w 1 secure-service 80` - check pod connectivity
`sudo netstat -ltup` - check ports occupied with running applications
`my-svc.my-namespace.svc.cluster-domain.example` - full DNS for netcat 
`kubectl exec time-check -- sh -c 'echo $TIME_FREQ'` - particular env varieble
`k exec time-check -- env` - all env variebles
