---
title: "Cleanup"
date: 2018-10-087T08:30:11-07:00
weight: 35
draft: false
---

Congratulations on completing the GitOps with Weave Flux module. 

This module is not used in subsequent steps, so you can remove the resources now, or at the end of the workshop.

First, delete all images from the [Amazon ECR Repository](https://console.aws.amazon.com/ecr/repositories).

Next, go to the [CloudFormation Console](https://console.aws.amazon.com/cloudformation/) and delete the stack used to deploy the image build CodePipeline

Now, delete Weave Flux and your load balanced services

```
helm uninstall helm-operator --namespace flux
helm uninstall flux --namespace flux
kubectl delete namespace flux 
kubectl delete crd helmreleases.helm.fluxcd.io

helm uninstall mywebserver -n nginx
kubectl delete namespace nginx
kubectl delete svc eks-example -n eks-example
kubectl delete deployment eks-example -n eks-example
kubectl delete namespace eks-example
```

Optionally go to GitHub and delete your k8s-config and eks-example repositories.  


{{% notice info %}}
If you are using your own account for this workshop, continue with the below steps.  If doing this at an AWS event, skip the steps below.
{{% /notice %}}

Remove IAM roles you previously created 

```
aws iam delete-role-policy --role-name eksworkshop-CodePipelineServiceRole --policy-name codepipeline-access 
aws iam delete-role --role-name eksworkshop-CodePipelineServiceRole
aws iam delete-role-policy --role-name eksworkshop-CodeBuildServiceRole --policy-name codebuild-access 
aws iam delete-role --role-name eksworkshop-CodeBuildServiceRole
```

Remove the artifact bucket you previously created 
```
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
aws s3 rb s3://eksworkshop-${ACCOUNT_ID}-codepipeline-artifacts --force
```

