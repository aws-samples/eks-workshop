---
title: "Install"
date: 2019-08-22T00:00:00-08:00
weight: 10
draft: false
---

In this chapter, we will install Kubeflow on Amazon EKS cluster. If you don't have an EKS cluster, please follow instructions from [getting started guide](/020_prerequisites) and then launch your EKS cluster using [eksctl](/030_eksctl) chapter

### Increase cluster size

We need more resources for completing the Kubeflow chapter of the EKS Workshop.
First, we'll increase the size of our cluster to 6 nodes

```
export NODEGROUP_NAME=$(eksctl get nodegroups --cluster eksworkshop-eksctl -o json | jq -r '.[0].Name')
eksctl scale nodegroup --cluster eksworkshop-eksctl --name $NODEGROUP_NAME --nodes 6
```
{{% notice info %}}
Scaling the nodegroup will take 2 - 3 minutes.
{{% /notice %}}

### Install Kubeflow on Amazon EKS

Download 1.0.1 release of `kfctl`. This binary will allow you to install Kubeflow on Amazon EKS

```
curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.0.1/kfctl_v1.0.1-0-gf3edb9b_linux.tar.gz" | tar xz -C /tmp
sudo mv -v /tmp/kfctl /usr/local/bin
```
#### Setup your configuration

