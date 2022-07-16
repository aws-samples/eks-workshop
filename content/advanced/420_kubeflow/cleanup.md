---
title: "Cleanup"
date: 2022-07-16T15:43:24-04:00
weight: 90
draft: false
---

### Uninstall Kubeflow

First, delete IAM users, S3 bucket and Kubernetes secret
```
# delete s3user
aws iam detach-user-policy --user-name s3user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam delete-access-key --access-key-id `echo $AWS_ACCESS_KEY_ID_VALUE | base64 --decode` --user-name s3user
aws iam delete-user --user-name s3user
# delete sagemakeruser
aws iam detach-user-policy --user-name sagemakeruser --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam delete-access-key --access-key-id `echo $AWS_ACCESS_KEY_ID_VALUE | base64 --decode` --user-name sagemakeruser
aws iam delete-user --user-name sagemakeruser
# delete S3 bucket
aws s3 rb s3://$S3_BUCKET --force --region $AWS_REGION
# delete aws-secret
kubectl delete secret/aws-secret
kubectl delete secret/aws-secret -n kubeflow
```

Next, delete all existing Kubeflow profiles. 

```bash
kubectl get profile
kubectl delete profile --all
```

You can delete a Kubeflow deployment by running the `kubectl delete` command on the manifest according to the deployment option you chose. For example, to delete a vanilla installation, run the following command:

```bash
kustomize build deployments/vanilla/ | kubectl delete -f -
```

This command assumes that you have the repository in the same state as when you installed Kubeflow.

Cleanup steps for specific deployment options can be found in their respective [installation guides](https://awslabs.github.io/kubeflow-manifests/release-v1.5.1-aws-b1.0.0/docs/deployment/). 

> Note: This will not delete your Amazon EKS cluster.

#### (Optional) Delete Amazon EKS cluster

If you created a dedicated Amazon EKS cluster for Kubeflow using `eksctl`, you can delete it with the following command:

```bash
eksctl delete cluster --region $CLUSTER_REGION --name $CLUSTER_NAME
```

> Note: It is possible that parts of the CloudFormation deletion will fail depending upon modifications made post-creation. In that case, manually delete the eks-xxx role in IAM, then the ALB, the EKS target groups, and the subnets of that particular cluster. Then, retry the command to delete the nodegroups and the cluster.

For more detailed information on deletion options, see [Deleting an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html). 