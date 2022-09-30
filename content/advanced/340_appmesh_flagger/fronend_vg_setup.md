---
title: "Deploy Frontend/VirtualGateway"
date: 2021-03-18T00:00:00-05:00
weight: 40
draft: false
---

#### Deploy the Frontend Service

We will want to visualize the automated canary deployment, so we will use the `frontend` service as a UI. This `frontend` service will call the backend service `detail` to get the vendor information. In order to expose the `frontend` service outside the mesh, we will use AWS AppMesh VirtualGateway affiliated with Network Load Balancer. Lets deploy the `frontend` service.

```bash
export APP_VERSION=1.0
envsubst < flagger/frontend.yaml | kubectl apply -f - 
```

{{< output >}}
deployment.apps/frontend created
service/frontend created
virtualnode.appmesh.k8s.aws/frontend created
virtualservice.appmesh.k8s.aws/frontend created 
{{< /output >}}

#### Deploy the AppMesh VirtualGateway

```bash
helm upgrade -i appmesh-gateway eks/appmesh-gateway \
	--namespace flagger \
    --set serviceAccount.create=false \
    --set serviceAccount.name=flagger-envoy-proxies
```

{{< output >}}  
Release "appmesh-gateway" does not exist. Installing it now.
NAME: appmesh-gateway
LAST DEPLOYED: Tue Mar 23 01:58:55 2021
NAMESPACE: flagger
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS App Mesh Gateway installed!                                                                                   
{{< /output >}}

#### Create the GatewayRoute

In this [GatewayRoute](https://github.com/aws-containers/eks-microservice-demo/blob/main/flagger/gateway.yaml), we are routing the traffic coming into the VirtualGateway to `frontend` VirtualService.

```bash
kubectl apply -f flagger/gateway.yaml 
```

{{< output >}}  
gatewayroute.appmesh.k8s.aws/frontend created
{{< /output >}}

Get all the resources for AppMesh VirtualGateway `appmesh-gateway`

```bash
kubectl get all  -n flagger -o wide | grep appmesh-gateway
```
{{< output >}}  
pod/appmesh-gateway-65bc4cb47d-l6m6d      2/2     Running   0          19h     192.168.6.246    ip-192-168-19-33.us-east-2.compute.internal   <none>           <none>

service/appmesh-gateway      LoadBalancer   10.100.235.124   a21cab1223ac9414da4c97dee2f2c245-XXXXX.elb.us-east-2.amazonaws.com   80:30249/TCP   19h     app.kubernetes.io/name=appmesh-gateway

deployment.apps/appmesh-gateway      1/1     1            1           19h     envoy        840364872350.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod       app.kubernetes.io/name=appmesh-gateway

replicaset.apps/appmesh-gateway-65bc4cb47d      1         1         1       19h     envoy        840364872350.dkr.ecr.us-west-2.amazonaws.com/aws-appmesh-envoy:v1.15.1.0-prod       app.kubernetes.io/name=appmesh-gateway,pod-template-hash=65bc4cb47d

virtualgateway.appmesh.k8s.aws/appmesh-gateway   arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualGateway/appmesh-gateway_flagger   19h

gatewayroute.appmesh.k8s.aws/frontend   arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualGateway/appmesh-gateway_flagger/gatewayRoute/frontend_flagger   19h
{{< /output >}}

{{% notice info %}}
It takes 3 to 5 minutes to set up the Load Balancer.
{{% /notice %}}

#### Testing Setup

Find the AppMesh VirtualGateway public endpoint:

```bash
export URL="http://$(kubectl -n flagger get svc/appmesh-gateway -ojson | jq -r ".status.loadBalancer.ingress[].hostname")"
echo $URL
```

{{< output >}}  
http://a21cab1223ac9414da4c97dee2f2c245-XXXXXXXX.elb.us-east-2.amazonaws.com
{{< /output >}}

Wait for the NLB to become active:

```bash
watch curl -sS $URL
```

Once the LoadBalancer is active, access the LoadBalancer endpoint in browser
![lb](/images/app_mesh_flagger/lb.png)

You can see that our `frontend` service is exposed via VirtualGateway using Network LoadBalancer. And this `frontend` service communicates with backend service `detail` to get the vendor information.

Congratulations on exposing the `frontend` service via App Mesh VirtualGateway!  

Let’s test the Automated Canary Deployment for `detail` backend service.
