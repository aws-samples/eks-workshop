---
title: "Deploy Sample Apps"
date: 2018-11-13T16:37:17+09:00
weight: 40
draft: true
---

### Sample Apps

![Sample Apps](/images/servicemesh-deploy1.png)

The Bookinfo application is broken into four separate microservices:

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

---

### Deploy Sample Apps

Deploy sample apps by manually injecting istio proxy and confirm pods, services are running correctly

```
kubectl apply -f <(istioctl kube-inject -f samples/bookinfo/platform/kube/bookinfo.yaml)

kubectl get pod

kubectl get svc
```

Define virtualservice, ingressgateway and find out ELB endpoint to get connected from your browser.

This may take a minute or two, first for the Ingress to be created, and secondly for the Ingress to hook up with the services it exposes. `wait and wait`

```
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

kubectl get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' -n istio-system 
```

Open a browser and connect to the endpoint that you get from istio-ingressgateway to see whether sample app is working.

{{% notice info %}}
You have to add **/productpage** at the end of the URI in the browser to see the sample webpage
{{% /notice %}}

![Sample Apps](/images/servicemesh-deploy2.png)

> Iterate reloading the page and check out review section calls different versions of reviews (v1, v2, v3) each time
