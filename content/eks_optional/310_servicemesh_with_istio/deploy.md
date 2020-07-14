---
title: "Deploy Sample Apps"
date: 2018-11-13T16:37:17+09:00
weight: 40
draft: false
---

## The Envoy Sidecar

As mentioned during the Istio architecture overview, in order to take advantage of all of Istio’s features pods must be running an Istio sidecar proxy.

Istio offers two ways injecting the Istio sidecar into a pod:

* **Manually** using the `istioctl` command.

  Manual injection directly modifies configuration, like deployments, and injects the proxy configuration into it.

* **Automatically** using the Istio sidecar injector.

    You will still need to manually enable Istio in each namespace that you want to be managed by Istio.

{{% notice note %}}
We will install the Bookinfo application inside its own namespace and allow Istio to automatically inject the Sidecar Proxy.
{{% /notice %}}

```bash
kubectl create namespace bookinfo
kubectl label namespace bookinfo istio-injection=enabled

 kubectl get ns bookinfo --show-labels
```

Now, we can deploy a vanilla definition of the Bookinfo application inside the its own namespace, and the Mutating Webhook will alter the definition of any pod it sees to include the Envoy sidecar container.

## Architecture of the Bookinfo application

![Sample Apps](/images/istio/istio_bookinfo_architecture.png)

The `Bookinfo` application is broken into four separate microservices:

* <span style="color:orange">**productpage**</span>
  * The productpage microservice calls the details and reviews microservices to populate the page.

* <span style="color:orange">**details**</span>
  * The details microservice contains book information.

* <span style="color:orange">**reviews**</span>
  * The reviews microservice contains book reviews. It also calls the ratings microservice.

* <span style="color:orange">**ratings**</span>
  * The ratings microservice contains book ranking information that accompanies a book review.

There are 3 versions of the <span style="color:orange">*reviews*</span> microservice:

* Version v1
  * doesn’t call the ratings service.

* Version v2
  * calls the ratings service, and displays each rating as 1 to 5 <span style="color:black">**black stars**</span>.

* Version v3
  * calls the ratings service, and displays each rating as 1 to 5 <span style="color:red">**red stars**</span>.

## Deploy the Sample Apps

Now we will deploy the Bookinfo application to review key capabilities of `Istio` such as intelligent routing, and review telemetry data using `Prometheus` and `Grafana`.

```bash
kubectl -n bookinfo apply \
  -f ${HOME}/environment/istio-${ISTIO_VERSION}/samples/bookinfo/platform/kube/bookinfo.yaml
```

Let's verify the deployment

```bash
kubectl -n bookinfo get pod,svc
```

{{< output >}}
NAME                                 READY   STATUS    RESTARTS   AGE
pod/details-v1-c5b5f496d-p24pr       2/2     Running   0          15s
pod/productpage-v1-c7765c886-6gt9c   2/2     Running   0          15s
pod/ratings-v1-f745cf57b-jkhfn       2/2     Running   0          15s
pod/reviews-v1-75b979578c-g6jct      2/2     Running   0          15s
pod/reviews-v2-597bf96c8f-x2nnb      2/2     Running   0          15s
pod/reviews-v3-54c6c64795-m544j      2/2     Running   0          15s

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/details       ClusterIP   10.100.180.109   <none>        9080/TCP   15s
service/productpage   ClusterIP   10.100.80.194    <none>        9080/TCP   15s
service/ratings       ClusterIP   10.100.158.101   <none>        9080/TCP   15s
service/reviews       ClusterIP   10.100.12.229    <none>        9080/TCP   15s
{{< /output >}}

## Create an Istio Gateway

Now that the Bookinfo services are up and running, you need to make the application accessible from outside of your Kubernetes cluster, e.g., from a browser. An [Istio Gateway](https://istio.io/docs/concepts/traffic-management/#gateways) is used for this purpose.

We'll define the virtual service and ingress gateway.

```bash
kubectl -n bookinfo \
 apply -f ${HOME}/environment/istio-${ISTIO_VERSION}/samples/bookinfo/networking/bookinfo-gateway.yaml
```

{{% notice warning %}}
This may take a minute or two, first for the Ingress to be created, and secondly for the Ingress to hook up with the services it exposes.
{{% /notice %}}

To verify that the application is reachable, run the command below, click on the link and choose open.

```bash
export GATEWAY_URL=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "http://${GATEWAY_URL}/productpage"
```

![Bookinfo](/images/istio/istio_bookinfo_1.png)

{{% notice note %}}
Click reload multiple times to see how the layout and content of the reviews changes as different versions (v1, v2, v3) of the app are called.
{{% /notice %}}
