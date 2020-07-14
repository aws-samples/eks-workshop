---
title: "Kubernetes Jobs"
date: 2018-11-18T00:00:00-05:00
weight: 20
draft: false
---

### Kubernetes Jobs

A `job` creates one or more pods and ensures that a specified number of them successfully terminate. As pods successfully complete, the job tracks the successful completions. When a specified number of successful completions is reached, the job itself is complete. Deleting a Job will cleanup the pods it created.

Let's start by creating the _job-whalesay.yaml_ manifest using this command

```bash
mkdir  ~/environment/batch_policy/

cat <<EoF > ~/environment/batch_policy/job-whalesay.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: whalesay
spec:
  template:
    spec:
      containers:
      - name: whalesay
        image: docker/whalesay
        command: ["cowsay",  "This is a Kubernetes Job!"]
      restartPolicy: Never
  backoffLimit: 4
EoF
```

Run a sample Kubernetes Job using the `whalesay` image.

```bash
kubectl apply -f job-whalesay.yaml
```

Wait until the job has completed successfully.

```bash
kubectl get job/whalesay
```

{{< output >}}
NAME       DESIRED   SUCCESSFUL   AGE
whalesay   1         1            2m
{{< /output >}}

Confirm the output.

```bash
kubectl logs -l job-name=whalesay
```

{{< output >}}
 ___________________________ 
< This is a Kubernetes Job! >
 --------------------------- 
    \
     \
      \     
                    ##        .            
              ## ## ##       ==            
           ## ## ## ##      ===            
       /""""""""""""""""___/ ===        
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
       \______ o          __/            
        \    \        __/             
          \____\______/   
{{< /output >}}
