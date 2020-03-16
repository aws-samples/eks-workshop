---
title: "Creating and Deploying Secrets"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---

Since 1.14, Kubectl supports the management of Kubernetes objects using Kustomize. [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#overview-of-kustomize) provides resource Generators to create Secrets and ConfigMaps. The Kustomize generators should be specified in a **kustomization.yaml** file. A Kustomize file for generating a Secret from literal key-value pairs looks as follows:
{{< output >}}
namespace: octank
secretGenerator:
- name: database-credentials
  literals:
  - username=admin
  - password=Tru5tN0!
generatorOptions:
  disableNameSuffixHash: true
{{< /output >}}

Run the following set of commands to generate a Secret using Kubectl and Kustomize.
```
mkdir -p ~/environment/secrets
cd ~/environment/secrets
wget https://eksworkshop.com/beginner/200_secrets/secrets.files/kustomization.yaml
kubectl kustomize . > secret.yaml
```

The generated Secret with base64 encoded value for *username* and *password* keys is as follows:
{{< output >}}
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: database-credentials
  namespace: octank
data:
  password: VHJ1NXROMCE=
  username: YWRtaW4=
{{< /output >}}


You can now deploy this Secret to your EKS cluster.
```
kubectl create namespace octank
kubectl apply -f secret.yaml
```

#### Exposing Secrets as Environment Variables
You may expose the keys, namely, *username* and *password*, in the **database-credentials** Secret to a Pod as environment variables using a Pod manifest as shown below:
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
    env:
    - name: DATABASE_USER
      valueFrom:
        secretKeyRef:
          name: database-credentials
          key: username
    - name: DATABASE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: database-credentials
          key: password 
{{< /output >}}

Run the following set of commands to deploy a pod that references the **database-credentials** Secret created above.
```
wget https://eksworkshop.com/beginner/200_secrets/secrets.files/pod-variable.yaml
kubectl apply -f pod-variable.yaml
kubectl get pod -n octank
```

View the output logs from the pod to verfiy that the environment variables *DATABASE_USER* and *DATABASE_PASSWORD* have been assigned the expected literal values
```
kubectl logs pod-variable -n octank
```
The output should look as follows:
{{< output >}}
DATABASE_USER = admin
DATABASE_PASSWROD = Tru5tN0!
{{< /output >}}
