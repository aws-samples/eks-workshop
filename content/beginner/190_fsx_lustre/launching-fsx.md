---
title: "Creating an Fsx Lustre File System"
date: 2020-11-03T00:00:00-03:00
weight: 10
draft: false
---

The Amazon FSx for Lustre Container Storage Interface (CSI) driver provides a CSI interface that allows Amazon EKS clusters to manage the lifecycle of Amazon FSx for Lustre file systems.
For detailed descriptions of the available parameters and complete examples that demonstrate the driver's features, see the Amazon FSx for Lustre Container Storage Interface (CSI) driver project on GitHub.  



#### Prerequisites

```
CLUSTER_NAME=eksworkshop-eksctl
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.vpcId" --output text)
SUBNET_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.subnetIds[0]" --output text)
SECURITY_GROUP_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.resourcesVpcConfig.securityGroupIds" --output text)
CIDR_BLOCK=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[].CidrBlock" --output text)
S3_LOGS_BUCKET=eks-fsx-lustre-$(cat /dev/urandom | LC_ALL=C tr -dc "[:alpha:]" | tr '[:upper:]' '[:lower:]' | head -c 32)
```


You must have:

   * Version 1.18.163 or later of the AWS CLI installed. You can check your currently-installed version with the aws --version command. To install or upgrade the AWS CLI, see Installing the AWS CLI.

   * An existing Amazon EKS cluster. If you don't currently have a cluster, see Getting started with Amazon EKS to create one.

   * Version 0.31.0-rc.0 or later of eksctl installed. You can check your currently-installed version with the eksctl version command. To install or upgrade eksctl, see Installing or upgrading eksctl.

   * The latest version of kubectl installed that aligns to your cluster version. You can check your currently-installed version with the kubectl version --short --client command. For more information, see Installing kubectl.

#### To deploy the Amazon FSx for Lustre CSI driver to an Amazon EKS cluster

1. Create an AWS Identity and Access Management OIDC provider and associate it with your cluster.
    ```
    eksctl utils associate-iam-oidc-provider \
        --region $AWS_REGION \
        --cluster $CLUSTER_NAME \
        --approve
    ```

    - Create an IAM policy and service account that allows the driver to make calls to AWS APIs on your behalf.

        ```
        cat > fsx-csi-driver.json
        ```
        Copy the following text and save it to a file named fsx-csi-driver.json.

        ```
    "Version":"2012-10-17",
        "Statement":[
            {
                "Effect":"Allow",
                "Action":[
                    "iam:CreateServiceLinkedRole",
                    "iam:AttachRolePolicy",
                    "iam:PutRolePolicy"
                ],
                "Resource":"arn:aws:iam::*:role/aws-service-role/s3.data-source.lustre.fsx.amazonaws.com/*"
            },
            {
                "Action":"iam:CreateServiceLinkedRole",
                "Effect":"Allow",
                "Resource":"*",
                "Condition":{
                    "StringLike":{
                    "iam:AWSServiceName":[
                        "fsx.amazonaws.com"
                    ]
                    }
                }
            },
            {
                "Effect":"Allow",
                "Action":[
                    "s3:ListBucket",
                    "fsx:CreateFileSystem",
                    "fsx:DeleteFileSystem",
                    "fsx:DescribeFileSystems"
                ],
                "Resource":[
                    "*"
                ]
            }
        ]
        }
        ```

2. Create the policy.
```
    aws iam create-policy \
        --policy-name Amazon_FSx_Lustre_CSI_Driver \
        --policy-document file://fsx-csi-driver.json
```
    *Take note of the policy Amazon Resource Name (ARN) that is returned.*

3. Create a Kubernetes service account for the driver and attach the policy to the service account. Replacing the ARN of the policy with the ARN returned in the previous step.
    ```
    eksctl create iamserviceaccount \
        --region $AWS_REGION \
        --name fsx-csi-controller-sa \
        --namespace kube-system \
        --cluster $CLUSTER_NAME \
        --attach-policy-arn arn:aws:iam::<111122223333:policy/Amazon_FSx_Lustre_CSI_Driver> \
        --approve
    ```

    **Output:**

    You'll see several lines of output as the service account is created. The last line of output is similar to the following example line.

    ```
    [ℹ]  created serviceaccount "kube-system/fsx-csi-controller-sa"
    ```

    Note the name of the AWS CloudFormation stack that was deployed. In the example output above, the stack is named eksctl-prod-addon-iamserviceaccount-kube-system-fsx-csi-controller-sa.

4. Note the Role ARN for the role that was created.

   - Open the AWS CloudFormation console at https://console.aws.amazon.com/cloudformation
    
   - Ensure that the console is set to the Region that you created your IAM role in and then select Stacks.

   - Select the stack named eksctl-prod-addon-iamserviceaccount-kube-system-fsx-csi-controller-sa.

   - Select the Outputs tab. The Role ARN is listed on the Output(1) page.

5. Deploy the driver with the following command.

    ```
    kubectl apply -k "github.com/kubernetes-sigs/aws-fsx-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
    ```
    **Output:**

    ```
    Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
    serviceaccount/fsx-csi-controller-sa configured
    clusterrole.rbac.authorization.k8s.io/fsx-csi-external-provisioner-role created
    clusterrolebinding.rbac.authorization.k8s.io/fsx-csi-external-provisioner-binding created
    deployment.apps/fsx-csi-controller created
    daemonset.apps/fsx-csi-node created
    csidriver.storage.k8s.io/fsx.csi.aws.com created
    ```

6. Patch the driver deployment to add the service account that you created in step 3, replacing the ARN with the ARN that you noted in step 4.

```
kubectl annotate serviceaccount -n kube-system <fsx-csi-controller-sa> \
 eks.amazonaws.com/role-arn=<arn:aws:iam::111122223333:role/eksctl-prod-addon-iamserviceaccount-kube-sys-Role1-NPFTLHJ5PJF5> --overwrite=true
```

