---
title: "Creating and Deploying Secrets (cont.)"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

#### Exposing Secrets as Volumes
Secrets can be also mounted as data volumes on to a Pod and you can control the paths within the volume where the Secret keys are projected using a Pod manifest as shown below:
{{< output >}}
apiVersion: v1
kind: Pod
metadata:
  name: someName
  namespace: someNamespace
spec:
  containers:
  - name: someContainer
    image: someImage
    volumeMounts:
    - name: secret-volume
      mountPath: "/etc/data"
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: database-credentials
      items:
      - key: username
        path: DATABASE_USER 
      - key: password
        path: DATABASE_PASSWORD 
{{< /output >}}

With the above configuration, what will happen is:

- value for the *username* key in the **database-credentials** Secret is stored in the file */etc/data/DATABASE_USER* within the Pod
- value for the *password* key is stored in the file */etc/data/DATABASE_PASSWORD*

Run the following set of commands to deploy a pod that mounts the **database-credentials** Secret as a volume.
```
wget https://eksworkshop.com/beginner/200_secrets/secrets.files/pod-volume.yaml
kubectl apply -f pod-volume.yaml
kubectl get pod -n octank
```

View the output logs from the pod to verfiy that the files */etc/data/DATABASE_USER* and */etc/data/DATABASE_PASSWORD* within the Pod have been loaded with the expected literal values
```
kubectl logs pod-volume -n octank
```
The output should look as follows:
{{< output >}}
cat /etc/data/DATABASE_USER
admin
cat /etc/data/DATABASE_PASSWORD
Tru5tN0!
{{< /output >}}
