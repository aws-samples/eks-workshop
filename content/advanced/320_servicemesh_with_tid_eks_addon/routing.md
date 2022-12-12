---
title: "Traffic Management"
date: 2018-11-13T21:49:32+09:00
weight: 40
draft: false
---

### Traffic shifting - based on header

This exercise is built and extended based on the documentation of tetratelabs.io [Zero-Downtime Releases](https://tetratelabs.io/istio-in-practice/zero-downtime-releases)

After creating and configuring all objects the diagram will look like this.

![Alt text](/images/tetrate-istio-distro/traffic_shifting.png "Traffic shifting logical diagram")

Lets list what exactly is achieved here:

- Traffic will arrive on AWS Classic LoadBalancer
- the call will be forwarded to `tid-ingressgateway-gw` pod, created in previous step
- the traffic will be accepted per `Istio Gateway` manifest
- based on hostname `helloworld.tetrate.io` and presence of the header `blue-version: on` the decision will be made:
    - no header will be send to `v1` of `helloworld` application in `green` namespace
    - calls with `blue-version: on` header present will be forwarded to `v2` of `helloworld` application in `blue` namespace

As first step we will deploy two versions of `helloworld` sample application instances per below console commands:

```sh
# create namespaces for each version 
kubectl create namespace green
kubectl create namespace blue

# enable istio-injection for each namespace
kubectl label namespace green \
    istio-injection=enabled
kubectl label namespace blue \
    istio-injection=enabled

# deploy application from upstream
kubectl apply \
    -f https://raw.githubusercontent.com/istio/istio/release-1.15/samples/helloworld/helloworld.yaml \
    -l version=v1 -n green

kubectl apply \
    -f https://raw.githubusercontent.com/istio/istio/release-1.15/samples/helloworld/helloworld.yaml \
    -l version=v2 -n blue

# also add service objects for each version
kubectl apply \
    -f https://raw.githubusercontent.com/istio/istio/release-1.15/samples/helloworld/helloworld.yaml \
    -l service=helloworld -n green

kubectl apply \
    -f https://raw.githubusercontent.com/istio/istio/release-1.15/samples/helloworld/helloworld.yaml \
    -l service=helloworld -n blue
```

The next step is to create GW manifest definition:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: tid-helloworld
  namespace: tid-ingress-ns
spec:
  selector:
    istio: tid-ingress-gw # selector needs to match one defined in previous step for Istio Gateway deployment
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - helloworld.tetrate.io # this domain is not registered in public DNS and header needs to be supplied
```

Below is simplified version of Virtual Service created from [more advanced example](https://tetratelabs.io/istio-in-practice/zero-downtime-releases). This definition specifies where traffic will be directed:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
    name: helloworld-service
    namespace: tid-ingress-ns # namespace where GW was created in previous step
spec:
    gateways:
      - tid-helloworld
    hosts:
      - helloworld.tetrate.io
    http:
      - match:
        - headers:
            blue-version:  # if the request has "blue-version: on" header - requests will go to v2
              regex: '.*on.*'
        route:
          - destination:
              host: helloworld.blue.svc.cluster.local
      - route: # requests without additional header will go to v1
          - destination:
              host: helloworld.green.svc.cluster.local
```

To confirm the desired behavior is implemented.

- obtain the AWS LB FQDN and store in variable

    ```bash
    ADDR=$(kubectl -n tid-ingress-ns get service tid-ingressgateway -o=jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")
    ```

    you can confirm that address is obtained by displaying the variable

  {{< output >}}$ ADDR=$(kubectl -n tid-ingress-ns get service tid-ingressgateway -o=jsonpath="{.status.loadBalancer.ingress[0]['hostname','ip']}")
$ echo $ADDR
ad33d7b9ed818419ea6a8d8b6d710742-1404212739.ap-northeast-2.elb.amazonaws.com{{</ output >}}
- confirm that the blue header works and requests land on __blue__ `helloworld-v2` instance:
{{< output >}}$ curl $ADDR/hello -H "Host: helloworld.tetrate.io" -H "blue-version: on" 
Hello version: v2, instance: helloworld-v2-79bf565586-p6zph
{{</ output >}}
- confirm that traffic without extra headed will go to __green__ `helloworld-v1` instances:
{{< output >}}$ curl $ADDR/hello -H "Host: helloworld.tetrate.io" 
Hello version: v1, instance: helloworld-v1-77cb56d4b4-vzpj6
{{</ output >}}

This example demonstrates a very flexible way to manage traffic based on the specific requirements.
