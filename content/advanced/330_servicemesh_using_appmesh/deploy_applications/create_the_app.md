---
title: "Create Product Catalog Application"
date: 2020-01-27T08:30:11-07:00
weight: 60
---

Let's create the Product Catalog Application!
    
#### Build Application Services

Build and Push the Container images to ECR for all the three services
```bash
cd eks-app-mesh-polyglot-demo
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
PROJECT_NAME=eks-app-mesh-demo
export APP_VERSION=1.0
for app in catalog_detail product_catalog frontend_node; do
  aws ecr describe-repositories --repository-name $PROJECT_NAME/$app >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name $PROJECT_NAME/$app >/dev/null
  TARGET=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME/$app:$APP_VERSION
  docker build -t $TARGET apps/$app
  docker push $TARGET
done
```
{{% notice info %}}
Building/Pushing Container images first time to ECR may take around 3-5 minutes
{{% /notice %}}

Once completed, you can confirm the images are in ECR by logging into the console
![ecr](/images/app_mesh_fargate/ecr.png)

#### Deploy the Application Services to EKS

```bash
envsubst < ./deployment/base_app.yaml | kubectl apply -f -
```
{{< output >}}
deployment.apps/prodcatalog created
service/prodcatalog created
deployment.apps/proddetail created
service/proddetail created
deployment.apps/frontend-node created
service/frontend-node created
{{< /output >}}

{{% notice info %}}
Fargate pod creation for `prodcatalog` service may take 3 to 4 minutes
{{% /notice %}}

#### Get the deployment details
 
```bash
kubectl get deployment,pods,svc -n prodcatalog-ns -o wide
```
You can see that:

 + Product Catalog service was deployed to `Fargate` pod as it matched the configuration 
 (namespace `prodcatalog-ns` and pod spec label as `app= prodcatalog`) that we had specified when creating fargate profile 
 + And other services Frontend and Catalog Product Detail were deployed into `Managed Nodegroup`
 
    {{< output >}}
NAME                            READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS      IMAGES                                                                          SELECTOR
deployment.apps/frontend-node   1/1     1            1           44h   frontend-node   $ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/frontend-node:4.6                  app=frontend-node
deployment.apps/prodcatalog     1/1     1            1           22h   prodcatalog     $ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/product-catalog:1.2                app=prodcatalog
deployment.apps/proddetail      1/1     1            1           44h   proddetail      $ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/product-detail:1.1                 app=proddetail

NAME                                 READY   STATUS    RESTARTS   AGE   IP               NODE                                                   NOMINATED NODE   READINESS GATES
pod/frontend-node-77d64585d4-xxxx   1/1     Running   0          13h   192.168.X.6     ip-192-168-X-X.us-west-2.compute.internal           <none>           <none>
pod/prodcatalog-98f7c5f87-xxxxx      1/1     Running   0          13h   192.168.X.17   fargate-ip-192-168-X-X.us-west-2.compute.internal   <none>           <none>
pod/proddetail-5b558df99d-xxxxx      1/1     Running   0          18h   192.168.24.X   ip-192-168-X-X.us-west-2.compute.internal            <none>           <none>

NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)        AGE   SELECTOR
service/frontend-node   ClusterIP      10.100.X.X    <none>                                                                          9000/TCP       44h   app=frontend-node
service/prodcatalog     ClusterIP      10.100.X.X   <none>                                                                          5000/TCP       41h   app=prodcatalog
service/proddetail      ClusterIP      10.100.X.X   <none>                                                                          3000/TCP       44h   app=proddetail                                                               3000/TCP       103m
    {{< /output >}}

 
#### Confirm that the fargate pod is using the Service Account role
```bash
export BE_POD_NAME=$(kubectl get pods -n prodcatalog-ns -l app=prodcatalog -o jsonpath='{.items[].metadata.name}') 

kubectl describe pod ${BE_POD_NAME} -n  prodcatalog-ns | grep 'AWS_ROLE_ARN\|AWS_WEB_IDENTITY_TOKEN_FILE\|serviceaccount' 
```

You should see the below output which has the same role that we had associated with the Service Account as part of Fargate setup.
{{< output >}}
AWS_ROLE_ARN:                 arn:aws:iam::$ACCOUNT_ID:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-1PWNQ4AJFMVBF
AWS_WEB_IDENTITY_TOKEN_FILE:  /var/run/secrets/eks.amazonaws.com/serviceaccount/token
/var/run/secrets/eks.amazonaws.com/serviceaccount from aws-iam-token (ro)
/var/run/secrets/kubernetes.io/serviceaccount from prodcatalog-envoy-proxies-token-69pql (ro)
{{< /output >}}

#### Confirm that the fargate pod logging is enabled
```bash
kubectl describe pod ${BE_POD_NAME} -n  prodcatalog-ns | grep LoggingEnabled
```
We can see the confirmation in the events that says Successfully enabled logging for pod.
{{< output >}}
  Normal  LoggingEnabled  2m7s  fargate-scheduler  Successfully enabled logging for pod
{{< /output >}}