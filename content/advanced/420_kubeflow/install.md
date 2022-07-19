---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

In this chapter, we will install Kubeflow on Amazon EKS cluster. If you don't have an EKS cluster, please follow instructions from [getting started guide](/020_prerequisites) and then launch your EKS cluster using [eksctl](/030_eksctl) chapter

### Ensure you have OIDC provider attached to the cluster

First check if the EKS cluster has OIDC provider attched by running the command:

```
eksctl get cluster eksworkshop-eksctl -o json | jq -r .[0].Identity
```

It the output of the previous command is blank, create an [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) and associate it with for your EKS cluster with the following command:

```
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} \
--region ${CLUSTER_REGION} --approve
```

### Increase cluster size

We need more resources for completing the Kubeflow chapter of the EKS Workshop.
First, we'll increase the size of our cluster to 8 nodes

```
export NODEGROUP_NAME=$(eksctl get nodegroups --cluster eksworkshop-eksctl -o json | jq -r '.[0].Name')
eksctl scale nodegroup --cluster eksworkshop-eksctl --name $NODEGROUP_NAME --nodes 8 --nodes-max 8
```
{{% notice info %}}
Scaling the nodegroup will take 2 - 3 minutes.
{{% /notice %}}

### Install Kubeflow on Amazon EKS

#### Install Kustomize
<div data-proofer-ignore>
Download 3.2.0 release of `kustomize`. This binary will allow you to install Kubeflow on Amazon EKS
</div>

