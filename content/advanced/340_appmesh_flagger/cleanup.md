---
title: "Cleanup"
date: 2021-01-27T08:30:11-07:00
weight: 60
draft: false
---

{{% notice info %}}
Namespace deletion may take few minutes, please wait till the process completes.
{{% /notice %}}


#### Delete ECR images

```bash
aws ecr delete-repository --repository-name eks-microservice-demo/detail --force
aws ecr delete-repository --repository-name eks-microservice-demo/frontend --force
```

#### Delete Flagger Resources

```bash
kubectl delete canary detail -n  flagger
helm uninstall flagger-loadtester -n flagger
kubectl delete HorizontalPodAutoscaler detail -n flagger
```

#### Delete Flagger namespace

```bash
kubectl delete namespace flagger
```

#### Delete the mesh

```bash
kubectl delete meshes flagger
```

#### Uninstall the Flagger Helm Charts

```bash
helm -n appmesh-system delete flagger
```

#### Delete Flagger CRDs

```bash
for i in $(kubectl get crd | grep flagger | cut -d" " -f1) ; do
kubectl delete crd $i
done
```

#### Uninstall Prometheus Helm Charts

```bash
helm -n appmesh-system delete appmesh-prometheus
```

#### Uninstall Metric Server

```bash
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

#### (Optional) Uninstall AppMesh 

```bash
helm -n appmesh-system delete appmesh-controller
for i in $(kubectl get crd | grep appmesh | cut -d" " -f1) ; do
kubectl delete crd $i
done
eksctl delete iamserviceaccount  --cluster eksworkshop-eksctl --namespace appmesh-system --name appmesh-controller
kubectl delete namespace appmesh-system
```

#### (Optional) Delete Nodegroup
```bash
envsubst < ./deployment/clusterconfig.yaml | eksctl delete nodegroup -f -  --approve
```

{{% notice info %}}
Nodegroup deletion may take few minutes even though it shows the message as "Deleted" in the command line response. You can log into console and navigate to EKS -> Cluster -> Configuration -> Compute and confirm the deletion.
{{% /notice %}}
