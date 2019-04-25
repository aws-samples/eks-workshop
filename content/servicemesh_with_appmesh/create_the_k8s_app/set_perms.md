---
title: "Set Permissions"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Next, we'll setup the workers to have the correct permissions to run App Mesh API calls.

Copy and paste the below code to add the permissions as an inline policy to your worker node instances:

### Setup Permissions for the Worker Nodes
{{< tabs name="Create EKS Cluster" >}}

{{{< tab name="Workshop at AWS event"  >}}
If you are performing these steps during a Workshop at an AWS event, the steps have already been completed, and you may continue to the next step below of verifying the policy is attached to the role.

{{< /tab >}}

{{< tab name="Workshop in your own account" codelang="output" >}}


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
        "appmesh:DeleteRoute"
  ],
      "Resource": "*"
    }
  ]
}
EoF

aws iam put-role-policy --role-name $ROLE_NAME --policy-name AM-Policy-For-Worker --policy-document file://k8s-appmesh-worker-policy.json

{{< /tab >}}}
{{< /tabs >}}

To verify the policy was attached to the role, run the following command:

```
aws iam get-role-policy --role-name $ROLE_NAME --policy-name AM-Policy-For-Worker
```
