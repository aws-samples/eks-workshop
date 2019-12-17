---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

In this chapter, we will install Kubeflow on Amazon EKS cluster. If you don't have an EKS cluster, please follow instructions from [getting started guide](/020_prerequisites) and then launch your EKS cluster using [eksctl](/030_eksctl) chapter

### Increase cluster size

We need more resources for completing the Kubeflow chapter of the EKS Workshop.
First, we'll increase the size of our cluster to 6 nodes:

```
export NODEGROUP_NAME=$(eksctl get nodegroups --cluster eksworkshop-eksctl -o json | jq -r '.[0].Name')
eksctl scale nodegroup --cluster eksworkshop-eksctl --name $NODEGROUP_NAME --nodes 6
```
{{% notice info %}}
Scaling the nodegroup will take 2 - 3 minutes.
{{% /notice %}}

### Install Kubeflow on Amazon EKS

Download 0.7 release of `kfctl`. This binary will allow you to install Kubeflow on Amazon EKS:

```
curl --silent --location "https://github.com/kubeflow/kubeflow/releases/download/v0.7.0/kfctl_v0.7.0_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin
```

Export Kubeflow configuration file:

```
export CONFIG_URI=https://raw.githubusercontent.com/kubeflow/manifests/v0.7-branch/kfdef/kfctl_aws.0.7.0.yaml
```
#### Customize your configuration

Set an environment variable for your AWS cluster name, and Kubeflow deployment to be the same as cluster name. Set the path to the base directory where you want to store Kubeflow deployments. Then set the Kubeflow application directory for this deployment.
```
export AWS_CLUSTER_NAME=eksworkshop-eksctl
export KF_NAME=${AWS_CLUSTER_NAME}

export BASE_DIR=~/environment
export KF_DIR=${BASE_DIR}/${KF_NAME}
```
Until https://github.com/kubeflow/kubeflow/issues/3827 is fixed, install `aws-iam-authenticator`:

```
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin
```

Run **kfctl build** command to set up your configuraiton

```
mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl build -V -f ${CONFIG_URI}
```
Set an environment variable pointing to your local configuration file

```
export CONFIG_FILE=${KF_DIR}/kfctl_aws.0.7.0.yaml
```

Replace EKS Cluster Name and AWS Region in your $(CONFIG_FILE).
```
sed -i -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}
```
Replace Worker node IAM Roles in your $(CONFIG_FILE). Before we do that, let's check if we have ROLE_NAME in our environment variable
```
test -n "$ROLE_NAME" && echo ROLE_NAME is "$ROLE_NAME" || echo ROLE_NAME is not set
```
If you get ROLE_NAME is not set, run the commands from [export the Worker node role](https://eksworkshop.com/030_eksctl/test/#export-the-worker-role-name-for-use-throughout-the-workshop) and run the command again

Once you get proper response, run next command to replace with $ROLE_NAME
```
sed -i "s@eksctl-eksworkshop-eksctl-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@$ROLE_NAME@" ${CONFIG_FILE}
```

#### Deploy Kubeflow

Apply configuration and deploy Kubeflow on your cluster:

```
rm -rf kustomize
kfctl apply -V -f ${CONFIG_FILE}
```

Run below command to check the status

```
kubectl get pods -n kubeflow
```
{{% notice info %}}
Installing Kubeflow and its toolset may take 2 - 3 minutes. Few pods may initially give Error or CrashLoopBackOff status. Give it some time, they will auto-heal and will come to Running state
{{% /notice %}}

You should see similar results
{{< output >}}
NAME                                                           READY   STATUS    RESTARTS   AGE
admission-webhook-bootstrap-stateful-set-0                     1/1     Running   0          5m19s
admission-webhook-deployment-78d899bf68-bszdj                  1/1     Running   0          4m20s
alb-ingress-controller-6868b86fbf-dwjvm                        1/1     Running   0          5m13s
application-controller-stateful-set-0                          1/1     Running   0          5m20s
argo-ui-55b859f7d7-q5t45                                       1/1     Running   0          5m20s
centraldashboard-75474d6f94-w4smp                              1/1     Running   0          5m19s
jupyter-web-app-deployment-6c8f4c8997-kjwx7                    1/1     Running   0          5m19s
katib-controller-7ddd4c8b8c-ddbmd                              1/1     Running   1          5m16s
katib-db-7b679f6f8c-hlxdn                                      1/1     Running   0          5m16s
katib-manager-84c4fb876b-g758b                                 1/1     Running   0          5m16s
katib-ui-5d454c75c7-ghmh2                                      1/1     Running   0          5m16s
metacontroller-0                                               1/1     Running   0          5m20s
metadata-db-5dd459cc-64tm6                                     1/1     Running   0          5m18s
metadata-deployment-b745d8bcf-jfq8l                            1/1     Running   0          5m18s
metadata-deployment-b745d8bcf-kwn9r                            1/1     Running   0          5m18s
metadata-envoy-deployment-7ccf5c4f74-kl99k                     1/1     Running   0          5m18s
metadata-grpc-deployment-6496f66c8c-clbnq                      1/1     Running   5          5m18s
metadata-grpc-deployment-6496f66c8c-p6vhb                      1/1     Running   5          5m18s
metadata-ui-78f5b59b56-mdvmv                                   1/1     Running   0          5m18s
minio-6f48db9cc4-tvmjc                                         1/1     Running   0          5m16s
ml-pipeline-844645fd-sj8sc                                     1/1     Running   0          5m16s
ml-pipeline-ml-pipeline-visualizationserver-865894f5f7-bv8mk   1/1     Running   0          5m14s
ml-pipeline-persistenceagent-66f89b56d9-4s862                  1/1     Running   0          5m15s
ml-pipeline-scheduledworkflow-57445ddf88-b6np4                 1/1     Running   0          5m15s
ml-pipeline-ui-5c64b6c666-pczbk                                1/1     Running   0          5m15s
ml-pipeline-viewer-controller-deployment-7cc8d77468-l8qdz      1/1     Running   0          5m15s
mpi-operator-5bf8b566b7-92b6n                                  1/1     Running   0          5m13s
mysql-749f87bff5-zk26s                                         1/1     Running   0          5m15s
notebook-controller-deployment-6c887454f7-xr5gx                1/1     Running   0          5m17s
nvidia-device-plugin-daemonset-bhjwh                           1/1     Running   0          5m15s
nvidia-device-plugin-daemonset-ftcdr                           1/1     Running   0          5m15s
nvidia-device-plugin-daemonset-fzd8c                           1/1     Running   0          5m15s
profiles-deployment-67655ddbdd-68h6z                           2/2     Running   0          5m14s
pytorch-operator-84c58df794-xvdg2                              1/1     Running   0          5m17s
seldon-operator-controller-manager-0                           1/1     Running   1          5m16s
spartakus-volunteer-64cb78bbc5-4kb4f                           1/1     Running   0          5m17s
tensorboard-6544748d94-rpvd5                                   1/1     Running   0          5m17s
tf-job-operator-db676465c-vl6vh                                1/1     Running   0          5m17s
workflow-controller-676484d796-t8vjc                           1/1     Running   0          5m19s
{{< /output >}}
