---
title: "Cleanup"
date: 2018-08-07T08:30:11-07:00
weight: 60
---

To uninstall Jenkins and cleanup the service account and CodeCommit repository run:

```
helm uninstall cicd
aws codecommit delete-repository --repository-name eksworkshop-app
aws iam detach-user-policy --user-name git-user --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitPowerUser
aws iam delete-service-specific-credential --user-name git-user --service-specific-credential-id $CREDENTIAL_ID
aws iam delete-user --user-name git-user
eksctl delete iamserviceaccount --name jenkins --namespace default --cluster eksworkshop-eksctl
rm -rf ~/environment/eksworkshop-app
rm ~/environment/values.yaml
```