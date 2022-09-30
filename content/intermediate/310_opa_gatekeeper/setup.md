---
title: "OPA Gatekeeper setup in EKS"
weight: 15
draft: false
---

In this section, we will setup `OPA Gatekeeper` within the cluster.

#### 1. Deploy OPA Gatekeeper using Prebuilt docker images
```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.8/deploy/gatekeeper.yaml
```

#### 2. Check the pods in gatekeeper-system namespace
```bash
kubectl get pods -n gatekeeper-system
```

The output will be similar to:

```bash
NAME                                             READY   STATUS    RESTARTS   AGE
gatekeeper-audit-5bc9b59c57-9d9hc                1/1     Running   0          25s
gatekeeper-controller-manager-744cdc8556-hxf2n   1/1     Running   0          25s
gatekeeper-controller-manager-744cdc8556-jn42m   1/1     Running   0          25s
gatekeeper-controller-manager-744cdc8556-wwrb6   1/1     Running   0          25s
```

#### 3. Observe OPA Gatekeeper Component logs once operational

You can follow the OPA logs to see the webhook requests being issued by the Kubernetes API server:
```bash
kubectl logs -l control-plane=audit-controller -n gatekeeper-system
kubectl logs -l control-plane=controller-manager -n gatekeeper-system
```

This completes the OPA Gatekeeper setup on Amazon EKS cluster. To order to define and enforce the policy, OPA Gatekeeper uses a framework [OPA Constraint Framework](https://github.com/open-policy-agent/frameworks/tree/master/constraint)
