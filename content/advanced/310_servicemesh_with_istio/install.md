---
title: "Install Istio"
date: 2019-03-20T13:36:55+01:00
weight: 30
draft: false
---

We will install all the Istio components using the built-in demo configuration profile. This installation lets you quickly get started evaluating Istio.

{{% notice info %}}
The demo configuration profile is not suitable for performance evaluation. It is designed to showcase Istio functionality with high levels of tracing and access logging.
For more information about Istio profile, [click here](https://istio.io/docs/setup/additional-setup/config-profiles/).
{{% /notice %}}

Istio will be installed in the `istio-system` namespace.

```bash
yes | istioctl install --set profile=demo
```

{{< output >}}
✔ Istio core installed
✔ Istiod installed
✔ Egress gateways installed
✔ Ingress gateways installed
✔ Installation complete
{{< /output >}}

We can verify all the services have been installed.

```bash
kubectl -n istio-system get svc
```

The output should look like this

{{< output >}}
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP      10.100.167.140   <none>                                                                    80/TCP,443/TCP,15443/TCP                                                     107s
istio-ingressgateway   LoadBalancer   10.100.15.31     abc1fcfe168bb4d9e8264e8952758806-1033162489.us-east-2.elb.amazonaws.com   15021:30819/TCP,80:30708/TCP,443:32447/TCP,31400:31433/TCP,15443:30201/TCP   107s
istiod                 ClusterIP      10.100.133.178   <none>                                                                    15010/TCP,15012/TCP,443/TCP,15014/TCP                                        117s
{{< /output >}}

and check the corresponding pods with

```bash
kubectl -n istio-system get pods
```

{{< output >}}
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-cd6b59579-vlv6c     1/1     Running   0          2m35s
istio-ingressgateway-78f7794d66-9jbw5   1/1     Running   0          2m35s
istiod-574485bfdc-wtjcg                 1/1     Running   0          2m45s
{{< /output >}}
