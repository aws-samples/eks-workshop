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
2021-05-02 17:37:05 [ℹ]  eksctl version 0.45.0
2021-05-02 17:37:05 [ℹ]  using region $AWS_REGION
2021-05-02 17:37:05 [ℹ]  will create IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "$AWS_REGION"
2021-05-02 17:37:05 [✔]  created IAM Open ID Connect provider for cluster "eksworkshop-eksctl" in "$AWS_REGION"
{{< /output >}}

#### Create the Namespace and IAM Role and ServiceAccount 

We will create the `prodcatalog-ns` and the IRSA for this namespace which will give permission to X-Ray, AppMesh and Cloudwatch Logs policies.

```bash
kubectl create namespace prodcatalog-ns

cd eks-app-mesh-polyglot-demo
aws iam create-policy \
    --policy-name ProdEnvoyNamespaceIAMPolicy \
    --policy-document file://deployment/envoy-iam-policy.json

eksctl create iamserviceaccount --cluster eksworkshop-eksctl \
  --namespace prodcatalog-ns \
  --name prodcatalog-envoy-proxies \
  --attach-policy-arn arn:aws:iam::$ACCOUNT_ID:policy/ProdEnvoyNamespaceIAMPolicy \
  --override-existing-serviceaccounts \
  --approve 
```
{{< output >}}
namespace/prodcatalog-ns created

{
    "Policy": {
        "PolicyName": "ProdEnvoyNamespaceIAMPolicy", 
        "PermissionsBoundaryUsageCount": 0, 
        "CreateDate": "2021-05-02T17:41:59Z", 
        "AttachmentCount": 0, 
        "IsAttachable": true, 
        "PolicyId": "ANPAV45SCB72ZHQFMQFXR", 
        "DefaultVersionId": "v1", 
        "Path": "/", 
        "Arn": "arn:aws:iam::$ACCOUNT_ID:policy/ProdEnvoyNamespaceIAMPolicy", 
        "UpdateDate": "2021-05-02T17:41:59Z"
    }
}

2021-05-02 17:42:00 [ℹ]  eksctl version 0.45.0
2021-05-02 17:42:00 [ℹ]  using region $AWS_REGION
2021-05-02 17:42:00 [ℹ]  1 iamserviceaccount (prodcatalog-ns/prodcatalog-envoy-proxies) was included (based on the include/exclude rules)
2021-05-02 17:42:00 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2021-05-02 17:42:00 [ℹ]  1 task: { 2 sequential sub-tasks: { create IAM role for serviceaccount "prodcatalog-ns/prodcatalog-envoy-proxies", create serviceaccount "prodcatalog-ns/prodcatalog-envoy-proxies" } }
2021-05-02 17:42:00 [ℹ]  building iamserviceaccount stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-envoy-proxies"
2021-05-02 17:42:00 [ℹ]  deploying stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-envoy-proxies"
2021-05-02 17:42:00 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-envoy-proxies"
2021-05-02 17:42:17 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-envoy-proxies"
2021-05-02 17:42:34 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-addon-iamserviceaccount-prodcatalog-ns-prodcatalog-envoy-proxies"
2021-05-02 17:42:34 [ℹ]  created serviceaccount "prodcatalog-ns/prodcatalog-envoy-proxies"
{{< /output >}}

The IAM role gets associated with a Kubernetes Service Account. You can see details of the service account created with the following command.

```bash
kubectl describe sa prodcatalog-envoy-proxies -n prodcatalog-ns
```
{{< output >}}
Name:                prodcatalog-envoy-proxies
Namespace:           prodcatalog-ns
Labels:              app.kubernetes.io/managed-by=eksctl
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::$ACCOUNT_ID:role/eksctl-eksworkshop-eksctl-addon-iamserviceac-Role1-1PWNQ4AJFMVBF
Image pull secrets:  <none>
Mountable secrets:   prodcatalog-envoy-proxies-token-69pql
Tokens:              prodcatalog-envoy-proxies-token-69pql
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
cd eks-app-mesh-polyglot-demo
envsubst < ./deployment/clusterconfig.yaml | eksctl create fargateprofile -f -
```
{{< output >}}
2021-05-02 17:44:51 [ℹ]  eksctl version 0.45.0
2021-05-02 17:44:51 [ℹ]  using region $AWS_REGION
2021-05-02 17:44:51 [ℹ]  deploying stack "eksctl-eksworkshop-eksctl-fargate"
2021-05-02 17:44:51 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-fargate"
2021-05-02 17:45:08 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-fargate"
2021-05-02 17:45:24 [ℹ]  waiting for CloudFormation stack "eksctl-eksworkshop-eksctl-fargate"
2021-05-02 17:45:25 [ℹ]  creating Fargate profile "fargate-productcatalog" on EKS cluster "eksworkshop-eksctl"
2021-05-02 17:49:43 [ℹ]  created Fargate profile "fargate-productcatalog" on EKS cluster "eksworkshop-eksctl"
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
![fargate](/images/app_mesh_fargate/fargate.png)

Notice that the profile includes the private subnets in your EKS cluster. Pods running on Fargate are not assigned public IP addresses, 
so only private subnets (with no direct route to an Internet Gateway) are supported when you create a Fargate profile. Hence, 
while provisioning an EKS cluster, you must make sure that the VPC that you create contains one or more private subnets. 
When you create an EKS cluster with [eksctl](http://eksctl.io) utility, under the hoods it creates a VPC that meets these requirements.



