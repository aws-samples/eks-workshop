---
title: "Flagger Set Up"
date: 2021-03-18T00:00:00-05:00
weight: 10
draft: false
---

#### PreRequisite

We assume that we have already have the following setup before we start this chapter.
  * [**Required**] An existing EKS Cluster `eksworkshop-eksctl` created from [EKS Workshop](/030_eksctl/launcheks/)
  * [**Required**] [Nodegroup setup](/advanced/330_servicemesh_using_appmesh/add_nodegroup_fargate/create_nodegroup/) completed from AppMesh Workshop.
  * [**Required**] [AppMesh setup](/advanced/330_servicemesh_using_appmesh/appmesh_installation/install_appmesh/) completed from AppMesh Workshop.
  * [**Required**] [increased the disk size on your Cloud9 instnace](020_prerequisites/workspace/#increase-the-disk-size-on-the-cloud9-instance) as we need to build container images for our application.


 #### Install Flagger

Add Flagger Helm repository:

```bash
helm repo add flagger https://flagger.app
```

{{< output >}}
"flagger" has been added to your repositories
{{< /output >}}

Install Flagger's Canary CRD:

```bash
kubectl apply -f https://raw.githubusercontent.com/weaveworks/flagger/master/artifacts/flagger/crd.yaml
```
{{< output >}}
customresourcedefinition.apiextensions.k8s.io/canaries.flagger.app created
customresourcedefinition.apiextensions.k8s.io/metrictemplates.flagger.app created
customresourcedefinition.apiextensions.k8s.io/alertproviders.flagger.app created
{{< /output >}}

Deploy Flagger in the appmesh-system namespace:

```bash
helm upgrade -i flagger flagger/flagger \
--namespace=appmesh-system \
--set crd.create=false \
--set meshProvider=appmesh:v1beta2 \
--set metricsServer=http://appmesh-prometheus:9090
```
{{< output >}}    
Release "flagger" does not exist. Installing it now.
NAME: flagger
LAST DEPLOYED: Mon Dec 14 15:23:32 2020
NAMESPACE: appmesh-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Flagger installed
{{< /output >}}


#### Install the App Mesh Prometheus

```bash
helm upgrade -i appmesh-prometheus eks/appmesh-prometheus \
--wait --namespace appmesh-system
```

{{< output >}}
Release "appmesh-prometheus" does not exist. Installing it now.
NAME: appmesh-prometheus
LAST DEPLOYED: Sat Mar 13 20:59:29 2021
NAMESPACE: appmesh-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS App Mesh Prometheus installed!
{{< /output >}}

#### Enable horizontal pod auto-scaling

Install the Horizontal Pod Autoscaler (HPA) metrics provider:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

{{< output >}}
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
{{< /output >}}

After a minute, the metrics API should report CPU and memory usage for pods. You can verify the metrics API:
```bash
kubectl -n kube-system get deployment/metrics-server
```
{{< output >}}
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
metrics-server   1/1     1            1           2m34s
{{< /output >}}

```bash
kubectl -n kube-system top pods
```
{{< output >}}
NAME                              CPU(cores)   MEMORY(bytes)   
aws-node-g8bhs                    3m           40Mi            
aws-node-rgbnf                    3m           39Mi            
aws-node-wd5f9                    3m           40Mi            
coredns-556765db45-4mvnb          2m           7Mi             
coredns-556765db45-z6hmw          2m           7Mi             
kube-proxy-gr7j8                  1m           8Mi             
kube-proxy-jnjmd                  1m           7Mi             
kube-proxy-zsn8g                  1m           8Mi             
metrics-server-866b7d5b74-cvrgm   0m           4Mi 
{{< /output >}}
