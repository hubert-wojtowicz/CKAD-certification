# cron jobs
```yml
apiVersion: batch/v1beta1
kind: CronJob
metadata: 
  name: reporting-cron-job
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    completions: 3
    parallelism: 3
    template:
      spec:
        containers:
        - name: math-add
          image: ubuntu
          command: ['expr', '3', '+', '2']
        restartPolicy: Never # by default `allays` so without setting this container never reach state Completed, but recreate every time process end
```

# jobs
- `kubectl create job throw-dice-job --image kodekloud/throw-dice --dry-run=client -o yaml`
- this is one time run process calculating expression
```yml
apiVersion: v1
kind: Pod
metadata: 
  name: math-pod
spec:
  containers:
  - name: math-add
    image: ubuntu
    command: ['expr', '3', '+', '2']
  restartPolicy: Never # by default `allays` so without setting this container never reach state Completed, but recreate every time process end
```
- job is abstraction over such processes that complete one by one in pipeline (chain) 

```yml
apiVersion: batch/v1
kind: Job
metadata: 
  name: math-add-job
spec:
  completions: 3
  parallelism: 3
  template:
    spec:
      containers:
      - name: math-add
        image: ubuntu
        command: ['expr', '3', '+', '2']
      restartPolicy: Never # by default `allays` so without setting this container never reach state Completed, but recreate every time process end
```
- to se output of job we need to log stdout of pod `kubectl log pod <name>`...