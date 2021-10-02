---
title: "Secrets Store CSI Driver and ASCP"
date: 2021-10-01T00:00:00-04:00
weight: 10
pre: '<i class="fa fa-film" aria-hidden="true"></i>'
draft: false
---

### Install CSI drivers
Prepare your cluster by installing Secrets Store CSI Secret driver and AWS Secrets and Configuration Provider (ASCP). The ASCP works with EKS version 1.17 or later.

#### Secrets Store CSI Driver:

```bash
helm repo add secrets-store-csi-driver \
  https://raw.githubusercontent.com/kubernetes-sigs/secrets-store-csi-driver/master/charts

helm install -n kube-system csi-secrets-store \
  --set syncSecret.enabled=true \
  --set enableSecretRotation=true \
  secrets-store-csi-driver/secrets-store-csi-driver
```

#### ASCP: 
```bash
kubectl apply -f https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml
```

#### Verifiy the installation:
Verify that two daemonsets deployed. ```csi-secrets-store-secrets-store-csi-driver``` for standard Secrets Store CSI Driver and ```csi-secrets-store-provider-aws``` for the ASCP that supports provider (AWS) specific options.

```bash
kubectl get daemonsets -n kube-system | grep csi-secrets-store
```
  
{{<output>}}
csi-secrets-store-provider-aws               3         3         3       3            3           kubernetes.io/os=linux        1d
csi-secrets-store-secrets-store-csi-driver   3         3         3       3            3           kubernetes.io/os=linux        1d
{{</output>}}


