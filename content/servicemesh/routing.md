---
title: "Intelligent Routing"
date: 2018-11-13T21:49:32+09:00
weight: 50
draft: false
---

### Intelligent Routing

> Deploying a microservice-based application in an Istio service mesh allows one to externally control service monitoring and tracing, request (version) routing, resiliency testing, security and policy enforcement, etc., In a consistent way across the services, for the application as a whole.

Before you can use Istio to control the Bookinfo version routing, you need to define the available versions, called <span style="color:orange">*`subsets`*</span>, in destination rules

```
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml

kubectl get destinationrules -o yaml
```

To route to one version only, you apply virtual services that set the default version for the microservices. In this case, the virtual services will route all traffic to <span style="color:orange">**reviews:v1**</span> of each microservice.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl get virtualservices reviews -o yaml
```

> Iterate reloading the page and check out review section calls only version of reviews v1 all the time

Change the route configuration so that all traffic from a specific user is routed to a specific service version. In this case, all traffic from a user named <span style="color:orange">*Jason*</span> will be routed to the service <span style="color:orange">**reviews:v2**</span>.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

kubectl get virtualservices reviews -o yaml
```

> Login to a user as jason. You will only see reviews:v2 all the time. Others will see reviews:v1

To test for resiliency, inject a 7s delay between the reviews:v2 and ratings microservices for user jason. This test will uncover a bug that was intentionally introduced into the Bookinfo app.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

kubectl get virtualservice ratings -o yaml
```

> Login to a user as jason. You will see the delays and it ends up display error for reviews. Others will see reviews without error.
> The timeout between the productpage and the reviews service is 6 seconds - coded as 3s + 1 retry for 6s total.

To test for another resiliency, introduce an HTTP abort to the ratings microservices for the test user jason. The page will immediately display the “<span style="color:orange">*Ratings service is currently unavailable*</span>”

```
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml

kubectl get virtualservice ratings -o yaml
```

> Login to a user as jason. You will see error for ratings. Others will see rating without error.

This demo shows you how to gradually migrate traffic from one version of a microservice to another. <span style="color:orange">Send 50% of traffic to reviews:v1</span> and <span style="color:blue">50% to reviews:v3</span>. Then, complete the migration by sending 100% of traffic to reviews:v3.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

kubectl get virtualservice reviews -o yaml
```

> keep refreshing your browser. You will see the pages for reviews:v1 and reviews:v3
