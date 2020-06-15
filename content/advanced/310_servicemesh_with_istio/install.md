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
istioctl manifest apply --set profile=demo
```

We can verify all the services have been installed.

```bash
kubectl -n istio-system get svc
```

The output should look like this

{{< output >}}
NAME                        TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)                                                                                                                                      AGE
grafana                     ClusterIP      10.100.183.102   <none>                                                                   3000/TCP                                                                                                                                     58m
istio-egressgateway         ClusterIP      10.100.179.248   <none>                                                                   80/TCP,443/TCP,15443/TCP                                                                                                                     58m
istio-ingressgateway        LoadBalancer   10.100.138.139   a9c79b62563f411ea82170a0c9607b74-524971824.us-east-2.elb.amazonaws.com   15020:31905/TCP,80:32464/TCP,443:30729/TCP,15029:32747/TCP,15030:31321/TCP,15031:32649/TCP,15032:32041/TCP,31400:31660/TCP,15443:31055/TCP   58m
istio-pilot                 ClusterIP      10.100.227.105   <none>                                                                   15010/TCP,15011/TCP,15012/TCP,8080/TCP,15014/TCP,443/TCP                                                                                     58m
istiod                      ClusterIP      10.100.89.14     <none>                                                                   15012/TCP,443/TCP                                                                                                                            58m
jaeger-agent                ClusterIP      None             <none>                                                                   5775/UDP,6831/UDP,6832/UDP                                                                                                                   58m
jaeger-collector            ClusterIP      10.100.158.185   <none>                                                                   14267/TCP,14268/TCP,14250/TCP                                                                                                                58m
jaeger-collector-headless   ClusterIP      None             <none>                                                                   14250/TCP                                                                                                                                    58m
jaeger-query                ClusterIP      10.100.21.18     <none>                                                                   16686/TCP                                                                                                                                    58m
kiali                       ClusterIP      10.100.29.228    <none>                                                                   20001/TCP                                                                                                                                    58m
prometheus                  ClusterIP      10.100.226.30    <none>                                                                   9090/TCP                                                                                                                                     58m
tracing                     ClusterIP      10.100.24.83     <none>                                                                   80/TCP                                                                                                                                       58m
zipkin                      ClusterIP      10.100.247.224   <none>                                                                   9411/TCP                                                                                                                                     58m

{{< /output >}}

and check the corresponding pods with

```bash
kubectl -n istio-system get pods
```

{{< output >}}
NAME                                    READY   STATUS    RESTARTS   AGE
grafana-556b649566-2gb5d                1/1     Running   0          59m
istio-egressgateway-65949b978b-vbmg4    1/1     Running   0          59m
istio-ingressgateway-7c76987989-2g9vn   1/1     Running   0          59m
istio-tracing-7cf5f46848-s5pcb          1/1     Running   0          59m
istiod-5bb7dddbd8-n84hc                 1/1     Running   0          59m
kiali-6d54b8ccbc-v8zgb                  1/1     Running   0          59m
prometheus-b47d8c58c-bvmr5              2/2     Running   0          59m
{{< /output >}}
