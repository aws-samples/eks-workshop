---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role](/020_prerequisites/workspaceiam/#validate-the-iam-role) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:

**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}
Run `aws sts get-caller-identity` and validate that your _Arn_ contains `eksworkshop-admin`and an Instance Id.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
```

If you do not see the correct role, please go back and [validate the IAM role](/020_prerequisites/workspaceiam/#validate-the-iam-role) for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}

### Create an EKS cluster

{{% notice warning %}}
`eksctl` version must be 0.48.0 or above to deploy EKS 1.19, [click here](/030_eksctl/prerequisites) to get the latest version.
{{% /notice %}}

`eksctl` allows you to create cluster in two ways.

>#### Option 1: Cluster configuration file (recommended)

Cluster configuration file uses YAML file to represent EKS cluster properties and options to fine tune cluster behavior. Please see official documentation for schema of [cluster configuration](https://eksctl.io/usage/schema/) file.

Lets create eksctl configuration file for cluster deployment

```bash
cat << EOF > eksworkshop.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eksworkshop-eksctl
  region: ${AWS_REGION}
  version: "1.19"

availabilityZones: ["${AZS[0]}", "${AZS[1]}", "${AZS[2]}"]

managedNodeGroups:
- name: nodegroup
  desiredCapacity: 3
  instanceType: t3.small
  ssh:
    enableSsm: true

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF
```

Next, use the file you created as the input for the `eksctl` cluster creation.

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}

```bash
eksctl create cluster -f eksworkshop.yaml
```
{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}

>#### Option 2: Create cluster using `eksctl` cli.

{{% notice info %}}
We recommend creating cluster using configuration file. It will allow you to store configuration file in source control and keep track of changes to cluster overtime. Infrastructure as code (IaC) is preferred over manual changs.
{{% /notice %}}

```bash
eksctl create cluster \
--name eksworkshop-eksctl \
--version 1.19 \
--tags cluster-type=workshop,department=dev \
--region "${AWS_REGION}" \
--zones "${AZS[0]},${AZS[1]},${AZS[2]}" \
--nodes 3 \
--node-type t3.medium \
--node-private-networking \
--enable-ssm \
--managed
```

Kubernetes secrets are just base64 encoded strings. It is highly recommended to encrypt secrets using trusted and secure encryption service. 
Next, we will enable kubernetes secrets encryption using AWS KMS. It will also encrypt existing secrets in cluster.
 
```bash
eksctl utils enable-secrets-encryption \
--region "${AWS_REGION}" \
--cluster eksworkshop-eksctl \
--encrypt-existing-secrets \
--key-arn "${MASTER_ARN}" \
--approve
```

Here we are creating EKS cluster with managed nodes by specifying `--managed` flag. It is good practice to tag resources in AWS for easier maintenance and cost allocation purpose. `--tags` option will propagate tags to ec2 instances and ebs volumes in cluster.
`eksctl` utility supports many other options to fine tune cluster, see [official documentation](https://eksctl.io/introduction/) to learn more about eksctl.

We can also generate cluster configuration file using cli by using `--dry-run` flag, which will be a good starting point for custom configuration file.

```bash
eksctl create cluster \
--name eksworkshop-eksctl \
--version 1.19 \
--tags cluster-type=workshop,department=dev \
--region "${AWS_REGION}" \
--zones "${AZS[0]},${AZS[1]},${AZS[2]}" \
--nodes 3 \
--node-type t3.medium \
--node-private-networking \
--enable-ssm \
--managed \
--dry-run
```

This will generate eksctl configuration file similar to one we stored in eksworkshop.yaml earlier.

