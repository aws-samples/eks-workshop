---
title: "Deploy Example Microservices"
date: 2018-11-177T08:30:11-07:00
weight: 12
draft: false
---

We now have the foundation in place to deploy microservices, which are instrumented with [X-Ray SDKs](https://docs.aws.amazon.com/xray/index.html#lang/en_us), to the EKS cluster.

In this step, we are going to deploy example [front-end](https://github.com/aws-samples/eks-workshop/tree/master/content/intermediate/245_x-ray/sample-front.files) and [back-end](https://github.com/aws-samples/eks-workshop/tree/master/content/intermediate/245_x-ray/sample-back.files) microservices to the cluster. The example services are already instrumented using the [X-Ray SDK for Go](https://docs.aws.amazon.com/xray/latest/devguide/xray-sdk-go.html). Currently, X-Ray has SDKs for Go, Python, Node.js, Ruby, .NET and Java.

```
kubectl apply -f https://eksworkshop.com/intermediate/245_x-ray/sample-front.files/x-ray-sample-front-k8s.yml

kubectl apply -f https://eksworkshop.com/intermediate/245_x-ray/sample-back.files/x-ray-sample-back-k8s.yml
```

To review the status of the deployments, you can run:

```
kubectl describe deployments x-ray-sample-front-k8s x-ray-sample-back-k8s
```

For the status of the services, run the following command:

```
kubectl describe services x-ray-sample-front-k8s x-ray-sample-back-k8s
```

Once the front-end service is deployed, run the following command to get the Elastic Load Balancer (ELB) endpoint and open it in a browser.

```
kubectl get service x-ray-sample-front-k8s -o wide
```

After your ELB is deployed and available, open up the endpoint returned by the previous command in your browser and allow it to remain open. The front-end application makes a new request to the /api endpoint once per second, which in turn calls the back-end service. The JSON document displayed in the browser is the result of the request made to the back-end service.

{{% notice info %}}
This service was configured with a [LoadBalancer](https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/) so,
an [AWS Elastic Load Balancer](https://aws.amazon.com/elasticloadbalancing/) (ELB) is launched by Kubernetes for the service.
The EXTERNAL-IP column contains a value that ends with "elb.amazonaws.com" - the full value is the DNS address.
{{% /notice %}}

{{% notice tip %}}
When the front-end service is first deployed, it can take up to several minutes for the ELB to be created and DNS updated.
{{% /notice %}}

