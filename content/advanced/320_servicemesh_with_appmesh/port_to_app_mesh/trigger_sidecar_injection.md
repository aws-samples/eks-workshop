---
title: "Sidecar Injection"
date: 2018-08-07T08:30:11-07:00
weight: 70
---

Recall that to join the mesh, each pod will need an Envoy proxy sidecar container. We have enabled automatic sidecar injection on the `prod` namespace, but this was done after initial pod creation. Currently, your pods each have one container running.

```bash
kubectl get pods -n prod
```

{{< output >}}
NAME                        READY   STATUS    RESTARTS   AGE
NAME                        READY   STATUS    RESTARTS   AGE
dj-6bf5fb7f45-qkhv7         1/1     Running   0          7m21s
jazz-v1-6f688dcbf9-djb9h    1/1     Running   0          7m21s
metal-v1-566756fbd6-8k2rs   1/1     Running   0          7m21s
{{< /output >}}

To inject sidecar proxies for these pods, simply restart the deployments. The controller will handle the rest.

```bash
kubectl -n prod rollout restart deployment dj jazz-v1 metal-v1
```

{{< output >}}
deployment.apps/dj restarted
deployment.apps/jazz-v1 restarted
deployment.apps/metal-v1 restarted
{{< /output >}}

You should now see 2 containers in each pod. It might take a few seconds for the new configuration to settle.

```bash
kubectl -n prod get pods
```

{{< output >}}
NAME                       READY   STATUS    RESTARTS   AGE
dj-6544487b5f-7glpg        2/2     Running   0          14s
jazz-v1-9bfb9b78c-qjmvj    2/2     Running   0          14s
metal-v1-9f78fb8c8-67mqc   2/2     Running   0          14s
{{< /output >}}

Now you can see that 2 containers are running in each pod, verify that they are the application service and the Envoy proxy. Examine the pod and confirm these are the containers running within it.

```bash
kubectl -n prod get pods dj-6544487b5f-7glpg -o jsonpath='{.spec.containers[*].name}'
```

{{< output >}}
dj envoy
{{< /output >}}

Here you see both the application service as well as the sidecar proxy container. Any new pods created in this namespace will have the proxy injected automatically.

