---
title: "Secrets Store CSI Driver and ASCP"
date: 2021-10-01T00:00:00-04:00
weight: 10
draft: false
---

### Install CSI drivers
Prepare your cluster by installing Secrets Store CSI Secret driver and AWS Secrets and Configuration Provider (ASCP).

#### Secrets Store CSI Driver:

```bash
helm repo add secrets-store-csi-driver \
  https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts

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
kubectl get daemonsets -n kube-system -l app=csi-secrets-store-provider-aws
kubectl get daemonsets -n kube-system -l app.kubernetes.io/instance=csi-secrets-store
```
  
{{<output>}}
NAME                             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
csi-secrets-store-provider-aws   1         1         1       1            1           kubernetes.io/os=linux   2m34s

NAME                                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
csi-secrets-store-secrets-store-csi-driver   1         1         1       1            1           kubernetes.io/os=linux   2m42s
{{</output>}}


