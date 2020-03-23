---
title: "Create S3 Bucket and IAM Role for Velero"
weight: 10
draft: false
---

#### Create an S3 bucket to backup cluster

Velero uses AWS S3 bucket to backup EKS cluster. Create an S3 bucket:

{{% notice info %}}
If you are running this workshop in a region other than us-east-1, use the command below to create S3 bucket. Replace <teamhash or uniquename> with the teamhash that was provided you or use a unique string.

```
aws s3api create-bucket \
--bucket eksworkshop-backup-<teamhash or uniquename>-$RANDOM \
--region $AWS_REGION \
--create-bucket-configuration LocationConstraint=$AWS_REGION
```
{{% /notice %}}

{{% notice info %}}
For us-east-1, use the command below to create S3 bucket. Replace <teamhash or uniquename> with the teamhash that was provided you or use a unique string.

```
aws s3api create-bucket \
--bucket eksworkshop-backup-<teamhash or uniquename>-$RANDOM \
--region $AWS_REGION
```
{{% /notice %}}

The output should something like this
```
{
    "Location": "http://eksworkshop-backup-7asfaff-22480.s3.amazonaws.com/"
}
```

Set the BUCKET variable with the bucket name (*example: eksworkshop-backup-7asfaff-22480*) you created.
```
BUCKET=<bucketname>
```

#### Create an IAM role Velero:

Create an IAM user for Velero:

```
aws iam create-user --user-name velero
```

Attach policies to give velero the necessary permissions:

```
cat > velero-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateSnapshot",
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${BUCKET}"
            ]
        }
    ]
}
EOF
```

Attach policy to velero IAM User
```
aws iam put-user-policy \
  --user-name velero \
  --policy-name velero \
  --policy-document file://velero-policy.json
```

Create an access key for the user:
```
aws iam create-access-key --user-name velero
```

The result should look like:
```
{
  "AccessKey": {
        "UserName": "velero",
        "Status": "Active",
        "CreateDate": "2020-03-18T22:24:41.576Z",
        "SecretAccessKey": <AWS_SECRET_ACCESS_KEY>,
        "AccessKeyId": <AWS_ACCESS_KEY_ID>
  }
}
```
Create a credentials file (velero-credentials) specfic to velero user in your local directory (~/environment):

```
[default]
aws_access_key_id=<AWS_ACCESS_KEY_ID>
aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
```
