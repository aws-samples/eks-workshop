---
title: "Installing Sealed Secrets"
date: 2021-07-15T00:00:00-03:00
weight: 13
draft: false
---

#### Installing the kubeseal Client
For Linux x86_64 systems, the client-tool may be installed into /usr/local/bin with the following command:
```
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
For MacOS systems, the client-tool is installed as follows:
```
brew install kubeseal
```

#### Installing the Custom Controller and CRD for SealedSecret
Install the SealedSecret CRD, controller and RBAC artifacts on your EKS cluster as follows:
```
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/controller.yaml
kubectl apply -f controller.yaml
```

Check the status of the controller pod.
```
kubectl get pods -n kube-system | grep sealed-secrets-controller
```
Output:
{{< output >}}
sealed-secrets-controller-7bdbc75d47-5wxvf   1/1     Running   0          60s
{{< /output >}}

The logs printed by the controller reveal the name of the Secret that it created in its namespace, *kube-system*, and which contais the private key pair used by the controller for unsealing SealedSecrets deployed to the cluster. Note that the name of the controller pod will be different in your cluster.
```
kubectl logs sealed-secrets-controller-84fcdcd5fd-9qb5j -n kube-system
```
Output:
{{< output >}}
controller version: 0.17.5
2022/05/22 08:59:30 Starting sealed-secrets controller version: 0.17.5
2022/05/22 08:59:30 Searching for existing private keys
2022/05/22 08:59:35 New key written to kube-system/sealed-secrets-key862hv
2022/05/22 08:59:35 Certificate is 
-----BEGIN CERTIFICATE-----
MIIEzTCCArWgAwIBAgIRANwD+TO7y4nPvBTS80l5ToIwDQYJKoZIhvcNAQELBQAw
ADAeFw0yMjA1MjIwODU5MzVaFw0zMjA1MTkwODU5MzVaMAAwggIiMA0GCSqGSIb3
(…)
GC4KFr8SHcF6u2UyYwhNEXyAVhE9vt6E6Pc6EH5K/aKrmW5tfy12M9gFKFKUsMZk
Z5XdfsBEweI4/PlBNnQWjmlLENy9h6PEtN1Xh+msjQyB
-----END CERTIFICATE-----

2022/05/22 08:59:35 HTTP server serving on :8080
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
    tls.crt: LS0tLS1CRUdJTiBDRVJUSU(...)S0tLQo=
    tls.key: LS0tLS1CRUdJTiBSU0EgUF(...)S0tLS0K
  kind: Secret
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","data":{"tls.crt":"LS0tLS1CRUdJTiBDRVJUSU(...)S0tLS0K"},"kind":"Secret","metadata":{"annotations":{},"creationTimestamp":"2022-05-22T08:59:35Z","generateName":"sealed-secrets-key","labels":{"sealedsecrets.bitnami.com/sealed-secrets-key":"active"},"managedFields":[{"apiVersion":"v1","fieldsType":"FieldsV1","fieldsV1":{"f:data":{".":{},"f:tls.crt":{},"f:tls.key":{}},"f:metadata":{"f:generateName":{},"f:labels":{".":{},"f:sealedsecrets.bitnami.com/sealed-secrets-key":{}}},"f:type":{}},"manager":"Go-http-client","operation":"Update","time":"2022-05-22T08:59:35Z"}],"name":"sealed-secrets-key862hv","namespace":"kube-system","resourceVersion":"1540151","selfLink":"/api/v1/namespaces/kube-system/secrets/sealed-secrets-key862hv","uid":"83d0d7a1-f051-4640-8573-d095300034a4"},"type":"kubernetes.io/tls"}
    creationTimestamp: "2022-05-22T09:11:56Z"
    generateName: sealed-secrets-key
    labels:
      sealedsecrets.bitnami.com/sealed-secrets-key: active
    managedFields:
    - apiVersion: v1
      fieldsType: FieldsV1
      fieldsV1:
        f:data:
          .: {}
          f:tls.crt: {}
          f:tls.key: {}
        f:metadata:
          f:annotations:
            .: {}
            f:kubectl.kubernetes.io/last-applied-configuration: {}
          f:generateName: {}
          f:labels:
            .: {}
            f:sealedsecrets.bitnami.com/sealed-secrets-key: {}
        f:type: {}
      manager: kubectl-client-side-apply
      operation: Update
      time: "2022-05-22T09:11:56Z"
    name: sealed-secrets-key862hv
    namespace: kube-system
    resourceVersion: "1542721"
    selfLink: /api/v1/namespaces/kube-system/secrets/sealed-secrets-key862hv
    uid: 607eb61e-fa44-4230-8532-0a65c3348167
  type: kubernetes.io/tls
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
{{< /output >}}
