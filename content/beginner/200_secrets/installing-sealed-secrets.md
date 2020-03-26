---
title: "Installing Sealed Secrets"
date: 2019-04-09T00:00:00-03:00
weight: 13
draft: false
---

#### Installing the kubeseal Client
For Linux x86_64 systems, the client-tool may be installed into /usr/local/bin with the following command:
```
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.10.0/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
For MacOS systems, the client-tool is installed as follows:
```
brew install kubeseal
```

#### Installing the Custom Controller and CRD for SealedSecret
Install the SealedSecret CRD, controller and RBAC artifacts on your EKS cluster as follows:
```
cd ~/environment/secrets
wget https://eksworkshop.com/beginner/200_secrets/secrets.files/controller.yaml
kubectl apply -f controller.yaml
```

Check the status of the controller pod.
```
kubectl get pods -n kube-system | grep sealed-secrets-controller
```
Output:
{{< output >}}
sealed-secrets-controller-7b98b688db-tgx28            1/1     Running   0          41s
{{< /output >}}

The logs printed by the controller reveal the name of the Secret that it created in its namespace, *kube-system*, and which contais the private key pair used by the controller for unsealing SealedSecrets deployed to the cluster. Note that the name of the controller pod will be different in your cluster.
```
kubectl logs sealed-secrets-controller-84fcdcd5fd-9qb5j -n kube-system
```
Output:
{{< output >}}
2020/03/07 22:11:20 Starting sealed-secrets controller version: v0.9.8
2020/03/07 22:11:20 Searching for existing private keys
2020/03/07 22:11:23 New key written to kube-system/sealed-secrets-key8d8z2
2020/03/07 22:11:23 Certificate is 
-----BEGIN CERTIFICATE-----
MIIErTCCApWgAwIBAgIQJsQQhEXabaLWTUIzkH+EeDANBgkqhkiG9w0BAQsFADAA
MB4XDTIwMDMwNzIyMTEyM1oXDTMwMDMwNTIyMTEyM1owADCCAiIwDQYJKoZIhvcN
. . . . .
Se0Lk6ZACjiFqNMdL/VkSG2pYkjdFg64KZzDLad7lBrB3tOtCW8xG5T8jZuzDewB
65pXxa+MvFjnfukUE3LfC1xM17pPjRQmJ5YgcQCXsTorFXHIw21t3mF6EZfuZgpJ
XA==
-----END CERTIFICATE-----

2020/03/07 22:11:23 HTTP server serving on :8080
{{< /output >}}

As seen from the logs of the controller, it searches for a Secret with the label *sealedsecrets.bitnami.com/sealed-secrets-key* in its namespace. If it does not find one, it creates a new one in its namespace and prints the public key portion of the key pair to its output logs. View the contents of the Secret which contais the public/private key pair in YAML format as follows:
```
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml
```
Output:
{{< output >}}
apiVersion: v1
items:
- apiVersion: v1
  data:
    tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0 . . .
    tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVk . . .
  kind: Secret
  metadata:
    creationTimestamp: "2020-03-07T04:30:37Z"
    generateName: sealed-secrets-key
    labels:
      sealedsecrets.bitnami.com/sealed-secrets-key: active
    name: sealed-secrets-keyvk4pr
    namespace: kube-system
    resourceVersion: "6256711"
    selfLink: /api/v1/namespaces/kube-system/secrets/sealed-secrets-keyvk4pr
    uid: 65141347-602c-11ea-bdba-12239483f525
  type: kubernetes.io/tls
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
{{< /output >}}
