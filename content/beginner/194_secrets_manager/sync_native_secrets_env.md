---
title: "Sync with native Kubernetes secrets"
date: 2021-10-01T00:00:00-04:00
weight: 40
draft: false
---

This section covers the following use cases.

1. Fetch values from the individual keys of the JSON formatted secrets and mount them as separate files.
2. Sync secrets from the mounted volumes to native Kubernetes secrets object. 
3. Use Kubernetes standard feature to set up environment variables from the Kubernetes secrets.

#### Create SecretProviderClass to extract key-value pairs

Let's create a SecretProviderClass custom resource and use ```jmesPath``` field in the spec file. Use of [jmesPath](https://jmespath.org/) allows extracting specific key-value from a JSON-formatted secret. It is a provider-specific feature from [ASCP](https://github.com/aws/secrets-store-csi-driver-provider-aws).

```secretObjects``` spec section allows specifying the Kubernetes native secret structure synced from the *objects:* extracted from the JSON formatted secret using ```jmesPath```. The feature is provided by the standard [Secret Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret.html).


```bash
cat << EOF > nginx-deployment-spc-k8s-secrets.yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: nginx-deployment-spc-k8s-secrets
spec:
  provider: aws
  parameters: 
    objects: |
      - objectName: "DBSecret_eksworkshop"
        objectType: "secretsmanager"
        jmesPath:
          - path: username
            objectAlias: dbusername
          - path: password
            objectAlias: dbpassword
  # Create k8s secret. It requires volume mount first in the pod and then sync.
  secretObjects:                
    - secretName: my-secret-01
      type: Opaque
      data:
        #- objectName: <objectName> or <objectAlias> 
        - objectName: dbusername
          key: db_username_01
        - objectName: dbpassword
          key: db_password_01
EOF
```

Create custom resource.
```bash
kubectl apply -f nginx-deployment-spc-k8s-secrets.yaml

kubectl get SecretProviderClass nginx-deployment-spc-k8s-secrets
```

The output indicates the resource ```nginx-deployment-spc-k8s-secrets``` created successfully.
{{<output>}}
NAME                               AGE
nginx-deployment-spc-k8s-secrets   10s
{{</output>}}


#### Create pod mount secrets volumes and set up Environment variables. 

Configure a pod to mount volumes for individually extracted key-value pairs from the secrets. Once the pod is created with secrets volume mounts, the Secrets Store CSI Driver then creates and syncs Kubernetes secret object ```my-secret-01```. The pod then be able to populate Environment variables from the Kubernetes secret.

```bash
cat << EOF > nginx-deployment-k8s-secrets.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment-k8s-secrets
  labels:
    app: nginx-k8s-secrets
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-k8s-secrets
  template:
    metadata:
      labels:
        app: nginx-k8s-secrets
    spec:
      serviceAccountName: nginx-deployment-sa
      containers:
      - name: nginx-deployment-k8s-secrets
        image: nginx
        imagePullPolicy: IfNotPresent
        ports:
          - containerPort: 80
        volumeMounts:
          - name: secrets-store-inline
            mountPath: "/mnt/secrets"
            readOnly: true
        env:
          - name: DB_USERNAME_01
            valueFrom:
              secretKeyRef:
                name: my-secret-01
                key: db_username_01
          - name: DB_PASSWORD_01
            valueFrom:
              secretKeyRef:
                name: my-secret-01
                key: db_password_01
      volumes:
        - name: secrets-store-inline
          csi:
            driver: secrets-store.csi.k8s.io
            readOnly: true
            volumeAttributes:
              secretProviderClass: nginx-deployment-spc-k8s-secrets
EOF
```

Create the deployment and verify the creation of pods.
```bash
kubectl apply -f nginx-deployment-k8s-secrets.yaml
sleep 2
kubectl get pods -l "app=nginx-k8s-secrets"
```

#### Verify the result

Get a shell prompt within the pod by running the following commands. Verify the secret mounted as separate files for each extracted key-value pair and corresponding environment variables set as well.

```bash
export POD_NAME=$(kubectl get pods -l app=nginx-k8s-secrets -o jsonpath='{.items[].metadata.name}')
kubectl exec -it ${POD_NAME} -- /bin/bash
```

Wait for the ```root``` shell prompt within the pod. Run the following set of commands and watch the output in the pod's shell. 

```bash
export PS1='# '
cd /mnt/secrets
ls -l   #--- List mounted secrets

cat dbusername; echo  
cat dbpassword; echo
cat DBSecret_eksworkshop; echo

env | grep DB    #-- Display two ENV variables set from the secret values
sleep 2
exit

```
The output shows the information as displayed here. The last ```exit``` command in the shell window exits from the pod's shell.

{{<output>}}
# cd /mnt/secrets
# ls -l   #--- List mounted secrets
total 12
-rw-r--r-- 1 root root 45 Nov 22 01:56 DBSecret_eksworkshop
-rw-r--r-- 1 root root 12 Nov 22 01:56 dbpassword
-rw-r--r-- 1 root root  3 Nov 22 01:56 dbusername
# 
# cat dbusername; echo  
foo
# cat dbpassword; echo
super-sekret
# cat DBSecret_eksworkshop; echo
{"username":"foo", "password":"super-sekret"}
# 
# env | grep DB    #-- Display two ENV variables set from the secret values
DB_USERNAME_01=foo
DB_PASSWORD_01=super-sekret
# sleep 2

# exit
exit
{{</output>}}

Notice under the path ```/mnt/secrets``` key-values pairs extracted in separate files based on *jmesPath* specification. Files ```dbusername``` and ```dbpassword``` contains extracted values from the JSON formatted secret ```DBSecret_eksworkshop```

Two Environment variables ```DB_USERNAME_01``` and ```DB_PASSWORD_01``` are set up respectively. These ENV vars mapped from the Kubernetes secrets object ```my-secret-01``` created automatically by the CSI driver.

Confirm the presence of Kubernetes secrets. It was created automatically by the CSI driver during pod deployment.
```bash
kubectl describe secrets my-secret-01
```

{{<output>}}
NAME           TYPE     DATA   AGE
my-secret-01   Opaque   2      14m
meharwal@147dda3bc928 tmp % kubectl describe secrets my-secret-01
Name:         my-secret-01
Namespace:    default
Labels:       secrets-store.csi.k8s.io/managed=true
Annotations:  <none>

Type:  Opaque

Data
====
db_password_01:  12 bytes
db_username_01:  3 bytes
{{</output>}}
