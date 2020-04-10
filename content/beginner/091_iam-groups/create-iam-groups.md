---
title: "Create IAM Groups"
date: 2020-04-05T18:00:00-00:00
draft: false
weight: 21
---

We want to have different IAM users which will be added to specific IAM groups in order to have different rights in the kubernetes cluster.

We will define 3 groups:

- **k8sAdmin** - users from this group will have admin rights on the kubernetes cluster
- **k8sDev** - users from this group will have full access only in the development namespace of the cluster
- **k8sInteg** - users from this group will have access to integration namespace. 

> In fact, users from **k8sDev** and **k8sInteg** groups will only have access to namespaces where we will define kubernetes RBAC access for their associated kubernetes role.
We'll see this but first, let's creates the groups.

#### Create k8sAdmin IAM Group

The **k8sAdmin** Group will be allowed to assume the **k8sAdmin** IAM Role.

```
aws iam create-group --group-name k8sAdmin
```
Let's add a Policy on our group which will allow users from this group to assume our k8sAdmin Role:

```
ADMIN_GROUP_POLICY=$(echo -n '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeOrganizationAccountRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':role/k8sAdmin"
    }
  ]
}')
echo ADMIN_GROUP_POLICY=$ADMIN_GROUP_POLICY

aws iam put-group-policy \
--group-name k8sAdmin \
--policy-name k8sAdmin-policy \
--policy-document "$ADMIN_GROUP_POLICY"
```

#### Create k8sDev IAM Group

The **k8sDev** Group will be allowed to assume the **k8sDev** IAM Role.

```
aws iam create-group --group-name k8sDev
```
Let's add a Policy on our group which will allow users from this group to assume our k8sDev Role:

```
DEV_GROUP_POLICY=$(echo -n '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeOrganizationAccountRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':role/k8sDev"
    }
  ]
}')
echo DEV_GROUP_POLICY=$DEV_GROUP_POLICY

aws iam put-group-policy \
--group-name k8sDev \
--policy-name k8sDev-policy \
--policy-document "$DEV_GROUP_POLICY"
```

#### Create k8sInteg IAM Group

```
aws iam create-group --group-name k8sInteg
```
Let's add a Policy on our group which will allow users from this group to assume our k8sInteg Role:

```
INTEG_GROUP_POLICY=$(echo -n '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAssumeOrganizationAccountRole",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::'; echo -n "$ACCOUNT_ID"; echo -n ':role/k8sInteg"
    }
  ]
}')
echo INTEG_GROUP_POLICY=$INTEG_GROUP_POLICY

aws iam put-group-policy \
--group-name k8sInteg \
--policy-name k8sInteg-policy \
--policy-document "$INTEG_GROUP_POLICY"
```

You now should have your 3 groups

```
aws iam list-groups
```

{{< output >}}
{
    "Groups": [
        {
            "Path": "/",
            "GroupName": "k8sAdmin",
            "GroupId": "AGPAZRV3OHPJZGT2JKVDV",
            "Arn": "arn:aws:iam::xxxxxxxxxx:group/k8sAdmin",
            "CreateDate": "2020-04-07T13:32:52Z"
        },
        {
            "Path": "/",
            "GroupName": "k8sDev",
            "GroupId": "AGPAZRV3OHPJUOBR375KI",
            "Arn": "arn:aws:iam::xxxxxxxxxx:group/k8sDev",
            "CreateDate": "2020-04-07T13:33:15Z"
        },
        {
            "Path": "/",
            "GroupName": "k8sInteg",
            "GroupId": "AGPAZRV3OHPJR6GM6PFDG",
            "Arn": "arn:aws:iam::xxxxxxxxxx:group/k8sInteg",
            "CreateDate": "2020-04-07T13:33:25Z"
        }
    ]
}
{{< /output >}}