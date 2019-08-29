---
title: "Launch EKS"
date: 2018-08-07T13:34:24-07:00
weight: 20
---


{{% notice warning %}}
**DO NOT PROCEED** with this step unless you have [validated the IAM role](/prerequisites/workspaceiam/#validate-the-iam-role) in use by the Cloud9 IDE. You will not be able to run the necessary kubectl commands in the later modules unless the EKS cluster is built using the IAM role.
{{% /notice %}}

#### Challenge:
**How do I check the IAM role on the workspace?**

{{%expand "Expand here to see the solution" %}}
Run `aws sts get-caller-identity` and validate that your _Arn_ contains `eksworkshop-admin` or `TeamRole`
(or the role created when starting the workshop) and an Instance Id.

```output
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/eksworkshop-admin/i-01234567890abcdef"
}
or
{
    "Account": "123456789012",
    "UserId": "AROA1SAMPLEAWSIAMROLE:i-01234567890abcdef",
    "Arn": "arn:aws:sts::123456789012:assumed-role/TeamRole/i-01234567890abcdef"
}
```

If you do not see the correct role, please go back and [validate the IAM role](/prerequisites/workspaceiam/#validate-the-iam-role) for troubleshooting.

If you do see the correct role, proceed to next step to create an EKS cluster.
{{% /expand %}}

### Create an EKS cluster
```
eksctl create cluster --name=eksworkshop-eksctl --nodes=3 --alb-ingress-access --region=${AWS_REGION}
```

#### If you're planning to run Machine Learning workloads in the Kubeflow chapter, then use the following command instead (note: this launches large p3 instances)
```
curl -OL https://raw.githubusercontent.com/aws-samples/eks-workshop/master/content/eksctl/launcheks.files/eksworkshop-kubeflow.yml.template
export AWS_AZS=$(aws ec2 describe-availability-zones --region=${AWS_REGION} --query 'AvailabilityZones[*].ZoneName' --output json | tr '\n' ' ' | sed 's/[][]//g')
export AWS_AZ=$(aws ec2 describe-availability-zones --region=${AWS_REGION} --query 'AvailabilityZones[0].ZoneName' --output json)
echo "export AWS_AZS=${AWS_AZS}" >> ~/.bash_profile
export "AWS_AZ=${AWS_AZ}" >> ~/.bash_profile
envsubst <eksworkshop-kubeflow.yml.template >eksworkshop-kubeflow.yml
eksctl create cluster -f eksworkshop-kubeflow.yml
```

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}
