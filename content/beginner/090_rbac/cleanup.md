---
title: "Cleanup"
date: 2018-10-03T10:14:46-07:00
draft: false
weight: 70
---

Once you have completed this chapter, you can cleanup the files and resources you created by issuing the following commands:

```bash
unset AWS_SECRET_ACCESS_KEY
unset AWS_ACCESS_KEY_ID
kubectl delete namespace rbac-test
rm rbacuser_creds.sh
rm rbacuser-role.yaml
rm rbacuser-role-binding.yaml
aws iam delete-access-key --user-name=rbac-user --access-key-id=$(jq -r .AccessKey.AccessKeyId /tmp/create_output.json)
aws iam delete-user --user-name rbac-user
rm /tmp/create_output.json
```

Next remove the rbac-user mapping from the existing configMap by editing the existing aws-auth.yaml file:

```
data:
  mapUsers: |
    []
```

And apply the ConfigMap and delete the aws-auth.yaml file
```bash
kubectl apply -f aws-auth.yaml
rm aws-auth.yaml
```
