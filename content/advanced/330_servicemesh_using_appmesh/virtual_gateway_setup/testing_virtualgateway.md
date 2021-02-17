---
title: "Testing Virtual Gateway"
date: 2020-01-27T08:30:11-07:00
weight: 80
---

Now it's time to test. Get the Loadbalancer endpoint that Virtual Gateway is exposed.
    
{{% notice info %}}
It takes 3 to 5 minutes to set up the Load Balancer. You can go to Console and Go to Load Balancer and check if the state is `Active`.
Do not proceed to next step until Load Balancer is `Active`.
{{% /notice %}}

```bash
export LB_NAME=$(kubectl get svc ingress-gw -n prodcatalog-ns -o jsonpath="{.status.loadBalancer.ingress[*].hostname}") 
 curl -v --silent ${LB_NAME} | grep x-envoy
echo $LB_NAME
```
Check if the request to the Ingress Gateway is going from envoy by curl to the above Loadbalancer url
{{< output >}}    
> GET / HTTP/1.1
> Host: db13be460b8648c4bXXXf.elb.us-west-2.amazonaws.com
> User-Agent: curl/7.54.0
> Accept: */*
> 
< HTTP/1.1 200 OK
< content-type: text/html; charset=utf-8
< content-length: 3783
< x-amzn-trace-id: Root=1-5ff4c10e-71cca9a19486406b80eaa475
< server: envoy
< date: Tue, 05 Jan 2021 19:42:06 GMT
< x-envoy-upstream-service-time: 3
< server: envoy
{ [1079 bytes data]
* Connection #0 to host db13be460b8648c4bXXXf.elb.us-west-2.amazonaws.com left intact

workshop:~/environment $ echo $LB_NAME

db13be460b8648c4bXXXf.elb.us-west-2.amazonaws.com
{{< /output >}} 

Copy paste the above Loadbalancer endpoint in your browser and you should see the frontend application loaded as below.
![fronteend](/images/app_mesh_fargate/ui1.png)

Add Product e.g. `Table` with ID as `1` to Product Catalog and click **Add** button.
![post rquest](/images/app_mesh_fargate/ui2.png)

You should see the new product `Table` added in the Product Catalog table. You can also see the Catalog Detail about Vendor information has been fetched from `proddetail` backend service.
![pos2 reauest](/images/app_mesh_fargate/ui3.png)


Congratulations on exposing the Product Catalog Application via App Mesh Virtual Gateway!  

Let’s try out Canary Deployment by adding a new version of the `proddetail-v2` and adding some new configuration to our virtual routers to shift traffic between the different versions of Catalog Detail service `proddetail-v1` and `proddetail-v2`.