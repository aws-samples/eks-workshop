---
title: "Install"
date: 2022-07-16T00:00:00-08:00
weight: 10
draft: false
---

### Prerequisites
Everything you need to get started with Kubeflow on AWS

#### Install the necessary tools
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - A command line tool for interacting with AWS services.
- [eksctl](https://eksctl.io/introduction/#installation) - A command line tool for working with EKS clusters.
- [kubectl](https://kubernetes.io/docs/tasks/tools) - A command line tool for working with Kubernetes clusters.
- [yq](https://mikefarah.gitbook.io/yq) - A command line tool for YAML processing. (For Linux environments, use the [wget plain binary installation](https://github.com/mikefarah/yq/#install))
- [jq](https://stedolan.github.io/jq/download/) - A command line tool for processing JSON.
- [kustomize version 3.2.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/v3.2.0) - A command line tool to customize Kubernetes objects through a kustomization file.
> Warning: Kubeflow is not compatible with the latest versions of of kustomize 4.x. This is due to changes in the order that resources are sorted and printed. Please see [kubernetes-sigs/kustomize#3794](https://github.com/kubernetes-sigs/kustomize/issues/3794) and [kubeflow/manifests#1797](https://github.com/kubeflow/manifests/issues/1797). We know that this is not ideal and are working with the upstream kustomize team to add support for the latest versions of kustomize as soon as we can.
- [python 3.8+](https://www.python.org/downloads/) - A programming language used for automated installation scripts.
- [pip](https://pip.pypa.io/en/stable/installation/) - A package installer for python.

#### Create an EKS cluster
> Note: Be sure to check [Amazon EKS and Kubeflow Compatibility](https://awslabs.github.io/kubeflow-manifests/release-v1.5.1-aws-b1.0.0/docs/about/eks-compatibility/) when creating your cluster with specific EKS versions.

If you do not have an existing cluster, run the following command to create an EKS cluster.

> Note: Various controllers use IAM roles for service accounts (IRSA). An [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) must exist for your cluster to use IRSA.

Set `CLUSTER_NAME` and `CLUSTER_REGION` environment variables: 
```bash
export CLUSTER_NAME=eksworkshop
export CLUSTER_REGION=us-east-1
```

Run the following command to create an EKS cluster:
```bash
eksctl create cluster \
--name ${CLUSTER_NAME} \
--version 1.21 \
--region ${CLUSTER_REGION} \
--nodegroup-name linux-nodes \
--node-type m6a.xlarge \
--nodes 5 \
--nodes-min 5 \
--nodes-max 10 \
--managed \
--with-oidc
```

If you are using an existing EKS cluster, create an [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) and associate it with for your EKS cluster with the following command:
```bash
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} \
--region ${CLUSTER_REGION} --approve
```
More details about cluster creation via `eksctl` can be found in the [Creating and managing clusters](https://eksctl.io/usage/creating-and-managing-clusters/) guide.

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

### Install Kubeflow on Amazon EKS
This guide describes how to deploy Kubeflow on AWS EKS. This vanilla version has minimal changes to the upstream Kubeflow manifests.
#### Build Manifests and install Kubeflow

There two options for installing Kubeflow official components and common services with kustomize.

1. Single-command installation of all components under `apps` and `common`
2. Multi-command, individual components installation for `apps` and `common`

Option 1 targets ease of deployment for end users. \
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

Once everything is installed successfully, you can access the Kubeflow Central Dashboard [by logging into your cluster](#connect-to-your-kubeflow-cluster).

You can now start experimenting and running your end-to-end ML workflows with Kubeflow!

#### Install individual components

This section lists an installation command for each official Kubeflow component (under `apps`) and each common service (under `common`) using just `kubectl` and `kustomize`.

If you run all of the following commands, the end result is the same as installing everything through the [single command installation](#install-with-a-single-command). 

The purpose of this section is to:
- Provide a description of each component and insight on how it gets installed.
- Enable the user or distribution owner to pick and choose only the components they need.

##### cert-manager

`cert-manager` is used by many Kubeflow components to provide certificates for
admission webhooks.

Install `cert-manager`:

```sh
kustomize build upstream/common/cert-manager/cert-manager/base | kubectl apply -f -
kustomize build upstream/common/cert-manager/kubeflow-issuer/base | kubectl apply -f -
```

##### Istio

Istio is used by many Kubeflow components to secure their traffic, enforce
network authorization, and implement routing policies.

Install Istio:

```sh
kustomize build upstream/common/istio-1-11/istio-crds/base | kubectl apply -f -
kustomize build upstream/common/istio-1-11/istio-namespace/base | kubectl apply -f -
kustomize build upstream/common/istio-1-11/istio-install/base | kubectl apply -f -
```

##### Dex

Dex is an OpenID Connect Identity (OIDC) with multiple authentication backends. In this default installation, it includes a static user with the email `user@example.com`. By default, the user's password is `12341234`. For any production Kubeflow deployment, you should change the default password by following the steps in [Change default user password](#change-default-user-password).

Install Dex:

```sh
kustomize build upstream/common/dex/overlays/istio | kubectl apply -f -
```

##### OIDC AuthService

The OIDC AuthService extends your Istio Ingress-Gateway capabilities to be able to function as an OIDC client:

Install OIDC AuthService:

```sh
kustomize build upstream/common/oidc-authservice/base | kubectl apply -f -
```

##### Knative

Knative is used by the KServe/KFServing official Kubeflow component.

Install Knative Serving:

```sh
kustomize build upstream/common/knative/knative-serving/base | kubectl apply -f -
kustomize build upstream/common/istio-1-11/cluster-local-gateway/base | kubectl apply -f -
```

Optionally, you can install Knative Eventing, which can be used for inference request logging.

Install Knative Eventing:

```sh
kustomize build upstream/common/knative/knative-eventing/base | kubectl apply -f -
```

##### Kubeflow namespace

Create the namespace where the Kubeflow components will live. This namespace
is named `kubeflow`.

Install the `kubeflow` namespace:

```sh
kustomize build upstream/common/kubeflow-namespace/base | kubectl apply -f -
```

##### Kubeflow Roles

Create the Kubeflow ClusterRoles `kubeflow-view`, `kubeflow-edit`, and
`kubeflow-admin`. Kubeflow components aggregate permissions to these
ClusterRoles.

Install Kubeflow roles:

```sh
kustomize build upstream/common/kubeflow-roles/base | kubectl apply -f -
```

##### Kubeflow Istio Resources

Create the Istio resources needed by Kubeflow. This kustomization currently
creates an Istio Gateway named `kubeflow-gateway` in the `kubeflow` namespace.
If you want to install with your own Istio, then you need this kustomization as
well.

Install Istio resources:

```sh
kustomize build upstream/common/istio-1-11/kubeflow-istio-resources/base | kubectl apply -f -
```

##### Kubeflow Pipelines

Install the [Multi-User Kubeflow Pipelines](https://www.kubeflow.org/docs/components/pipelines/multi-user/) official Kubeflow component:

```sh
kustomize build upstream/apps/pipeline/upstream/env/cert-manager/platform-agnostic-multi-user | kubectl apply -f -
```

##### KServe / KFServing

KFServing was rebranded to KServe.

Install the KServe component:

```sh
kustomize build awsconfigs/apps/kserve | kubectl apply -f -
```

Install the Models web app:

```sh
kustomize build upstream/contrib/kserve/models-web-app/overlays/kubeflow | kubectl apply -f -
```

For those not ready to migrate to KServe, you can still install KFServing v0.6.1 with
the following command, but we recommend migrating to KServe as soon as possible:

```sh
kustomize build upstream/apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -
```

##### Katib

Install the Katib official Kubeflow component:

```sh
kustomize build upstream/apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -
```

##### Central Dashboard

Install the Central Dashboard official Kubeflow component:

```sh
kustomize build upstream/apps/centraldashboard/upstream/overlays/kserve | kubectl apply -f -
```

##### Admission Webhook

Install the Admission Webhook for PodDefaults:

```sh
kustomize build upstream/apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -
```

##### Notebooks

Install the Notebook Controller official Kubeflow component:

```sh
kustomize build upstream/apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -
```

Install the Jupyter Web App official Kubeflow component:

```sh
kustomize build awsconfigs/apps/jupyter-web-app | kubectl apply -f -
```

##### Profiles and Kubeflow Access-Management (KFAM)

Install the Profile controller and the Kubeflow Access-Management (KFAM) official Kubeflow
components:

```sh
kustomize build upstream/apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -
```

##### Volumes Web App

Install the Volumes Web App official Kubeflow component:

```sh
kustomize build upstream/apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -
```

##### Tensorboard

Install the Tensorboards Web App official Kubeflow component:

```sh
kustomize build upstream/apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
```

Install the Tensorboard controller official Kubeflow component:

```sh
kustomize build upstream/apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -
```

##### Training Operator

Install the Training Operator official Kubeflow component:

```sh
kustomize build upstream/apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -
```

##### AWS Telemetry

Install the AWS Kubeflow telemetry component. This is an optional component. See [Usage Tracking](https://awslabs.github.io/kubeflow-manifests/release-v1.5.1-aws-b1.0.0/docs/about/usage-tracking/) for more information

```sh
kustomize build awsconfigs/common/aws-telemetry | kubectl apply -f -
```

##### User namespace

Finally, create a new namespace for the the default user. In this example, the namespace is called `kubeflow-user-example-com`.

```sh
kustomize build upstream/common/user-namespace/base | kubectl apply -f -
```

#### Connect to your Kubeflow cluster

After installation, it will take some time for all Pods to become ready. Make sure all Pods are ready before trying to connect, otherwise you might get unexpected errors. To check that all Kubeflow-related Pods are ready, use the following commands:

```sh
kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com
# Depending on your installation if you installed KServe
kubectl get pods -n kserve
```

##### Port-Forward

To get started quickly, you can access Kubeflow via port-forward. Run the following to port-forward Istio's Ingress-Gateway to local port `8080`:

```sh
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

After running the command, you can access the Kubeflow Central Dashboard by doing the following:

1. Open your browser and visit `http://localhost:8080`. You should get the Dex login screen.
2. Login with the default user's credential. The default email address is `user@example.com` and the default password is `12341234`.

##### Exposing Kubeflow over Load Balancer

In order to expose Kubeflow over an external address, you can set up AWS Application Load Balancer. Please take a look at the [Load Balancer guide](https://awslabs.github.io/kubeflow-manifests/release-v1.5.1-aws-b1.0.0/docs/deployment/add-ons/load-balancer/guide/) to set it up.

#### Change default user password

For security reasons, we do not recommend using the default password for the default Kubeflow user when installing in security-sensitive environments. Instead, you should define your own password before deploying. To define a password for the default user:

1. Pick a password for the default user, with email `user@example.com`, and hash it using `bcrypt`:

    ```sh
    python3 -c 'from passlib.hash import bcrypt; import getpass; print(bcrypt.using(rounds=12, ident="2y").hash(getpass.getpass()))'
    ```

2. Edit `upstream/common/dex/base/config-map.yaml` and fill the relevant field with the hash of the password you chose:

    ```yaml
    ...
      staticPasswords:
      - email: user@example.com
        hash: <enter the generated hash here>
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
pod/admission-webhook-deployment-7df7558c67-94js5                1/1     Running   0          115s
pod/cache-server-5bdbd59959-q74km                                2/2     Running   0          115s
pod/centraldashboard-79f489b55-mclgr                             2/2     Running   0          114s
pod/jupyter-web-app-deployment-7cd59c5c95-4g54h                  1/1     Running   0          112s
pod/katib-controller-58ddb4b856-22m58                            1/1     Running   0          115s
pod/katib-db-manager-d77c6757f-pk4g8                             1/1     Running   0          114s
pod/katib-mysql-7894994f88-v7xrz                                 1/1     Running   0          114s
pod/katib-ui-f787b9d88-g5vfd                                     1/1     Running   0          113s
pod/kfserving-controller-manager-0                               2/2     Running   0          105s
pod/kfserving-models-web-app-7884f597cf-rn62n                    2/2     Running   0          112s
pod/kserve-models-web-app-5c64c8d8bb-vmmk7                       2/2     Running   0          115s
pod/kubeflow-pipelines-profile-controller-84bcbdb899-ghlgj       1/1     Running   0          114s
pod/metacontroller-0                                             1/1     Running   0          105s
pod/metadata-envoy-deployment-86d856fc6-bq4bg                    1/1     Running   0          113s
pod/metadata-grpc-deployment-f8d68f687-pkj5z                     2/2     Running   3          113s
pod/metadata-writer-d7ff8d4bc-s5zkw                              2/2     Running   0          113s
pod/minio-5b65df66c9-wmd9m                                       2/2     Running   0          112s
pod/ml-pipeline-7499f55b46-4xvxn                                 2/2     Running   0          111s
pod/ml-pipeline-persistenceagent-7bf47b869c-bdmlh                2/2     Running   0          115s
pod/ml-pipeline-scheduledworkflow-565fd7846-q95kl                2/2     Running   0          114s
pod/ml-pipeline-ui-77477f77dc-xzrvr                              2/2     Running   0          114s
pod/ml-pipeline-viewer-crd-68bcdc87f9-rmmbm                      2/2     Running   1          114s
pod/ml-pipeline-visualizationserver-7bc59978d-8ss4l              2/2     Running   0          113s
pod/mysql-f7b9b7dd4-7rbdx                                        2/2     Running   0          113s
pod/notebook-controller-deployment-7474fbff66-9ghkn              2/2     Running   1          112s
pod/profiles-deployment-5cc86bc965-wxhrb                         3/3     Running   1          112s
pod/tensorboard-controller-controller-manager-5cbddb7fb5-mrrh8   3/3     Running   1          112s
pod/tensorboards-web-app-deployment-7c5db448d7-fgkxg             1/1     Running   0          116s
pod/training-operator-6bfc7b8d86-f8x2s                           1/1     Running   0          115s
pod/volumes-web-app-deployment-87484c848-xthgj                   1/1     Running   0          115s
pod/workflow-controller-5cb67bb9db-wbbjc                         2/2     Running   1          115s

NAME                                                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
service/admission-webhook-service                                   ClusterIP   10.100.144.241   <none>        443/TCP             2m9s
service/cache-server                                                ClusterIP   10.100.184.56    <none>        443/TCP             2m9s
service/centraldashboard                                            ClusterIP   10.100.16.140    <none>        80/TCP              2m9s
service/jupyter-web-app-service                                     ClusterIP   10.100.74.127    <none>        80/TCP              2m9s
service/katib-controller                                            ClusterIP   10.100.131.90    <none>        443/TCP,8080/TCP    2m9s
service/katib-db-manager                                            ClusterIP   10.100.215.172   <none>        6789/TCP            2m9s
service/katib-mysql                                                 ClusterIP   10.100.145.60    <none>        3306/TCP            2m9s
service/katib-ui                                                    ClusterIP   10.100.185.103   <none>        80/TCP              2m9s
service/kfserving-controller-manager-metrics-service                ClusterIP   10.100.48.0      <none>        8443/TCP            2m9s
service/kfserving-controller-manager-service                        ClusterIP   10.100.52.4      <none>        443/TCP             2m9s
service/kfserving-models-web-app                                    ClusterIP   10.100.202.254   <none>        80/TCP              2m9s
service/kfserving-webhook-server-service                            ClusterIP   10.100.145.238   <none>        443/TCP             2m9s
service/kserve-models-web-app                                       ClusterIP   10.100.229.163   <none>        80/TCP              2m9s
service/kubeflow-pipelines-profile-controller                       ClusterIP   10.100.147.104   <none>        80/TCP              2m9s
service/metadata-envoy-service                                      ClusterIP   10.100.32.232    <none>        9090/TCP            2m9s
service/metadata-grpc-service                                       ClusterIP   10.100.134.190   <none>        8080/TCP            2m9s
service/minio-service                                               ClusterIP   10.100.92.221    <none>        9000/TCP            2m9s
service/ml-pipeline                                                 ClusterIP   10.100.151.243   <none>        8888/TCP,8887/TCP   2m9s
service/ml-pipeline-ui                                              ClusterIP   10.100.124.135   <none>        80/TCP              2m9s
service/ml-pipeline-visualizationserver                             ClusterIP   10.100.142.117   <none>        8888/TCP            2m8s
service/mysql                                                       ClusterIP   10.100.197.250   <none>        3306/TCP            2m8s
service/notebook-controller-service                                 ClusterIP   10.100.197.237   <none>        443/TCP             2m8s
service/profiles-kfam                                               ClusterIP   10.100.46.151    <none>        8081/TCP            2m8s
service/tensorboard-controller-controller-manager-metrics-service   ClusterIP   10.100.224.80    <none>        8443/TCP            2m8s
service/tensorboards-web-app-service                                ClusterIP   10.100.25.37     <none>        80/TCP              2m8s
service/training-operator                                           ClusterIP   10.100.13.97     <none>        8080/TCP            2m8s
service/volumes-web-app-service                                     ClusterIP   10.100.249.86    <none>        80/TCP              2m8s
service/workflow-controller-metrics                                 ClusterIP   10.100.5.160     <none>        9090/TCP            2m8s

NAME                                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/admission-webhook-deployment                1/1     1            1           2m7s
deployment.apps/cache-server                                1/1     1            1           2m7s
deployment.apps/centraldashboard                            1/1     1            1           2m7s
deployment.apps/jupyter-web-app-deployment                  1/1     1            1           2m7s
deployment.apps/katib-controller                            1/1     1            1           2m7s
deployment.apps/katib-db-manager                            1/1     1            1           2m7s
deployment.apps/katib-mysql                                 1/1     1            1           2m7s
deployment.apps/katib-ui                                    1/1     1            1           2m7s
deployment.apps/kfserving-models-web-app                    1/1     1            1           2m7s
deployment.apps/kserve-models-web-app                       1/1     1            1           2m7s
deployment.apps/kubeflow-pipelines-profile-controller       1/1     1            1           2m7s
deployment.apps/metadata-envoy-deployment                   1/1     1            1           2m7s
deployment.apps/metadata-grpc-deployment                    1/1     1            1           2m7s
deployment.apps/metadata-writer                             1/1     1            1           2m7s
deployment.apps/minio                                       1/1     1            1           2m7s
deployment.apps/ml-pipeline                                 1/1     1            1           2m7s
deployment.apps/ml-pipeline-persistenceagent                1/1     1            1           2m7s
deployment.apps/ml-pipeline-scheduledworkflow               1/1     1            1           2m7s
deployment.apps/ml-pipeline-ui                              1/1     1            1           2m7s
deployment.apps/ml-pipeline-viewer-crd                      1/1     1            1           2m7s
deployment.apps/ml-pipeline-visualizationserver             1/1     1            1           2m7s
deployment.apps/mysql                                       1/1     1            1           2m7s
deployment.apps/notebook-controller-deployment              1/1     1            1           2m7s
deployment.apps/profiles-deployment                         1/1     1            1           2m7s
deployment.apps/tensorboard-controller-controller-manager   1/1     1            1           2m7s
deployment.apps/tensorboards-web-app-deployment             1/1     1            1           2m7s
deployment.apps/training-operator                           1/1     1            1           2m6s
deployment.apps/volumes-web-app-deployment                  1/1     1            1           2m6s
deployment.apps/workflow-controller                         1/1     1            1           2m6s

NAME                                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/admission-webhook-deployment-7df7558c67                1         1         1       2m5s
replicaset.apps/cache-server-5bdbd59959                                1         1         1       2m5s
replicaset.apps/centraldashboard-79f489b55                             1         1         1       2m5s
replicaset.apps/jupyter-web-app-deployment-7cd59c5c95                  1         1         1       2m5s
replicaset.apps/katib-controller-58ddb4b856                            1         1         1       2m4s
replicaset.apps/katib-db-manager-d77c6757f                             1         1         1       2m4s
replicaset.apps/katib-mysql-7894994f88                                 1         1         1       2m4s
replicaset.apps/katib-ui-f787b9d88                                     1         1         1       2m4s
replicaset.apps/kfserving-models-web-app-7884f597cf                    1         1         1       2m4s
replicaset.apps/kserve-models-web-app-5c64c8d8bb                       1         1         1       2m4s
replicaset.apps/kubeflow-pipelines-profile-controller-84bcbdb899       1         1         1       2m3s
replicaset.apps/metadata-envoy-deployment-86d856fc6                    1         1         1       2m3s
replicaset.apps/metadata-grpc-deployment-f8d68f687                     1         1         1       2m3s
replicaset.apps/metadata-writer-d7ff8d4bc                              1         1         1       2m3s
replicaset.apps/minio-5b65df66c9                                       1         1         1       2m3s
replicaset.apps/ml-pipeline-7499f55b46                                 1         1         1       2m2s
replicaset.apps/ml-pipeline-persistenceagent-7bf47b869c                1         1         1       2m2s
replicaset.apps/ml-pipeline-scheduledworkflow-565fd7846                1         1         1       2m2s
replicaset.apps/ml-pipeline-ui-77477f77dc                              1         1         1       2m2s
replicaset.apps/ml-pipeline-viewer-crd-68bcdc87f9                      1         1         1       2m2s
replicaset.apps/ml-pipeline-visualizationserver-7bc59978d              1         1         1       2m1s
replicaset.apps/mysql-f7b9b7dd4                                        1         1         1       2m1s
replicaset.apps/notebook-controller-deployment-7474fbff66              1         1         1       2m1s
replicaset.apps/profiles-deployment-5cc86bc965                         1         1         1       2m1s
replicaset.apps/tensorboard-controller-controller-manager-5cbddb7fb5   1         1         1       2m1s
replicaset.apps/tensorboards-web-app-deployment-7c5db448d7             1         1         1       2m
replicaset.apps/training-operator-6bfc7b8d86                           1         1         1       2m
replicaset.apps/volumes-web-app-deployment-87484c848                   1         1         1       2m
replicaset.apps/workflow-controller-5cb67bb9db                         1         1         1       2m

NAME                                            READY   AGE
statefulset.apps/kfserving-controller-manager   1/1     2m6s
statefulset.apps/metacontroller                 1/1     2m6s

NAME                                   SCHEDULE    SUSPEND   ACTIVE   LAST SCHEDULE   AGE
cronjob.batch/aws-kubeflow-telemetry   0 0 * * *   False     0        <none>          2m6s
```
{{% /expand %}}
