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
{{< tabs name="Create EKS Cluster" >}}
{{{< tab name="Workshop at AWS event" codelang="bash" >}}
# To create a basic EKS cluster, we can start by downloading a config template:
cd ~/environment
wget https://eksworkshop.com/eksctl/launcheks.files/eksworkshop.yml.template

# Next, let's fill in the template variables with values from our environment:
envsubst <eksworkshop.yml.template >eksworkshop.yml

# We can examine the rendered output by viewing `eksworkshop.yml`:
cat eksworkshop.yml

# Finally, now that we have the proper config generated, we can launch EKS:
eksctl create cluster -f eksworkshop.yml

{{< /tab >}}
{{< tab name="Workshop in your own account" codelang="output" >}}
eksctl create cluster --version=1.13 --name=eksworkshop-eksctl --nodes=3 --node-ami=auto --region=${AWS_REGION}
{{< /tab >}}}
{{< /tabs >}}


{{% notice note %}}
If you see this error in the output, it can be safely ignored. We will fix
it next:
`[✖] neither aws-iam-authenticator nor heptio-authenticator-aws are installed`
{{% /notice %}}

{{% notice info %}}
Launching EKS and all the dependencies will take approximately 15 minutes
{{% /notice %}}
