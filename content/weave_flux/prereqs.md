---
title: "Prereqs"
date: 2018-10-14T19:56:14-04:00
weight: 5
draft: false
---

#### Is **helm** installed?

We will use **helm** to install Weave Flux and a sample Helm chart. Please review  [installing helm chapter](/helm_root/helm_intro/install/index.html) for instructions if you don't have it installed.

```
helm ls
```

<br>
#### Does S3 artifact bucket exist and are IAM service roles created?

AWS CodePipeline and AWS CodeBuild both need [AWS Identity and Access Management (IAM)](https://aws.amazon.com/iam/) service roles to create a Docker image build pipeline.  

In this step, we are going to create an IAM role and add an inline policy that we will use in the CodeBuild stage
to interact with the EKS cluster via kubectl.

Create the bucket and roles:

{{< tabs name="Create IAM Roles and S3 Bucket" >}}
{{{< tab name="Workshop at AWS event" >}}
The required IAM roles and S3 bucket have been created for you as follows:<br>
<br>
S3 Artifact Bucket:         eksworkshop-<account number>-codepipeline-artifacts <br>
CodePipeline Service Role:  eksworkshop-CodePipelineServiceRole <br>
CodeBuild Service Role:     eksworkshop-CodeBuildServiceRole <br>
<br>
You can proceed with the next step.
{{< /tab >}}
{{< tab name="Workshop in your own account" codelang="bash" >}}
aws sts get-caller-identity

# Use your account number below
ACCT=123456789012
aws s3 mb s3://eksworkshop-${ACCT}-codepipeline-artifacts

cd ~/environment

wget https://eksworkshop.com/weave_flux/iam.files/cpAssumeRolePolicyDocument.json

aws iam create-role --role-name eksworkshop-CodePipelineServiceRole --assume-role-policy-document file://cpAssumeRolePolicyDocument.json 

wget https://eksworkshop.com/weave_flux/iam.files/cpPolicyDocument.json

aws iam put-role-policy --role-name eksworkshop-CodePipelineServiceRole --policy-name codepipeline-access --policy-document file://cpPolicyDocument.json

wget https://eksworkshop.com/weave_flux/iam.files/cbAssumeRolePolicyDocument.json

aws iam create-role --role-name eksworkshop-CodeBuildServiceRole --assume-role-policy-document file://cbAssumeRolePolicyDocument.json 

wget https://eksworkshop.com/weave_flux/iam.files/cbPolicyDocument.json

aws iam put-role-policy --role-name eksworkshop-CodeBuildServiceRole --policy-name codebuild-access --policy-document file://cbPolicyDocument.json

{{< /tab >}}}
{{< /tabs >}}
