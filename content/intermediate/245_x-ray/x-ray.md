---
title: "X-Ray Console"
date: 2018-11-177T08:30:11-07:00
weight: 13
draft: false
---

We now have the example microservices deployed, so we are going to investigate our [Service Graph](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-servicegraph) and [Traces](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-traces) in [X-Ray section of the AWS Management Console](https://console.aws.amazon.com/xray/home#/service-map).

The [Service map in the console](https://console.aws.amazon.com/xray/home#/service-map) provides a visual representation of the steps identified by X-Ray for a particular trace. Each resource that sends data to X-Ray within the same context appears as a service in the graph. In the example below, we can see that the **x-ray-sample-front-k8s** service is processing 39 transactions per minute with an average latency of 0.99ms per operation. Additionally, the **x-ray-sample-back-k8s** is showing an average latency of 0.08ms per transaction.

![GitHub Edit](/images/x-ray/service_map.png)

Next, go to the [traces section in the AWS Management Console](https://console.aws.amazon.com/xray/home#/traces) to view the execution times for the segments in the requests. At the top of the page, we can see the URL for the ELB endpoint and the corresponding traces below.

![GitHub Edit](/images/x-ray/traces.png)

If you click on the link on the left in the **Trace list** section you will see the overall execution time for the request (0.5ms for the **x-ray-sample-front-k8s** which wraps other segments and subsegments), as well as a breakdown of the individual [segments](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-segments) in the request. In this visualization, you can see the front-end and back-end segments and a [subsegment](https://docs.aws.amazon.com/xray/latest/devguide/xray-concepts.html#xray-concepts-subsegments) named **x-ray-sample-back-k8s-gen** In the [back-end service source code](https://github.com/aws-samples/eks-workshop/blob/master/content/intermediate/245_x-ray/sample-back.files/main.go#L35), we instrumented a subsegment that surrounds a random number generator.

In the Go example, [the main segment](https://github.com/aws-samples/eks-workshop/blob/master/content/intermediate/245_x-ray/sample-back.files/main.go#L26) is initialized in the xray.Handler helper, which in turn sets all necessary information in the http.Request context struct, so that it can be used when initializing the subsegment.

![GitHub Edit](/images/x-ray/trace.png)

{{% notice tip %}}
Click on the image to zoom
{{% /notice %}}


