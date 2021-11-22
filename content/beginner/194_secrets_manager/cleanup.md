---
title: "Cleanup the Lab"
date: 2021-09-31T00:00:00-04:00
weight: 50
draft: false
---

Make sure variables are set up correctly.
```bash
test -n "$EKS_CLUSTERNAME" && echo EKS_CLUSTERNAME is "$EKS_CLUSTERNAME" \
 || echo EKS_CLUSTERNAME is not set
test -n "$AWS_REGION" && echo AWS_REGION is "$AWS_REGION" || echo AWS_REGION is not set
```

The output must show both variables set. Your AWS region may be different.
{{<output>}}
EKS_CLUSTERNAME is eksworkshop-eksctl
AWS_REGION is us-east-2
{{</output>}}


Change the directory to your working directory. Verify you are in the correct directory path before running the cleanup steps.

```bash
ls -p

```

The output should show the directory listing with the following files. You may have more than these files displayed here.
{{<output>}}
00_iam_policy_arn_dbsecret		nginx-deployment-spc-k8s-secrets.yaml	nginx-deployment.yaml
nginx-deployment-k8s-secrets.yaml	nginx-deployment-spc.yaml
{{</output>}}


#### Cleanup
Run following commands to cleanup this lab.
```bash
kubectl delete -f nginx-deployment-k8s-secrets.yaml
rm nginx-deployment-k8s-secrets.yaml

kubectl delete -f nginx-deployment-spc-k8s-secrets.yaml
rm nginx-deployment-spc-k8s-secrets.yaml

kubectl delete -f nginx-deployment.yaml
rm nginx-deployment.yaml

kubectl delete -f nginx-deployment-spc.yaml
rm nginx-deployment-spc.yaml

eksctl delete iamserviceaccount \
    --region="$AWS_REGION" --name "nginx-deployment-sa"  \
    --cluster "$EKS_CLUSTERNAME" 

sleep 5

aws --region "$AWS_REGION" iam \
	delete-policy --policy-arn $(cat 00_iam_policy_arn_dbsecret)
unset IAM_POLICY_ARN_SECRET
unset IAM_POLICY_NAME_SECRET
rm 00_iam_policy_arn_dbsecret

aws --region "$AWS_REGION" secretsmanager \
  delete-secret --secret-id DBSecret_eksworkshop --force-delete-without-recovery

kubectl delete -f \
 https://raw.githubusercontent.com/aws/secrets-store-csi-driver-provider-aws/main/deployment/aws-provider-installer.yaml

helm uninstall -n kube-system csi-secrets-store
helm repo remove secrets-store-csi-driver
```
