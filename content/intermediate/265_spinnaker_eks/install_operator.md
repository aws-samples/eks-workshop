---
title: "Install Spinnaker Operator"
weight: 20
draft: false
---

There are several methods to install open source Spinnaker on EKS/Kubernetes:
- [Halyard](https://spinnaker.io/setup/install/)
- [Operator](https://github.com/armory/spinnaker-operator)
- [Kleat](https://github.com/spinnaker/kleat) intended to replace Halyard (under active development)

In this workshop we will be using Spinnaker **Operator**, a Kubernetes Operator for managing Spinnaker, built by [Armory](https://docs.armory.io/docs/installation/operator/). 
The Operator makes managing Spinnaker, which runs in Kubernetes, dramatically simpler and more automated, while introducing new Kubernetes-native features. The current tool (Halyard) involved significant manual processes and requires Spinnaker domain expertise. 

In contrast, the Operator lets you treat Spinnaker as just another Kubernetes deployment, which makes installing and managing Spinnaker easy and reliable. 
The Operator unlocks the scalability of a GitOps workflow by defining Spinnaker configurations in a code repository rather than in hal commands.

More details on the benefits of Sipnnaker Operator can be found in [Armory Docs](https://www.armory.io/spinnaker-community/spinnaker-operator/)

#### PreRequisite

* We assume that we have an existing EKS Cluster eksworkshop-eksctl created from [EKS Workshop](/030_eksctl/launcheks/).

* We also assume that we have [increased the disk size on your Cloud9 instance](/020_prerequisites/workspace/#increase-the-disk-size-on-the-cloud9-instance) as we need to build docker images for our application.

* [Optional] If you want to use AWS Console to navigate and explore resources in Amazon EKS ensure that you have completed [Console Credentials](/030_eksctl/console/) to get full access to the EKS Cluster in the EKS console.

* We also have installed the prequisite for EKS Cluster installation based on the instructions [here](/030_eksctl/prerequisites/)

* And we have also validated the IAM role in use by the Cloud9 IDE based on the intructions [here](020_prerequisites/workspaceiam/#validate-the-iam-role)

* Ensure you are getting the IAM role that you have attached to Cloud9 IDE when you execute the below command

```sh
aws sts get-caller-identity
```
{{< output >}}
{
	"Account": "XXXXXXX", 
	"UserId": "YYYYYYYY:i-009b2d423b1386a74", 
	"Arn": "arn:aws:sts::XXXXXXX:assumed-role/eksworkshop-admin-s/i-009b2d423b1386a74"
}
{{< /output >}}

* Check if AWS_REGION and ACCOUNT_ID are set correctly
```sh
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
test -n "$ACCOUNT_ID" && echo ACCOUNT_ID is "$ACCOUNT_ID" || echo ACCOUNT_ID is not set
```
If not, export the ACCOUNT_ID and AWS_REGION to ENV
{{< output >}}
export ACCOUNT_ID=<your_account_id>
export AWS_REGION=<your_aws_region>
{{< /output >}}


#### EKS cluster setup

We need bigger instance type for installing spinnaker services, hence we are creating new EKS cluster.
{{% notice info %}}
We are also deleting the existng nodegroup `nodegroup` that was created as part of cluster creation as we need Spinnaker Operator to create the services in the new nodegroup `spinnaker`
{{% /notice %}}
```
cat << EOF > spinnakerworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

# https://eksctl.io/usage/eks-managed-nodegroups/
managedNodeGroups:
  - name: spinnaker
    minSize: 2
    maxSize: 3
    desiredCapacity: 3
    instanceType: m5.large
    ssh:
      enableSsm: true
    volumeSize: 20
    labels: {role: spinnaker}
    tags:
      nodegroup-role: spinnaker
EOF

eksctl create nodegroup -f spinnakerworkshop.yaml
eksctl delete nodegroup --cluster=eksworkshop-eksctl --name=nodegroup

```
{{< output >}}
.....
.....
.....
2021-05-20 16:45:15 [ℹ]  waiting for at least 2 node(s) to become ready in "spinnaker"
2021-05-20 16:45:15 [ℹ]  nodegroup "spinnaker" has 3 node(s)
2021-05-20 16:45:15 [ℹ]  node "ip-192-y-x-184.${AWS_REGION}.compute.internal" is ready
2021-05-20 16:45:15 [ℹ]  node "ip-192-y-x-128.${AWS_REGION}.compute.internal" is ready
2021-05-20 16:45:15 [ℹ]  node "ip-192-y-x-105.${AWS_REGION}.compute.internal" is ready
2021-05-20 16:45:15 [✔]  created 1 managed nodegroup(s) in cluster "eksworkshop-eksctl"
2021-05-20 16:45:16 [ℹ]  checking security group configuration for all nodegroups
2021-05-20 16:45:16 [ℹ]  all nodegroups have up-to-date configuration
{{< /output >}}

Confirm the setup
```
kubectl get nodes
```
{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-y-x-184.${AWS_REGION}.compute.internal   Ready    <none>   4m45s   v1.17.12-eks-7684af
ip-192-y-x-128.${AWS_REGION}.compute.internal   Ready    <none>   4m37s   v1.17.12-eks-7684af
ip-192-y-x-105.${AWS_REGION}.compute.internal    Ready    <none>   4m47s   v1.17.12-eks-7684afå
{{< /output >}}


#### Install Spinnaker CRDs

Pick a release from https://github.com/armory/spinnaker-operator/releases and export that version. Below we are using the latest release of Spinnaker Operator when this workshop was written,

```
export VERSION=1.2.4
echo $VERSION

mkdir -p spinnaker-operator && cd spinnaker-operator
bash -c "curl -L https://github.com/armory/spinnaker-operator/releases/download/v${VERSION}/manifests.tgz | tar -xz"
kubectl apply -f deploy/crds/
```

{{< output >}}
1.2.4
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   621  100   621    0     0   2700      0 --:--:-- --:--:-- --:--:--  2688
100 11225  100 11225    0     0  29080      0 --:--:-- --:--:-- --:--:-- 29080
customresourcedefinition.apiextensions.k8s.io/spinnakeraccounts.spinnaker.io created
customresourcedefinition.apiextensions.k8s.io/spinnakerservices.spinnaker.io created
{{< /output >}}

#### Install Spinnaker Operator
Install operator in namespace `spinnaker-operator`. We have used `Cluster mode` for the operator that works across namespaces and requires a ClusterRole to perform validation.

```
kubectl create ns spinnaker-operator
kubectl -n spinnaker-operator apply -f deploy/operator/cluster
```
{{< output >}}
namespace/spinnaker-operator created
deployment.apps/spinnaker-operator created
clusterrole.rbac.authorization.k8s.io/spinnaker-operator-role created
clusterrolebinding.rbac.authorization.k8s.io/spinnaker-operator-binding created
serviceaccount/spinnaker-operator created
{{< /output >}}

Make sure the Spinnaker-Operator pod is running
{{% notice info %}}
This may take couple of minutes
{{% /notice %}}
```
kubectl get pod -n spinnaker-operator
```
{{< output >}}
NAME                                  READY   STATUS    RESTARTS   AGE
spinnaker-operator-6d95f9b567-tcq4w   2/2     Running   0          82s
{{< /output >}}
