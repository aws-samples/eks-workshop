---
title: "Installing Sealed Secrets"
date: 2021-07-15T00:00:00-03:00
weight: 13
draft: false
---

#### Installing the kubeseal Client
For Linux x86_64 systems, the client-tool may be installed into /usr/local/bin with the following command:
```
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/kubeseal-0.18.0-linux-amd64.tar.gz
tar xfz kubeseal-0.18.0-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```
For MacOS systems, the client-tool is installed as follows:
```
brew install kubeseal
```

#### Installing the Custom Controller and CRD for SealedSecret
Install the SealedSecret CRD, controller and RBAC artifacts on your EKS cluster as follows:
```
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.18.0/controller.yaml
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
controller version: v0.16.0
2021/07/14 21:26:59 Starting sealed-secrets controller version: v0.16.0
2021/07/14 21:26:59 Searching for existing private keys
2021/07/14 21:27:01 New key written to kube-system/sealed-secrets-keydw62x
2021/07/14 21:27:01 Certificate is
-----BEGIN CERTIFICATE-----
MIIErTCCApWgAwIBAgIQR5dpRFfh++CnGZuOc5bfGjANBgkqhkiG9w0BAQsFADAA
MB4XDTIxMDcxNDIxMjcwMVoXDTMxMDcxMjIxMjcwMVowADCCAiIwDQYJKoZIhvcN
(...)
vqXZrlmfM7ScQRMSnD5QiqaT3I2F2vpZgTyCvto8rcG62lmUAhKqPXqopBRJx+Of
K4MhPVDg6t0YdZFYH6+oKW7OGLR2rp4KBoIYfO/KPZMCYVayNiGPQT6kAr2C/pFu
Lg==
-----END CERTIFICATE-----

2021/07/14 21:27:01 HTTP server serving on :8080
{{< /output >}}

As seen from the logs of the controller, it searches for a Secret with the label *sealedsecrets.bitnami.com/sealed-secrets-key* in its namespace. If it does not find one, it creates a new one in its namespace and prints the public key portion of the key pair to its output logs. View the contents of the Secret which contais the public/private key pair in YAML format as follows:
```
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o yaml
```
Output:
{{< output >}}
apiVersion: v1
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
items:
- apiVersion: v1
  kind: Secret
  type: kubernetes.io/tls
  metadata:
    creationTimestamp: "2021-07-14T21:27:01Z"
    generateName: sealed-secrets-key
    labels:
      sealedsecrets.bitnami.com/sealed-secrets-key: active
    name: sealed-secrets-keydw62x
    namespace: kube-system
    resourceVersion: "1968"
    uid: 65cb8421-3b2b-4e64-9499-1e61536bdbc4
  data:
    tls.crt: LS0tLS1CRUdJTiBDRVJUSU(...)S0tCg==
    tls.key: LS0tLS1CRUdJTiBSU0EgUF(...)S0tLS0K
{{< /output >}}
