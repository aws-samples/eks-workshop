---
title: "Cleanup"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 70
---

Once you have completed this chapter, you can cleanup the files and resources you created by issuing the following commands:

```bash
unset KUBECONFIG

kubectl delete namespace development integration

rm /tmp/*.json
rm ~/.aws/*.sh

eksctl delete iamidentitymapping --cluster eksworkshop --arn arn:aws:iam::${ACCOUNT_ID}:role/k8sDev --username dev-user
eksctl delete iamidentitymapping --cluster eksworkshop --arn arn:aws:iam::${ACCOUNT_ID}:role/k8sDev --username dev-integ

aws iam delete-user --user-name PaulAdmin
aws iam delete-user --user-name JeanDev
aws iam delete-user --user-name PierreInteg

aws iam delete-role --role-name k8sAdmin
aws iam delete-role --role-name k8sDev
aws iam delete-role --role-name k8sInteg
```
