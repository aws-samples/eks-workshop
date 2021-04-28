---
title: "Deploy Canary Set Up"
date: 2021-03-18T00:00:00-05:00
weight: 30
draft: false
---

#### Clone the repository

```
cd ~/environment
git clone https://github.com/aws-containers/eks-microservice-demo.git
cd eks-microservice-demo
```

#### Create a namespace and a mesh
```bash
kubectl apply -f flagger/mesh.yaml
```

{{< output >}}  
namespace/flagger created
mesh.appmesh.k8s.aws/flagger created
{{< /output >}}

#### Create a deployment and a horizontal pod autoscaler

```bash
export APP_VERSION=1.0
envsubst < ./flagger/flagger-app.yaml | kubectl apply -f -
```
{{< output >}}  
horizontalpodautoscaler.autoscaling/detail created
deployment.apps/detail created                                                                                                             
{{< /output >}}

#### Create IAM policy and Role for flagger-loadtester
```bash
# Create an IAM policy called AWSAppMeshK8sControllerIAMPolicy
aws iam create-policy \
    --policy-name FlaggerEnvoyNamespaceIAMPolicy \
    --policy-document file://envoy-iam-policy.json

# Create an IAM service account for flagger namespace 
 eksctl create iamserviceaccount --cluster eksworkshop-eksctl \
  --namespace flagger \
  --name flagger-envoy-proxies \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/FlaggerEnvoyNamespaceIAMPolicy \
  --override-existing-serviceaccounts \
  --approve 
```

#### Deploy the load testing service to generate traffic during the canary analysis
```bash
helm upgrade -i flagger-loadtester flagger/loadtester \
  --namespace=flagger \
  --set appmesh.enabled=true \
  --set "appmesh.backends[0]=detail" \
  --set "appmesh.backends[1]=detail-canary" \
  --set "serviceAccountName=flagger-envoy-proxies"
```

{{< output >}}
Release "flagger-loadtester" does not exist. Installing it now.                                                                                   
NAME: flagger-loadtester                                                                                                                          
LAST DEPLOYED: Mon Mar 15 19:31:10 2021                                                                                                           
NAMESPACE: flagger                                                                                                                         STATUS: deployed                                                                                                                                  
REVISION: 1                                                                                                                                       TEST SUITE: None                                                                                                                                  
NOTES:                                                                                                                                            
Flagger's load testing service is available at http://flagger-loadtester.flagger/  
{{< /output >}}


#### Create a canary definition

Now lets deploy the Flagger canary definition file for `detail` service

```bash
kubectl apply -f flagger/flagger-canary.yaml
```

{{< output >}}  
canary.flagger.app/detail created
{{< /output >}}

You can see the below objects being created by flagger
```bash
kubectl -n appmesh-system logs deploy/flagger --tail 15  -f | jq .msg 
```

{{< output >}} 
"Service detail-primary.flagger created"
"all the metrics providers are available!"
"VirtualNode detail-primary.flagger created"
"VirtualNode detail-canary.flagger created"
"VirtualRouter detail created"
"VirtualService detail created"
"VirtualRouter detail-canary created"
"VirtualService detail-canary created"
"Deployment detail-primary.flagger created"
"detail-primary.flagger not ready: waiting for rollout to finish: observed deployment generation less then desired generation"
"all the metrics providers are available!"
"Scaling down Deployment detail.flagger"
"HorizontalPodAutoscaler detail-primary.flagger created"
"Service detail.flagger created"
"Initialization done! detail.flagger"
{{< /output >}}

You should see the below event from canary

```bash
kubectl -n flagger describe canary/detail
```

{{< output >}}  
Events:                                                                                                                                             Type     Reason  Age                  From     Message                                                                                            ----     ------  ----                 ----     -------                                                                                          
  Warning  Synced  2m24s                flagger  detail-primary.flagger not ready: waiting for rollout to finish: observed deployment generation less then desired generation                                                                                                         
  Normal   Synced  85s (x2 over 2m24s)  flagger  all the metrics providers are available!                                                           Normal   Synced  84s                  flagger  Initialization done! detail.flagger 
{{< /output >}}

After the bootstrap is completed, 
* `detail` deployment is scaled to zero. 
* Traffic to `detail.flagger` will be routed to the primary pods.
* AppMesh resources like virtualnode, virtualservice, virtualrouter has been created for the `detail` service
```bash
kubectl get pod,deployment,svc,virtualnode,virtualservice,virtualrouter -n flagger
```

{{< output >}}
NAME                                      READY   STATUS    RESTARTS   AGE
pod/detail-primary-5f4cb44b79-xxxx      3/3     Running   0          3m58s
pod/detail-primary-5f4cb44b79-xxxx       3/3     Running   0          3m58s
pod/flagger-loadtester-5bdf76cfb7-yyyy   3/3     Running   0          5m35s

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/detail               0/0     0            0           4m50s
deployment.apps/detail-primary       2/2     2            2           3m58s
deployment.apps/flagger-loadtester   1/1     1            1           5m35s

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/detail               ClusterIP   10.100.xxx.104   <none>        3000/TCP   2m58s
service/detail-canary        ClusterIP   10.100.yyy.188   <none>        3000/TCP   3m59s
service/detail-primary       ClusterIP   10.100.zzz.217   <none>        3000/TCP   3m59s
service/flagger-loadtester   ClusterIP   10.100.pp.62     <none>        80/TCP     5m35s

NAME                                             ARN                                                                                          AGE
virtualnode.appmesh.k8s.aws/detail-canary        arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualNode/detail-canary_flagger        3m59s
virtualnode.appmesh.k8s.aws/detail-primary       arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualNode/detail-primary_flagger       3m59s
virtualnode.appmesh.k8s.aws/flagger-loadtester   arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualNode/flagger-loadtester_flagger   5m35s

NAME                                           ARN                                                                                        AGE
virtualservice.appmesh.k8s.aws/detail          arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualService/detail.flagger          3m58s
virtualservice.appmesh.k8s.aws/detail-canary   arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualService/detail-canary.flagger   3m58s

NAME                                          ARN                                                                                       AGE
virtualrouter.appmesh.k8s.aws/detail          arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualRouter/detail_flagger          3m58s
virtualrouter.appmesh.k8s.aws/detail-canary   arn:aws:appmesh:us-east-2:$ACCOUNT_ID:mesh/flagger/virtualRouter/detail-canary_flagger   3m58s
{{< /output >}}

#### Testing the setup

Exec into flagger-loadtester pod

```bash
kubectl exec deploy/flagger-loadtester -n flagger -it bash
```
{{< output >}}  
Defaulting container name to loadtester.
Use 'kubectl describe pod/flagger-loadtester-5bdf76cfb7-wl59d -n flagger' to see all of the containers in this pod.
bash-5.0$ 
{{< /output >}}

Curl to `detail` service to confirm if you get response from the deployed service
```
curl http://detail.flagger:3000/catalogDetail
```
{{< output >}}  
{"version":"1","vendors":["ABC.com"]}
{{< /output >}}


Congratulations! You have set up the canary analysis for backend service `detail` succcessfuly.
