---
title: "Set Permissions"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Next, we'll setup the workers to have the correct permissions to run App Mesh API calls.

Verify that $ROLE_NAME is defined by running the following command:

```
echo $ROLE_NAME
```

If this variable is not defined (the above command returns an empty value), please visit [the cluster test chapter](/030_eksctl/test) and run through the export role name step.

Also be sure you have your region defined.  Verify its set by running the following command:

```
echo $AWS_REGION
```

If this variable is not defined (the above command returns an empty value), please run the following to define the AWS_REGION environmental variable:

```
export ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

echo "export ACCOUNT_ID=${ACCOUNT_ID}" >> ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" >> ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure get default.region
```



Copy and paste the below code to add the permissions as an inline policy to your worker node instances:

### Setup Permissions for the Worker Nodes
```
cat <<EoF > k8s-appmesh-worker-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "appmesh:DescribeMesh",
        "appmesh:DescribeVirtualNode",
        "appmesh:DescribeVirtualService",
        "appmesh:DescribeVirtualRouter",
        "appmesh:DescribeRoute",
        "appmesh:CreateMesh",
        "appmesh:CreateVirtualNode",
        "appmesh:CreateVirtualService",
        "appmesh:CreateVirtualRouter",
        "appmesh:CreateRoute",
        "appmesh:UpdateMesh",
        "appmesh:UpdateVirtualNode",
        "appmesh:UpdateVirtualService",
        "appmesh:UpdateVirtualRouter",
        "appmesh:UpdateRoute",
        "appmesh:ListMeshes",
        "appmesh:ListVirtualNodes",
        "appmesh:ListVirtualServices",
        "appmesh:ListVirtualRouters",
        "appmesh:ListRoutes",
        "appmesh:DeleteMesh",
        "appmesh:DeleteVirtualNode",
        "appmesh:DeleteVirtualService",
        "appmesh:DeleteVirtualRouter",
        "appmesh:DeleteRoute",
        "appmesh:StreamAggregatedResources"
  ],
      "Resource": "*"
    }
  ]
}
EoF

aws iam put-role-policy --role-name $ROLE_NAME --policy-name AM-Policy-For-Worker --policy-document file://k8s-appmesh-worker-policy.json
```

To verify the policy was attached to the role, run the following command:

```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name AM-Policy-For-Worker
```
