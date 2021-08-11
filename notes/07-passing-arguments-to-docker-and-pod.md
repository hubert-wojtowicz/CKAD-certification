## docker 
```
FROM ubuntu:14.04
RUN \
...
ADD ..
ADD ..
ADD ..
ENV HOME /root
WORKDIR /root
CMD["sleep", "2"]
```
- then `docker run ubuntu-sleeper` sleeps 2 units
- to override it `docker run ubuntu-sleeper sleep 5` need to repeat sleep command-this can be avoided with `ENTRYPOINT`

```
FROM ubuntu:14.04
RUN \
...
ADD ..
ADD ..
ADD ..
ENV HOME /root
WORKDIR /root
ENTRYPOINT["sleep"]
CMD["2"]
```
- then `docker run ubuntu-sleeper` sleeps 2 units
- then `docker run ubuntu-sleeper 5` sleeps 5 units

```yml
apiVersion: v1
kind: pod
metadata:
  name: ubuntu-sleeper-pod
spec:
  spec:
    containers:
    - image: ubuntu-sleeper
      name: ubuntu-sleeper-pod
      command: ["sleep2.0"] # override entrypoint instruction in docker
      args: ["10"] # override args instruction in docker
```