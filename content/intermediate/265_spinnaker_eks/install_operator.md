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

#### Prequisite

* Here we are using Cloud9 IDE whcih is setup based on the instructions from [eksworkshop](/020_prerequisites/)

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
```
cat << EOF > spinnakerworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: spinnaker-workshop
  region: ${AWS_REGION}
  version: "1.19"

availabilityZones: ["${AZS[0]}", "${AZS[1]}", "${AZS[2]}"]

managedNodeGroups:
- name: spinnaker
  desiredCapacity: 3
  instanceType: m5.large
  ssh:
    enableSsm: true

# To enable all of the control plane logs, uncomment below:
cloudWatch:
  clusterLogging:
    enableTypes: ["*"]

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF

 eksctl create cluster -f spinnakerworkshop.yaml
```
{{< output >}}
.....
.....
.....
2021-04-19 17:13:44 [✔]  EKS cluster "spinnaker-workshop" in "us-west-2" region is ready
{{< /output >}}

* Confirm the setup
```
kubectl get nodes
```
{{< output >}}
NAME                                           STATUS   ROLES    AGE     VERSION
ip-192-yy-21-xx.us-west-2.compute.internal   Ready    <none>   4m45s   v1.19.6-eks-49a6c0
ip-192-yy-59-xx.us-west-2.compute.internal   Ready    <none>   4m37s   v1.19.6-eks-49a6c0
ip-192-yy-87-xx.us-west-2.compute.internal    Ready    <none>   4m47s   v1.19.6-eks-49a6c0
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

```
kubectl get pod -n spinnaker-operator
```
{{< output >}}
NAME                                  READY   STATUS    RESTARTS   AGE
spinnaker-operator-6d95f9b567-tcq4w   2/2     Running   0          82s
{{< /output >}}
