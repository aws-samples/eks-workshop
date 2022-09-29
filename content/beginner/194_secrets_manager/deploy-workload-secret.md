---
title: "Deploy pods with mounted secrets"
date: 2021-10-21T00:00:00-04:00
weight: 30
draft: false
---

#### Create SecretProviderClass
Create SecretProviderClass custom resource with ```provider:aws``` . The SecretProviderClass must be in the same namespace as the pod using it later.

```bash
cat << EOF > nginx-deployment-spc.yaml
---
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: nginx-deployment-spc
spec:
  provider: aws
  parameters:
    objects: |
        - objectName: "DBSecret_eksworkshop"
          objectType: "secretsmanager"
EOF
```

Create custom resource.
```bash
kubectl apply -f nginx-deployment-spc.yaml

kubectl get SecretProviderClass
```

The output indicates the resource created successfully.
{{<output>}}
NAME                   AGE
nginx-deployment-spc   18s
{{</output>}}



#### Create pod and mount secrets

Configure a pod to mount volumes based on the SecretProviderClass ```nginx-deployment-spc``` created earlier and to retrieve secrets from the AWS Secrets Manager. The pod is also using a service account ```nginx-deployment-sa``` bound to the IAM role. 

```bash
cat << EOF > nginx-deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      serviceAccountName: nginx-deployment-sa
      containers:
      - name: nginx-deployment
        image: nginx
        ports:
        - containerPort: 80
        volumeMounts:
        - name: secrets-store-inline
          mountPath: "/mnt/secrets"
          readOnly: true
      volumes:
      - name: secrets-store-inline
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: nginx-deployment-spc
EOF
```

Create the deployment and verify the creation of pods.
```bash
kubectl apply -f nginx-deployment.yaml
sleep 5
kubectl get pods -l "app=nginx"
```
{{<output>}}
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-75bfbbcf99-ws4ts   1/1     Running   0          10s
{{</output>}}


#### Verify the mounted secret

Finally, verify the secret mounted as a file by executing the command within the pod.

```bash
export POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[].metadata.name}')
kubectl exec -it ${POD_NAME} -- cat /mnt/secrets/DBSecret_eksworkshop; echo
```

{{<output>}}
{"username":"foo", "password":"super-sekret"}
{{</output>}}

The successful output shows the secret fetched from the Secrets Store and stored as the local file named ```/mnt/secrets/DBSecret_eksworkshop```. It is now available to the pod application. 

Notice value of the JSON formatted secret is available as a single string in the file. What if you would like to fetch individual values from the keys of JSON formatted secret and make it available as Kubernetes native secret object. Proceed to the next section for such results.

