---
title: "Intelligent Routing"
date: 2018-11-13T21:49:32+09:00
weight: 50
draft: false
---

### Intelligent Routing

Deploying a microservice-based application in an Istio service mesh allows one to externally control service monitoring and tracing, request (version) routing, resiliency testing, security and policy enforcement, and more in a consistent manner across the services, and the application.

Before you can use Istio to control the Bookinfo version routing, you'll need to define the available versions, called <span style="color:orange">**subsets**</span>, in destination rules.

{{% notice info %}}
Service versions (a.k.a. subsets) - In a continuous deployment scenario, for a given service, there can be distinct subsets of instances running different variants of the application binary. These variants are not necessarily different API versions. They could be iterative changes to the same service, deployed in different environments (prod, staging, dev, etc.). Common scenarios where this occurs include A/B testing, canary rollouts, etc. The choice of a particular version can be decided based on various criterion (headers, url, etc.) and/or by weights assigned to each version. Each service has a default version consisting of all its instances.
{{% /notice %}}

```
kubectl apply -f samples/bookinfo/networking/destination-rule-all.yaml

kubectl get destinationrules -o yaml
```

To route to one version only, you apply virtual services that set the default version for the microservices. In this case, the virtual services will route all traffic to <span style="color:orange">**reviews:v1**</span> of microservice.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl get virtualservices reviews -o yaml
```

The subset is set to v1 for all reviews request.

```
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
```

Try now to reload the page multiple times, and note how only version 1 of reviews is displayed each time.

Next, we'll change the route configuration so that all traffic from a specific user is routed to a specific service version. In this case, all traffic from a user named <span style="color:orange">*Jason*</span> will be routed to the service <span style="color:orange">**reviews:v2**</span>.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

kubectl get virtualservices reviews -o yaml
```

The subset is set to v1 in default and route v2 if the logged user is match with 'jason' for reviews request.

```
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
```

To test, click **Sign in** from the top right corner of the page, and login using **jason** as user name with a blank password. You will only see reviews:v2 all the time. Others will see reviews:v1.

To test for resiliency, inject a 7s delay between the reviews:v2 and ratings microservices for user jason. This test will uncover a bug that was intentionally introduced into the Bookinfo app.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

kubectl get virtualservice ratings -o yaml
```

The subset is set to v1 in default and added 7s delay for all the request if the logged user is match with 'jason' for ratings.

```
spec:
  hosts:
  - ratings
  http:
  - fault:
      delay:
        fixedDelay: 7s
        percent: 100
    match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: ratings
        subset: v1
  - route:
    - destination:
        host: ratings
        subset: v1
```

Logout, then click **Sign in** from the top right corner of the page, using **jason** as the user name with a blank password. You will see the delays and it ends up display error for reviews. Others will see reviews without error.

The timeout between the productpage and the reviews service is 6 seconds - coded as 3s + 1 retry for 6s total.

To test for another resiliency, introduce an HTTP abort to the ratings microservices for the test user jason. The page will immediately display the “<span style="color:orange">*Ratings service is currently unavailable*</span>”

```
kubectl apply -f samples/bookinfo/networking/virtual-service-ratings-test-abort.yaml

kubectl get virtualservice ratings -o yaml
```

The subset is set to v1 and by default returns an error message of "Ratings service is currently unavailable" below the reviewer name if the logged username matches 'jason'.

```
spec:
  hosts:
  - ratings
  http:
  - fault:
      abort:
        httpStatus: 500
        percent: 100
    match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: ratings
        subset: v1
  - route:
    - destination:
        host: ratings
        subset: v1
```

To test, click **Sign in** from the top right corner of the page and login using **jason** for the user name with a blank password. As **jason** you will see the error message. Others (not logged in as **jason**) will see no error message.

Next, we'll demonstrate how to gradually migrate traffic from one version of a microservice to another. In our example, we'll send <span style="color:orange">50% of traffic to reviews:v1</span> and <span style="color:blue">50% to reviews:v3</span>.

```
kubectl apply -f samples/bookinfo/networking/virtual-service-all-v1.yaml

kubectl apply -f samples/bookinfo/networking/virtual-service-reviews-50-v3.yaml

kubectl get virtualservice reviews -o yaml
```

The subset is set to 50% of traffic to v1 and 50% of traffic to v3 for all reviews request.
```
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 50
    - destination:
        host: reviews
        subset: v3
      weight: 50
```

To test it, refresh your browser over and over, and you'll see only reviews:v1 and reviews:v3.
