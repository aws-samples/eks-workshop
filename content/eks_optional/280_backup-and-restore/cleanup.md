---
title: "Cleanup"
weight: 50
draft: false
---

Cleanup staging namepspace

```
kubectl delete namespace staging
kubectl delete storageclass staging
```

Cleanup velero namespace

```
kubectl delete namespace velero
```

Delete S3 Bucket and IAM user
```
aws s3 rb s3://$VELERO_BUCKET --force
aws iam delete-user-policy --user-name velero --policy-name velero
aws iam delete-access-key --access-key-id $VELERO_ACCESS_KEY_ID --user-name velero
aws iam delete-user --user-name velero
```

Delete files from Cloud9 environment
```
cd ..
rm -f velero*
rm -fr backup-restore
sudo rm -f /usr/local/bin/velero
```

You may also want to delete the environment variables (`$VELERO_BUCKET`, `$VELERO_ACCESS_KEY_ID`, and `$VELERO_SECRET_ACCESS_KEY`) from `~/.bash_profile` using your preferred editor as they are no longer valid. You will need to remove the lines below from `~/.bash_profile`.

```
export VELERO_BUCKET=eksworkshop-backup-1587212345-12345
export VELERO_ACCESS_KEY_ID=AKIAABCD12345EFGH
export VELERO_SECRET_ACCESS_KEY=XcImQuya/S0O6REL5ZrKI31yqW9Dsihb9ktNmpsQ
```