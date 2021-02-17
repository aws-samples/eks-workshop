---
title: "Add Fargate Profile"
date: 2020-01-27T08:30:11-07:00
weight: 22
draft: false
---

#### Create IAM OIDC provider

First, we will have to set up an OIDC provider with the cluster. The IAM OIDC Provider is not enabled by default, you can use the following command to enable it.

```bash
eksctl utils associate-iam-oidc-provider \
    --region ${AWS_REGION} \
    --cluster eksworkshop-eksctl \
    --approve
```
{{< output >}}
[ℹ]  eksctl version 0.36.2
[ℹ]  using region us-west-2
[ℹ]  will create IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "us-west-2"
[✔]  created IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "us-west-2"
{{< /output >}}

#### Create a IAM role and ServiceAccount 

Looking at the [clusterconfig.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/clusterconfig.yaml), you can see the below IRSA configuration.

{{< output >}}
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

....
....
iam:
  withOIDC: true
  serviceAccounts:
    - metadata:
        name: prodcatalog-sa
        namespace: prodcatalog-ns
        labels: {aws-usage: "application"}
      attachPolicyARNs:
        - "arn:aws:iam::aws:policy/AWSAppMeshEnvoyAccess"
        - "arn:aws:iam::aws:policy/AWSCloudMapDiscoverInstanceAccess"
        - "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
        - "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
        - "arn:aws:iam::aws:policy/AWSAppMeshFullAccess"
        - "arn:aws:iam::aws:policy/AWSCloudMapFullAccess"
{{< /output >}}

Using this [clusterconfig.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/clusterconfig.yaml) we will create a Kubernetes Service Account for the Fargate in the application namespace `prodcatalog-ns` by executing the following command. 
This command deploys a CloudFormation template that creates an Application Namespace `prodcatalog-ns` and Service Account `prodcatalog-ns/prodcatalog-sa` 
that has IAM role with all the IAM policies that we see in the above yaml.

This step is required to give IAM permissions to a Fargate pod running in the cluster using the IAM for Service Accounts feature.

```bash
envsubst < ./deployment/clusterconfig.yaml | eksctl create iamserviceaccount -f - --approve
```
{{< output >}}
[ℹ]  eksctl version 0.36.2
[ℹ]  using region us-west-2
[ℹ]  1 iamserviceaccount (prodcatalog-ns/prodcatalog-sa) was included (based on the include/exclude rules)
[!]  serviceaccounts that exists in Kubernetes will be excluded, use --override-existing-serviceaccounts to override
[ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "prodcatalog-ns/prodcatalog-sa", create serviceaccount "prodcatalog-ns/prodcatalog-sa" } }
[ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-sa"
[ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-sa"
[ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-sa"
[ℹ]  created namespace "prodcatalog-ns"
[ℹ]  created serviceaccount "prodcatalog-ns/prodcatalog-sa"
{{< /output >}}

The IAM role gets associated with a Kubernetes Service Account. You can see details of the service account created with the following command.

```bash
kubectl describe sa prodcatalog-sa -n prodcatalog-ns
```
{{< output >}}
Name:                prodcatalog-sa
Namespace:           prodcatalog-ns
Labels:              aws-usage=application
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::$ACCOUNT_ID:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-1EP800J16RHBX
Image pull secrets:  <none>
Mountable secrets:   prodcatalog-sa-token-g8f2x
Tokens:              prodcatalog-sa-token-g8f2x
Events:              <none>
{{< /output >}}

{{% notice info %}}
Learn more about [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) in the Amazon EKS documentation.
{{% /notice %}}

#### Create a Fargate profile

The [Fargate profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) allows an administrator to declare which pods run on Fargate. 
Each profile can have up to five selectors that contain a **namespace** and optional **labels**. You must define a namespace for every selector. 
The label field consists of multiple optional key-value pairs. Pods that match a selector (by matching a namespace for the selector and all of the labels 
specified in the selector) are scheduled on Fargate.

It is generally a good practice to deploy user application workloads into namespaces other than **kube-system** or **default** so that you have more 
fine-grained capabilities to manage the interaction between your pods deployed on to EKS. In this chapter we will create a new Fargate profile named **fargate-productcatalog** 
that targets all pods destined for the `prodcatalog-ns` namespace with label `app: prodcatalog`. You can see the Fargate Profile configuration below from [clusterconfig.yaml](https://github.com/aws-containers/eks-app-mesh-polyglot-demo/blob/master/deployment/clusterconfig.yaml).

{{< output >}}
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}

....
....
fargateProfiles:
  - name: fargate-productcatalog
    selectors:
      - namespace: prodcatalog-ns
        labels:
          app: prodcatalog
{{< /output >}}

Run the below command to create the Fargate Profile
```bash
envsubst < ./deployment/clusterconfig.yaml | eksctl create fargateprofile -f -
```
{{< output >}}
[ℹ]  creating Fargate profile "fargate-productcatalog" on EKS cluster "eksworkshop-eksctl"
{{< /output >}}

When your EKS cluster schedules pods on Fargate, the pods will need to make calls to AWS APIs on your behalf to do things like pull container 
images from Amazon ECR. The Fargate **Pod Execution Role** provides the IAM permissions to do this. This IAM role is automatically created 
for you by the above command.

Creation of a Fargate profile can take up to several minutes. Execute the following command after the profile creation is completed and 
you should see output similar to what is shown below.

{{% notice info %}}
The creation of the Fargate Profile will take about 5 - 7 minutes.
{{% /notice %}}

```bash
eksctl get fargateprofile --cluster eksworkshop-eksctl -o yaml
```
{{< output >}}
- name: fargate-productcatalog
  podExecutionRoleARN: arn:aws:iam::$ACCOUNT_ID:role/eksctl-eksworkshop-eksctl-FargatePodExecutionRole-JPQ56PZ7R9NL
  selectors:
  - labels:
      app: prodcatalog
    namespace: prodcatalog-ns
  status: ACTIVE
  subnets:
  - subnet-084a7XXXXXXXXXXXX
  - subnet-0b2dXXXXXXXXXXXXX
  - subnet-08565XXXXXXXXXXXX
{{< /output >}}

Log into console and navigate to Amazon EKS -> Cluster -> Click `eksworkshop-eksctl` -> Configuration -> Compute, you should see the new Fargate Profile `fargate-productcatalog` you created:
![fargate](/images/app_mesh_fargate/fargate1.png)

Notice that the profile includes the private subnets in your EKS cluster. Pods running on Fargate are not assigned public IP addresses, 
so only private subnets (with no direct route to an Internet Gateway) are supported when you create a Fargate profile. Hence, 
while provisioning an EKS cluster, you must make sure that the VPC that you create contains one or more private subnets. 
When you create an EKS cluster with [eksctl](http://eksctl.io) utility, under the hoods it creates a VPC that meets these requirements.



