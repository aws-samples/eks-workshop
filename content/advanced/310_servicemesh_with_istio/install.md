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
NAME                     TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                                                                                                                      AGE
grafana                  ClusterIP      10.100.211.214   <none>                                                                    3000/TCP                                                                                                                     163m
istio-citadel            ClusterIP      10.100.175.197   <none>                                                                    8060/TCP,15014/TCP                                                                                                           163m
istio-egressgateway      ClusterIP      10.100.243.11    <none>                                                                    80/TCP,443/TCP,15443/TCP                                                                                                     163m
istio-galley             ClusterIP      10.100.110.146   <none>                                                                    443/TCP,15014/TCP,9901/TCP,15019/TCP                                                                                         163m
istio-ingressgateway     LoadBalancer   10.100.241.197   af5f556e355ac11ea8cdb0ab545e9ca9-1255771424.us-west-2.elb.amazonaws.com   15020:31116/TCP,80:31055/TCP,443:31688/TCP,15029:31779/TCP,15030:31477/TCP,15031:30536/TCP,15032:31177/TCP,15443:31221/TCP   163m
istio-pilot              ClusterIP      10.100.207.164   <none>                                                                    15010/TCP,15011/TCP,8080/TCP,15014/TCP                                                                                       163m
istio-policy             ClusterIP      10.100.133.25    <none>                                                                    9091/TCP,15004/TCP,15014/TCP                                                                                                 163m
istio-sidecar-injector   ClusterIP      10.100.241.234   <none>                                                                    443/TCP                                                                                                                      163m
istio-telemetry          ClusterIP      10.100.156.136   <none>                                                                    9091/TCP,15004/TCP,15014/TCP,42422/TCP                                                                                       163m
jaeger-agent             ClusterIP      None             <none>                                                                    5775/UDP,6831/UDP,6832/UDP                                                                                                   163m
jaeger-collector         ClusterIP      10.100.114.107   <none>                                                                    14267/TCP,14268/TCP,14250/TCP                                                                                                163m
jaeger-query             ClusterIP      10.100.51.130    <none>                                                                    16686/TCP                                                                                                                    163m
kiali                    ClusterIP      10.100.69.167    <none>                                                                    20001/TCP                                                                                                                    163m
prometheus               ClusterIP      10.100.3.219     <none>                                                                    9090/TCP                                                                                                                     163m
tracing                  ClusterIP      10.100.14.49     <none>                                                                    80/TCP                                                                                                                       163m
zipkin                   ClusterIP      10.100.12.61     <none>                                                                    9411/TCP                                                                                                                     163m

{{< /output >}}

and check the corresponding pods with

```bash
kubectl -n istio-system get pods
```

{{< output >}}
NAME                                      READY   STATUS    RESTARTS   AGE
grafana-5f798469fd-vld8w                  1/1     Running   0          167m
istio-citadel-58bb67f9b8-kphhw            1/1     Running   0          167m
istio-egressgateway-6fd57475b5-xbjhk      1/1     Running   0          167m
istio-galley-7d4b9874c8-jczmj             1/1     Running   0          167m
istio-ingressgateway-7d65bf7fdf-94xhw     1/1     Running   0          167m
istio-pilot-65f8557545-lgr7m              1/1     Running   0          167m
istio-policy-6c6449c56f-5m7vl             1/1     Running   2          167m
istio-sidecar-injector-774969d686-8s9qd   1/1     Running   0          167m
istio-telemetry-585cc965f7-ltqll          1/1     Running   3          167m
istio-tracing-cd67ddf8-swkm5              1/1     Running   0          167m
kiali-7964898d8c-z4lqj                    1/1     Running   0          167m
prometheus-586d4445c7-5jj59               1/1     Running   0          167m
{{< /output >}}
