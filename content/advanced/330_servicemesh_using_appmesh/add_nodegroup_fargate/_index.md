---
title: "EKS Fargate and Observability setup"
date: 2020-01-27T08:30:11-07:00
weight: 10
draft: false
---

In this chapter, we will perform the following tasks in your existing EKS cluster `eksworkshop-eksctl`.
* Create Fargate Profile
* Enable OIDC Provider
* Create Namespace for Application Deployment
* Create IRSA (IAM Role for Service Account) for Application Namespace `prodcatalog-ns`
* Enable Observability for Logs and Metrics

#### PreRequisite

* We assume that we have an existing EKS Cluster `eksworkshop-eksctl` created from [EKS Workshop](/030_eksctl/launcheks/).

* We also assume that we have [increased the disk size on your Cloud9 instance](/020_prerequisites/workspace/#increase-the-disk-size-on-the-cloud9-instance) as we need to build docker images for our application.

* We will be using AWS Console to navigate and explore resources in Amazon EKS, AWS App Mesh, Amazon Cloudwatch, AWS X-Ray in this workshop. 
So ensure that you have completed [Console Credentials](/030_eksctl/console/) to get full access to your existing EKS Cluster `eksworkshop-eksctl` in the EKS console.

* Check if AWS_REGION and ACCOUNT_ID are set correctly
    ```sh
    test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
    test -n "$ACCOUNT_ID" && echo ACCOUNT_ID is "$ACCOUNT_ID" || echo ACCOUNT_ID is not set
    ```
    If not, export the ACCOUNT_ID and AWS_REGION to ENV
    {{< output >}}
export ACCOUNT_ID=<your_account_id>
export AWS_REGION=<your_aws_region>
    {{< /output >}}
      
* Clone the repository to your local workspace with this command:
```
cd ~/environment
git clone https://github.com/aws-containers/eks-app-mesh-polyglot-demo.git
cd eks-app-mesh-polyglot-demo
```

Now lets, create the Fargate Profile in our EKS cluster to deploy one `prodcatalog` service in our Product Catalog Application.