{{% notice info %}}
Warning: Kubeflow is not compatible with the latest versions of of kustomize 4.x. This is due to changes in the order that resources are sorted and printed. Please see [kubernetes-sigs/kustomize#3794](https://github.com/kubernetes-sigs/kustomize/issues/3794) and [kubeflow/manifests#1797](https://github.com/kubeflow/manifests/issues/1797). We know that this is not ideal and are working with the upstream kustomize team to add support for the latest versions of kustomize as soon as we can.
{{% /notice %}}

```
curl --silent --location "https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64" -o /tmp/kustomize
sudo chmod +x /tmp/kustomize && sudo mv -v /tmp/kustomize /usr/local/bin
```

#### Clone the repository 
Clone the [`awslabs/kubeflow-manifests`](https://github.com/awslabs/kubeflow-manifests) and the [`kubeflow/manifests`](https://github.com/kubeflow/manifests) repositories and check out the release branches of your choosing.

Substitute the value for `KUBEFLOW_RELEASE_VERSION`(e.g. v1.5.1) and `AWS_RELEASE_VERSION`(e.g. v1.5.1-aws-b1.0.0) with the tag or branch you want to use below. Read more about [releases and versioning](https://awslabs.github.io/kubeflow-manifests/release-v1.5.1-aws-b1.0.0/docs/about/releases/) if you are unsure about what these values should be.
```bash
export KUBEFLOW_RELEASE_VERSION=v1.5.1
export AWS_RELEASE_VERSION=v1.5.1-aws-b1.0.0
git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
```

#### Build Manifests and install Kubeflow

There two options for installing Kubeflow official components and common services with kustomize.

1. Single-command installation of all components under `apps` and `common`
2. Multi-command, individual components installation for `apps` and `common`

Option 1 targets ease of deployment for end users. This lab we will use this option.\
Option 2 targets customization and ability to pick and choose individual components.

> Warning: In both options, we use a default email (`user@example.com`) and password (`12341234`). For any production Kubeflow deployment, you should change the default password by following [the relevant section](#change-default-user-password).

---
**NOTE**

`kubectl apply` commands may fail on the first try. This is inherent in how Kubernetes and `kubectl` work (e.g., CR must be created after CRD becomes ready). The solution is to re-run the command until it succeeds. For the single-line command, we have included a bash one-liner to retry the command.

---

#### Install with a single command

You can install all Kubeflow official components (residing under `apps`) and all common services (residing under `common`) using the following command:

```sh
while ! kustomize build deployments/vanilla | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 30; done
```

Run below command to check the status
```
kubectl -n kubeflow get all
```
{{% notice info %}}
Installing Kubeflow and its toolset may take 2 - 3 minutes. Few pods may initially give Error or CrashLoopBackOff status. Give it some time, they will auto-heal and will come to Running state
{{% /notice %}}

{{%expand "Expand here to see the output" %}}
```
$ kubectl -n kubeflow get all
NAME                                                             READY   STATUS    RESTARTS   AGE
pod/admission-webhook-deployment-7df7558c67-t6nkd                1/1     Running   0          26m
pod/cache-server-5bdbd59959-hn54n                                2/2     Running   0          26m
pod/centraldashboard-79f489b55-q7j4b                             2/2     Running   0          26m
pod/jupyter-web-app-deployment-7cd59c5c95-rdqpf                  1/1     Running   0          26m
pod/katib-controller-58ddb4b856-72jq7                            1/1     Running   0          26m
pod/katib-db-manager-d77c6757f-fmwzk                             1/1     Running   0          26m
pod/katib-mysql-7894994f88-fclb8                                 1/1     Running   0          26m
pod/katib-ui-f787b9d88-vbshr                                     1/1     Running   0          26m
pod/kfserving-controller-manager-0                               2/2     Running   0          26m
pod/kfserving-models-web-app-7884f597cf-n7cn8                    2/2     Running   0          26m
pod/kserve-models-web-app-5c64c8d8bb-br6rp                       2/2     Running   0          26m
pod/kubeflow-pipelines-profile-controller-84bcbdb899-65wsn       1/1     Running   0          26m
pod/metacontroller-0                                             1/1     Running   0          26m
pod/metadata-envoy-deployment-86d856fc6-mr95n                    1/1     Running   0          26m
pod/metadata-grpc-deployment-f8d68f687-rhfvk                     2/2     Running   3          26m
pod/metadata-writer-d7ff8d4bc-txdn8                              2/2     Running   0          26m
pod/minio-5b65df66c9-lkw4f                                       2/2     Running   0          26m
pod/ml-pipeline-7499f55b46-w7w8l                                 2/2     Running   1          26m
pod/ml-pipeline-persistenceagent-7bf47b869c-nd8tb                2/2     Running   0          26m
pod/ml-pipeline-scheduledworkflow-565fd7846-n52x9                2/2     Running   0          26m
pod/ml-pipeline-ui-77477f77dc-4gjzg                              2/2     Running   0          26m
pod/ml-pipeline-viewer-crd-68bcdc87f9-9d72b                      2/2     Running   1          26m
pod/ml-pipeline-visualizationserver-7bc59978d-sdh84              2/2     Running   0          26m
pod/mysql-f7b9b7dd4-5mgtw                                        2/2     Running   0          26m
pod/notebook-controller-deployment-7474fbff66-lvftm              2/2     Running   1          26m
pod/profiles-deployment-5cc86bc965-zktbg                         3/3     Running   2          26m
pod/tensorboard-controller-controller-manager-5cbddb7fb5-j6hkw   3/3     Running   2          26m
pod/tensorboards-web-app-deployment-7c5db448d7-jqr58             1/1     Running   0          26m
pod/training-operator-6bfc7b8d86-grfm8                           1/1     Running   0          26m
pod/volumes-web-app-deployment-87484c848-lggnh                   1/1     Running   0          26m
pod/workflow-controller-5cb67bb9db-ph2q9                         2/2     Running   1          26m

NAME                                                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/admission-webhook-service                                   ClusterIP   10.100.204.94    <none>        443/TCP             26m
service/cache-server                                                ClusterIP   10.100.124.41    <none>        443/TCP             26m
service/centraldashboard                                            ClusterIP   10.100.26.238    <none>        80/TCP              26m
service/jupyter-web-app-service                                     ClusterIP   10.100.50.251    <none>        80/TCP              26m
service/katib-controller                                            ClusterIP   10.100.132.8     <none>        443/TCP,8080/TCP    26m
service/katib-db-manager                                            ClusterIP   10.100.231.114   <none>        6789/TCP            26m
service/katib-mysql                                                 ClusterIP   10.100.4.87      <none>        3306/TCP            26m
service/katib-ui                                                    ClusterIP   10.100.44.197    <none>        80/TCP              26m
service/kfserving-controller-manager-metrics-service                ClusterIP   10.100.146.200   <none>        8443/TCP            26m
service/kfserving-controller-manager-service                        ClusterIP   10.100.75.226    <none>        443/TCP             26m
service/kfserving-models-web-app                                    ClusterIP   10.100.193.57    <none>        80/TCP              26m
service/kfserving-webhook-server-service                            ClusterIP   10.100.115.110   <none>        443/TCP             26m
service/kserve-models-web-app                                       ClusterIP   10.100.160.240   <none>        80/TCP              26m
service/kubeflow-pipelines-profile-controller                       ClusterIP   10.100.44.161    <none>        80/TCP              26m
service/metadata-envoy-service                                      ClusterIP   10.100.111.207   <none>        9090/TCP            26m
service/metadata-grpc-service                                       ClusterIP   10.100.56.101    <none>        8080/TCP            26m
service/minio-service                                               ClusterIP   10.100.225.255   <none>        9000/TCP            26m
service/ml-pipeline                                                 ClusterIP   10.100.36.226    <none>        8888/TCP,8887/TCP   26m
service/ml-pipeline-ui                                              ClusterIP   10.100.192.99    <none>        80/TCP              26m
service/ml-pipeline-visualizationserver                             ClusterIP   10.100.70.121    <none>        8888/TCP            26m
service/mysql                                                       ClusterIP   10.100.51.87     <none>        3306/TCP            26m
service/notebook-controller-service                                 ClusterIP   10.100.193.94    <none>        443/TCP             26m
service/profiles-kfam                                               ClusterIP   10.100.122.221   <none>        8081/TCP            26m
service/tensorboard-controller-controller-manager-metrics-service   ClusterIP   10.100.102.234   <none>        8443/TCP            26m
service/tensorboards-web-app-service                                ClusterIP   10.100.138.222   <none>        80/TCP              26m
service/training-operator                                           ClusterIP   10.100.223.54    <none>        8080/TCP            26m
service/volumes-web-app-service                                     ClusterIP   10.100.95.178    <none>        80/TCP              26m
service/workflow-controller-metrics                                 ClusterIP   10.100.176.155   <none>        9090/TCP            26m

NAME                                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/admission-webhook-deployment                1/1     1            1           26m
deployment.apps/cache-server                                1/1     1            1           26m
deployment.apps/centraldashboard                            1/1     1            1           26m
deployment.apps/jupyter-web-app-deployment                  1/1     1            1           26m
deployment.apps/katib-controller                            1/1     1            1           26m
deployment.apps/katib-db-manager                            1/1     1            1           26m
deployment.apps/katib-mysql                                 1/1     1            1           26m
deployment.apps/katib-ui                                    1/1     1            1           26m
deployment.apps/kfserving-models-web-app                    1/1     1            1           26m
deployment.apps/kserve-models-web-app                       1/1     1            1           26m
deployment.apps/kubeflow-pipelines-profile-controller       1/1     1            1           26m
deployment.apps/metadata-envoy-deployment                   1/1     1            1           26m
deployment.apps/metadata-grpc-deployment                    1/1     1            1           26m
deployment.apps/metadata-writer                             1/1     1            1           26m
deployment.apps/minio                                       1/1     1            1           26m
deployment.apps/ml-pipeline                                 1/1     1            1           26m
deployment.apps/ml-pipeline-persistenceagent                1/1     1            1           26m
deployment.apps/ml-pipeline-scheduledworkflow               1/1     1            1           26m
deployment.apps/ml-pipeline-ui                              1/1     1            1           26m
deployment.apps/ml-pipeline-viewer-crd                      1/1     1            1           26m
deployment.apps/ml-pipeline-visualizationserver             1/1     1            1           26m
deployment.apps/mysql                                       1/1     1            1           26m
deployment.apps/notebook-controller-deployment              1/1     1            1           26m
deployment.apps/profiles-deployment                         1/1     1            1           26m
deployment.apps/tensorboard-controller-controller-manager   1/1     1            1           26m
deployment.apps/tensorboards-web-app-deployment             1/1     1            1           26m
deployment.apps/training-operator                           1/1     1            1           26m
deployment.apps/volumes-web-app-deployment                  1/1     1            1           26m
deployment.apps/workflow-controller                         1/1     1            1           26m

NAME                                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/admission-webhook-deployment-7df7558c67                1         1         1       26m
replicaset.apps/cache-server-5bdbd59959                                1         1         1       26m
replicaset.apps/centraldashboard-79f489b55                             1         1         1       26m
replicaset.apps/jupyter-web-app-deployment-7cd59c5c95                  1         1         1       26m
replicaset.apps/katib-controller-58ddb4b856                            1         1         1       26m
replicaset.apps/katib-db-manager-d77c6757f                             1         1         1       26m
replicaset.apps/katib-mysql-7894994f88                                 1         1         1       26m
replicaset.apps/katib-ui-f787b9d88                                     1         1         1       26m
replicaset.apps/kfserving-models-web-app-7884f597cf                    1         1         1       26m
replicaset.apps/kserve-models-web-app-5c64c8d8bb                       1         1         1       26m
replicaset.apps/kubeflow-pipelines-profile-controller-84bcbdb899       1         1         1       26m
replicaset.apps/metadata-envoy-deployment-86d856fc6                    1         1         1       26m
replicaset.apps/metadata-grpc-deployment-f8d68f687                     1         1         1       26m
replicaset.apps/metadata-writer-d7ff8d4bc                              1         1         1       26m
replicaset.apps/minio-5b65df66c9                                       1         1         1       26m
replicaset.apps/ml-pipeline-7499f55b46                                 1         1         1       26m
replicaset.apps/ml-pipeline-persistenceagent-7bf47b869c                1         1         1       26m
replicaset.apps/ml-pipeline-scheduledworkflow-565fd7846                1         1         1       26m
replicaset.apps/ml-pipeline-ui-77477f77dc                              1         1         1       26m
replicaset.apps/ml-pipeline-viewer-crd-68bcdc87f9                      1         1         1       26m
replicaset.apps/ml-pipeline-visualizationserver-7bc59978d              1         1         1       26m
replicaset.apps/mysql-f7b9b7dd4                                        1         1         1       26m
replicaset.apps/notebook-controller-deployment-7474fbff66              1         1         1       26m
replicaset.apps/profiles-deployment-5cc86bc965                         1         1         1       26m
replicaset.apps/tensorboard-controller-controller-manager-5cbddb7fb5   1         1         1       26m
replicaset.apps/tensorboards-web-app-deployment-7c5db448d7             1         1         1       26m
replicaset.apps/training-operator-6bfc7b8d86                           1         1         1       26m
replicaset.apps/volumes-web-app-deployment-87484c848                   1         1         1       26m
replicaset.apps/workflow-controller-5cb67bb9db                         1         1         1       26m

NAME                                            READY   AGE
statefulset.apps/kfserving-controller-manager   1/1     26m
statefulset.apps/metacontroller                 1/1     26m

NAME                                   SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/aws-kubeflow-telemetry   0 0 * * *   False     0        <none>          26m
```
{{% /expand %}}

Once everything is installed successfully, you can access the Kubeflow Central Dashboard [by logging into your cluster](#connect-to-your-kubeflow-cluster).

You can now start experimenting and running your end-to-end ML workflows with Kubeflow!