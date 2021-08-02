---
title: "Canary Deployment"
date: 2020-01-27T08:30:11-07:00
weight: 60
draft: false
---

  
Now lets deploy a new version (version 2) of Catalog Product Detail backend service. 
And change the `proddetail` VirtualRouter to route traffic 90% to `proddetail-v1` version 1 and 10% to `proddetail-v2` version 2. 
And as we gain confidence in the `proddetail-v2`, we can increase the % in a linear fashion. 
![canary](/images/app_mesh_fargate/canary1.png)

#### Build Catalog Detail Version 2 service

```bash
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
PROJECT_NAME=eks-app-mesh-demo
export APP_VERSION_2=2.0
for app in catalog_detail; do
  aws ecr describe-repositories --repository-name $PROJECT_NAME/$app >/dev/null 2>&1 || \
  aws ecr create-repository --repository-name $PROJECT_NAME/$app >/dev/null
  TARGET=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$PROJECT_NAME/$app:$APP_VERSION_2
  cd apps/$app
  docker build -t $TARGET -f version2/Dockerfile .
  docker push $TARGET
  cd ../../.
done
```

#### Deploy Catalog Detail Version 2 service resources

Looking at the section of [canary.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/canary.yaml#L27) shown below, 
you can see we've added the route as 10% to new service `proddetail-v2` and 90% to existing service `proddetail-v1`.

{{< output >}}
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualRouter
metadata:
  name: proddetail-router
  namespace: prodcatalog-ns
spec:
  listeners:
    - portMapping:
        port: 3000
        protocol: http
  routes:
    - name: proddetail-route
      httpRoute:
        match:
          prefix: /
        action:
          weightedTargets:
            - virtualNodeRef:
                name: proddetail-v1
              weight: 90
            - virtualNodeRef:
                name: proddetail-v2
              weight: 10
---
{{< /output >}}

Lets deploy the resources for proddetail service version v2

```bash
envsubst < ./deployment/canary.yaml | kubectl apply -f -
```
{{< output >}}
virtualnode.appmesh.k8s.aws/proddetail-v2 created
virtualrouter.appmesh.k8s.aws/proddetail-router configured
deployment.apps/proddetail2 created
service/proddetail2 created
{{< /output >}}

Check the resources for proddetail service version 2

```bash
kubectl get all -n prodcatalog-ns | grep 'proddetail2\|proddetail-v2'
```
{{< output >}}    
pod/proddetail2-9687989db-xxxx      3/3     Running   0          5m52s
service/proddetail2     ClusterIP      10.100.XX.YYY    <none>                                                                          3000/TCP       18m
deployment.apps/proddetail2     1/1     1            1           5m52s
replicaset.apps/proddetail2-96879yyyxx      1         1         1       5m52s
virtualnode.appmesh.k8s.aws/proddetail-v2   arn:aws:appmesh:us-west-2:405710966773:mesh/prodcatalog-mesh/virtualNode/proddetail-v2_prodcatalog-ns   18m
{{< /output >}}
