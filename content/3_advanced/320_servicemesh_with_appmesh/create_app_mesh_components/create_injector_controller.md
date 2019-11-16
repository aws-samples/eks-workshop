---
title: "Creating the Injector Controller"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

To create the injector controller, we'll run a script that creates a namespace, generates certificates, and then installs the injector deployment.

From the base repository directory, change into the injector directory:

```
cd 2_create_injector
```

Next, run the create.sh script:

```
./create.sh
```

Output should look similar to:

```
namespace/appmesh-inject created
creating certs in tmpdir /var/folders/02/qfw6pbm501xbw4scnk20w80h0_xvht/T/tmp.LFO95khQ
Generating RSA private key, 2048 bit long modulus
.........+++
..............................+++
e is 65537 (0x10001)
certificatesigningrequest.certificates.k8s.io/aws-app-mesh-inject.appmesh-inject created
NAME                                 AGE   REQUESTOR          CONDITION
aws-app-mesh-inject.appmesh-inject   0s    kubernetes-admin   Pending
certificatesigningrequest.certificates.k8s.io/aws-app-mesh-inject.appmesh-inject approved
secret/aws-app-mesh-inject created

processing templates
Created injector manifest at:/2_create_injector/inject.yaml

serviceaccount/aws-app-mesh-inject-sa created
clusterrole.rbac.authorization.k8s.io/aws-app-mesh-inject-cr unchanged
clusterrolebinding.rbac.authorization.k8s.io/aws-app-mesh-inject-binding configured
service/aws-app-mesh-inject created
deployment.apps/aws-app-mesh-inject created
mutatingwebhookconfiguration.admissionregistration.k8s.io/aws-app-mesh-inject unchanged

Waiting for pods to come up...

App Inject Pods and Services After Install:

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
aws-app-mesh-inject   ClusterIP   10.100.165.254   <none>        443/TCP   16s
NAME                                   READY   STATUS    RESTARTS   AGE
aws-app-mesh-inject-5d84d8c96f-gc6bl   1/1     Running   0          16s
```

If you're seeing the above output, the injector controller has been installed correctly.