Next step is to export environment variables needed for Kubeflow install.
{{% notice note %}}
We chose default kfctl configuration file for simplicity of workshop experience. However, we recommend to install Cognito configuration and add authentication and SSL (via ACM) for production. For additional steps needed to enable Cognito, please follow [Kubeflow documentation](https://www.kubeflow.org/docs/aws/deploy/install-kubeflow/)
{{% /notice %}}

```
cat << EoF > kf-install.sh
export AWS_CLUSTER_NAME=eksworkshop-eksctl
export KF_NAME=\${AWS_CLUSTER_NAME}

export BASE_DIR=/home/ec2-user/environment
export KF_DIR=\${BASE_DIR}/\${KF_NAME}

# export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws_cognito.v1.0.1.yaml"
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws.v1.0.1.yaml"

export CONFIG_FILE=\${KF_DIR}/kfctl_aws.yaml
EoF

source kf-install.sh
```
Create Kubeflow setup directory
```
mkdir -p ${KF_DIR}
cd ${KF_DIR}
```
Download configuration file
```
wget -O kfctl_aws.yaml $CONFIG_URI
```
We will use [IAM Roles for Service Account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in our configuration. IAM Roles for Service Account offers fine grained access control so that when Kubeflow interacts with AWS resources (such as ALB creation), it will use roles that are pre-defined by kfctl. kfctl will setup OIDC Identity Provider for your EKS cluster and create two IAM roles (**kf-admin-${AWS_CLUSTER_NAME}** and **kf-user-${AWS_CLUSTER_NAME}**) in your account. kfctl will then build trust relationship between OIDC endpoint and Kubernetes Service Accounts (SA) so that only SA can perform actions that are defined in the IAM role. Because we are using this feature, we will disable using IAM roles defined at the Worker nodes. In addition, we will replace EKS Cluster Name and AWS Region in your $(CONFIG_FILE).
```
sed -i '/region: us-west-2/ a \      enablePodIamPolicy: true' ${CONFIG_FILE}

sed -i -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}

sed -i "s@roles:@#roles:@" ${CONFIG_FILE}
sed -i "s@- eksctl-eksworkshop-eksctl-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@#- eksctl-eksworkshop-eksctl-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@" ${CONFIG_FILE}
```

Until https://github.com/kubeflow/kubeflow/issues/3827 is fixed, install aws-iam-authenticator
```
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin
```
#### Deploy Kubeflow

Apply configuration and deploy Kubeflow on your cluster:

```
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_FILE}
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
NAME                                                               READY   STATUS      RESTARTS   AGE
pod/admission-webhook-bootstrap-stateful-set-0                     1/1     Running     0          5m50s
pod/admission-webhook-deployment-64cb96ddbf-x2zfm                  1/1     Running     0          5m12s
pod/alb-ingress-controller-c76dd95d-z2kc7                          1/1     Running     0          5m45s
pod/application-controller-stateful-set-0                          1/1     Running     0          6m32s
pod/argo-ui-778676df64-w4lpj                                       1/1     Running     0          5m51s
pod/centraldashboard-7dd7dd685d-fjnr2                              1/1     Running     0          5m51s
pod/jupyter-web-app-deployment-89789fd5-pmwmf                      1/1     Running     0          5m50s
pod/katib-controller-6b789b6cb5-rc7xz                              1/1     Running     1          5m48s
pod/katib-db-manager-64f548b47c-6p6nv                              1/1     Running     0          5m48s
pod/katib-mysql-57884cb488-6g9zk                                   1/1     Running     0          5m48s
pod/katib-ui-5c5cc6bd77-mwmrl                                      1/1     Running     0          5m48s
pod/metacontroller-0                                               1/1     Running     0          5m51s
pod/metadata-db-76c9f78f77-pjvh8                                   1/1     Running     0          5m49s
pod/metadata-deployment-674fdd976b-946k6                           1/1     Running     0          5m49s
pod/metadata-envoy-deployment-5688989bd6-j5bdh                     1/1     Running     0          5m49s
pod/metadata-grpc-deployment-5579bdc87b-fc88k                      1/1     Running     2          5m49s
pod/metadata-ui-9b8cd699d-drm2p                                    1/1     Running     0          5m49s
pod/minio-755ff748b-hdfwk                                          1/1     Running     0          5m47s
pod/ml-pipeline-79b4f85cbc-hcttq                                   1/1     Running     5          5m47s
pod/ml-pipeline-ml-pipeline-visualizationserver-5fdffdc5bf-nqjb5   1/1     Running     0          5m46s
pod/ml-pipeline-persistenceagent-645cb66874-rgrt4                  1/1     Running     1          5m47s
pod/ml-pipeline-scheduledworkflow-6c978b6b85-dxgw4                 1/1     Running     0          5m46s
pod/ml-pipeline-ui-6995b7bccf-ktwb2                                1/1     Running     0          5m47s
pod/ml-pipeline-viewer-controller-deployment-8554dc7b9f-n4ccc      1/1     Running     0          5m46s
pod/mpi-operator-5bf8b566b7-gkbz9                                  1/1     Running     0          5m45s
pod/mysql-598bc897dc-srtpt                                         1/1     Running     0          5m47s
pod/notebook-controller-deployment-7db57b9ccf-4pqkw                1/1     Running     0          5m49s
pod/nvidia-device-plugin-daemonset-4s9tv                           1/1     Running     0          5m46s
pod/nvidia-device-plugin-daemonset-5p8kn                           1/1     Running     0          5m46s
pod/nvidia-device-plugin-daemonset-84jv6                           1/1     Running     0          5m46s
pod/nvidia-device-plugin-daemonset-d7x5f                           1/1     Running     0          5m46s
pod/nvidia-device-plugin-daemonset-m8cpr                           1/1     Running     0          5m46s
pod/profiles-deployment-b45dbc6f-7jfqw                             2/2     Running     0          5m46s
pod/pytorch-operator-5fd5f94bdd-dbddk                              1/1     Running     0          5m49s
pod/seldon-controller-manager-679fc777cd-58vzl                     1/1     Running     0          5m45s
pod/spark-operatorcrd-cleanup-tc4nw                                0/2     Completed   0          5m50s
pod/spark-operatorsparkoperator-c7b64b87f-w6glw                    1/1     Running     0          5m50s
pod/spartakus-volunteer-5b7d86d9cd-2z4dn                           1/1     Running     0          5m49s
pod/tensorboard-6544748d94-dr87g                                   1/1     Running     0          5m48s
pod/tf-job-operator-7d7c8fb8bb-bh2j9                               1/1     Running     0          5m48s
pod/workflow-controller-945c84565-ctx84                            1/1     Running     0          5m51s

NAME                                                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/admission-webhook-service                     ClusterIP   10.100.34.137    <none>        443/TCP             5m50s
service/application-controller-service                ClusterIP   10.100.122.252   <none>        443/TCP             6m32s
service/argo-ui                                       NodePort    10.100.56.77     <none>        80:32722/TCP        5m51s
service/centraldashboard                              ClusterIP   10.100.122.184   <none>        80/TCP              5m51s
service/jupyter-web-app-service                       ClusterIP   10.100.184.50    <none>        80/TCP              5m50s
service/katib-controller                              ClusterIP   10.100.96.16     <none>        443/TCP,8080/TCP    5m48s
service/katib-db-manager                              ClusterIP   10.100.161.38    <none>        6789/TCP            5m48s
service/katib-mysql                                   ClusterIP   10.100.186.115   <none>        3306/TCP            5m48s
service/katib-ui                                      ClusterIP   10.100.110.39    <none>        80/TCP              5m48s
service/metadata-db                                   ClusterIP   10.100.92.177    <none>        3306/TCP            5m49s
service/metadata-envoy-service                        ClusterIP   10.100.17.145    <none>        9090/TCP            5m49s
service/metadata-grpc-service                         ClusterIP   10.100.238.212   <none>        8080/TCP            5m49s
service/metadata-service                              ClusterIP   10.100.183.244   <none>        8080/TCP            5m49s
service/metadata-ui                                   ClusterIP   10.100.28.97     <none>        80/TCP              5m49s
service/minio-service                                 ClusterIP   10.100.185.36    <none>        9000/TCP            5m48s
service/ml-pipeline                                   ClusterIP   10.100.45.162    <none>        8888/TCP,8887/TCP   5m48s
service/ml-pipeline-ml-pipeline-visualizationserver   ClusterIP   10.100.211.60    <none>        8888/TCP            5m47s
service/ml-pipeline-tensorboard-ui                    ClusterIP   10.100.150.113   <none>        80/TCP              5m47s
service/ml-pipeline-ui                                ClusterIP   10.100.135.60    <none>        80/TCP              5m47s
service/mysql                                         ClusterIP   10.100.37.144    <none>        3306/TCP            5m48s
service/notebook-controller-service                   ClusterIP   10.100.250.183   <none>        443/TCP             5m49s
service/profiles-kfam                                 ClusterIP   10.100.24.246    <none>        8081/TCP            5m47s
service/pytorch-operator                              ClusterIP   10.100.104.208   <none>        8443/TCP            5m49s
service/seldon-webhook-service                        ClusterIP   10.100.68.153    <none>        443/TCP             5m46s
service/tensorboard                                   ClusterIP   10.100.25.5      <none>        9000/TCP            5m49s
service/tf-job-operator                               ClusterIP   10.100.165.41    <none>        8443/TCP            5m48s

NAME                                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/nvidia-device-plugin-daemonset   5         5         5       5            5           <none>          5m46s

NAME                                                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/admission-webhook-deployment                  1/1     1            1           5m50s
deployment.apps/alb-ingress-controller                        1/1     1            1           5m46s
deployment.apps/argo-ui                                       1/1     1            1           5m51s
deployment.apps/centraldashboard                              1/1     1            1           5m51s
deployment.apps/jupyter-web-app-deployment                    1/1     1            1           5m50s
deployment.apps/katib-controller                              1/1     1            1           5m48s
deployment.apps/katib-db-manager                              1/1     1            1           5m48s
deployment.apps/katib-mysql                                   1/1     1            1           5m48s
deployment.apps/katib-ui                                      1/1     1            1           5m48s
deployment.apps/metadata-db                                   1/1     1            1           5m49s
deployment.apps/metadata-deployment                           1/1     1            1           5m49s
deployment.apps/metadata-envoy-deployment                     1/1     1            1           5m49s
deployment.apps/metadata-grpc-deployment                      1/1     1            1           5m49s
deployment.apps/metadata-ui                                   1/1     1            1           5m49s
deployment.apps/minio                                         1/1     1            1           5m48s
deployment.apps/ml-pipeline                                   1/1     1            1           5m48s
deployment.apps/ml-pipeline-ml-pipeline-visualizationserver   1/1     1            1           5m47s
deployment.apps/ml-pipeline-persistenceagent                  1/1     1            1           5m48s
deployment.apps/ml-pipeline-scheduledworkflow                 1/1     1            1           5m47s
deployment.apps/ml-pipeline-ui                                1/1     1            1           5m47s
deployment.apps/ml-pipeline-viewer-controller-deployment      1/1     1            1           5m47s
deployment.apps/mpi-operator                                  1/1     1            1           5m46s
deployment.apps/mysql                                         1/1     1            1           5m48s
deployment.apps/notebook-controller-deployment                1/1     1            1           5m49s
deployment.apps/profiles-deployment                           1/1     1            1           5m47s
deployment.apps/pytorch-operator                              1/1     1            1           5m49s
deployment.apps/seldon-controller-manager                     1/1     1            1           5m46s
deployment.apps/spark-operatorsparkoperator                   1/1     1            1           5m50s
deployment.apps/spartakus-volunteer                           1/1     1            1           5m49s
deployment.apps/tensorboard                                   1/1     1            1           5m49s
deployment.apps/tf-job-operator                               1/1     1            1           5m48s
deployment.apps/workflow-controller                           1/1     1            1           5m51s

NAME                                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/admission-webhook-deployment-64cb96ddbf                  1         1         1       5m50s
replicaset.apps/alb-ingress-controller-c76dd95d                          1         1         1       5m45s
replicaset.apps/argo-ui-778676df64                                       1         1         1       5m51s
replicaset.apps/centraldashboard-7dd7dd685d                              1         1         1       5m51s
replicaset.apps/jupyter-web-app-deployment-89789fd5                      1         1         1       5m50s
replicaset.apps/katib-controller-6b789b6cb5                              1         1         1       5m48s
replicaset.apps/katib-db-manager-64f548b47c                              1         1         1       5m48s
replicaset.apps/katib-mysql-57884cb488                                   1         1         1       5m48s
replicaset.apps/katib-ui-5c5cc6bd77                                      1         1         1       5m48s
replicaset.apps/metadata-db-76c9f78f77                                   1         1         1       5m49s
replicaset.apps/metadata-deployment-674fdd976b                           1         1         1       5m49s
replicaset.apps/metadata-envoy-deployment-5688989bd6                     1         1         1       5m49s
replicaset.apps/metadata-grpc-deployment-5579bdc87b                      1         1         1       5m49s
replicaset.apps/metadata-ui-9b8cd699d                                    1         1         1       5m49s
replicaset.apps/minio-755ff748b                                          1         1         1       5m47s
replicaset.apps/ml-pipeline-79b4f85cbc                                   1         1         1       5m47s
replicaset.apps/ml-pipeline-ml-pipeline-visualizationserver-5fdffdc5bf   1         1         1       5m46s
replicaset.apps/ml-pipeline-persistenceagent-645cb66874                  1         1         1       5m47s
replicaset.apps/ml-pipeline-scheduledworkflow-6c978b6b85                 1         1         1       5m46s
replicaset.apps/ml-pipeline-ui-6995b7bccf                                1         1         1       5m47s
replicaset.apps/ml-pipeline-viewer-controller-deployment-8554dc7b9f      1         1         1       5m46s
replicaset.apps/mpi-operator-5bf8b566b7                                  1         1         1       5m45s
replicaset.apps/mysql-598bc897dc                                         1         1         1       5m47s
replicaset.apps/notebook-controller-deployment-7db57b9ccf                1         1         1       5m49s
replicaset.apps/profiles-deployment-b45dbc6f                             1         1         1       5m46s
replicaset.apps/pytorch-operator-5fd5f94bdd                              1         1         1       5m49s
replicaset.apps/seldon-controller-manager-679fc777cd                     1         1         1       5m45s
replicaset.apps/spark-operatorsparkoperator-c7b64b87f                    1         1         1       5m50s
replicaset.apps/spartakus-volunteer-5b7d86d9cd                           1         1         1       5m49s
replicaset.apps/tensorboard-6544748d94                                   1         1         1       5m48s
replicaset.apps/tf-job-operator-7d7c8fb8bb                               1         1         1       5m48s
replicaset.apps/workflow-controller-945c84565                            1         1         1       5m51s

NAME                                                        READY   AGE
statefulset.apps/admission-webhook-bootstrap-stateful-set   1/1     5m50s
statefulset.apps/application-controller-stateful-set        1/1     6m32s
statefulset.apps/metacontroller                             1/1     5m51s

NAME                                  COMPLETIONS   DURATION   AGE
job.batch/spark-operatorcrd-cleanup   1/1           42s        5m50s
```
{{% /expand %}}
