---
title: "Add VirtualGateway"
date: 2020-01-27T08:30:11-07:00
weight: 50
---

#### Adding App Mesh VirtualGateway

![gateway](/images/app_mesh_fargate/meshify3.png)
Until now we have verified the communication between services is routed through envoy proxy, lets expose the frontend service `frontend-node` using AWS App Mesh VirtualGateway.

Create VirtualGateway components uisng the [virtual_gateway.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/virtual_gateway.yaml) as shown below. 
This will create the kubernetes service as Type Load Balancer and will use the AWS Network Load balancer for routing the external internet traffic.
```bash
kubectl apply -f deployment/virtual_gateway.yaml 
```
{{< output >}}   
virtualgateway.appmesh.k8s.aws/ingress-gw created    
gatewayroute.appmesh.k8s.aws/gateway-route-frontend created 
service/ingress-gw created 
deployment.apps/ingress-gw created 
{{< /output >}} 

#### Get all the resources that are running in the namespace

You can see VirtualGateway components named as `ingress-gw` below:
```bash
kubectl get all  -n prodcatalog-ns -o wide | grep ingress
```
{{< output >}}       
pod/ingress-gw-5fb995f6fd-45nnm      2/2     Running   0          35s     192.168.24.144    ip-192-168-21-156.us-west-2.compute.internal            <none>           <none>
service/ingress-gw      LoadBalancer   10.100.24.17     ad34ee9dea9944ed78e78d0578060ba6-869c67fd174d0f4d.elb.us-west-2.amazonaws.com   80:31569/TCP   35s   app=ingress-gw
deployment.apps/ingress-gw      1/1     1            1           35s   envoy           840364872350.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod        app=ingress-gw
replicaset.apps/ingress-gw-5fb995f6fd      1         1         1       35s     envoy           840364872350.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod        app=ingress-gw,pod-template-hash=5fb995f6fd
virtualgateway.appmesh.k8s.aws/ingress-gw   arn:aws:appmesh:us-west-2:405710966773:mesh/prodcatalog-mesh/virtualGateway/ingress-gw_prodcatalog-ns   35s
gatewayroute.appmesh.k8s.aws/gateway-route-frontend   arn:aws:appmesh:us-west-2:405710966773:mesh/prodcatalog-mesh/virtualGateway/ingress-gw_prodcatalog-ns/gatewayRoute/gateway-route-frontend_prodcatalog-ns   35s
{{< /output >}}

Log into console and navigate to AWS App Mesh -> Click on `prodcatalog-mesh` -> Click on `Virtual gateways`, you should see below page.
![vgateway](/images/app_mesh_fargate/vg.png)