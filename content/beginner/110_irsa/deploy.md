---
title: "Deploy Sample Pod"
date: 2018-11-13T16:36:24+09:00
weight: 50
draft: false
---

Now that we have completed all the necessary configuration to run a Pod with IAM role. We will deploy sample Pod to the cluster, and run a test command to see whether it works correctly or not.

```
curl -LO https://eksworkshop.com/beginner/110_irsa/deploy.files/iam-pod.yaml
kubectl apply -f iam-pod.yaml
```

##### Make sure your pod is in **Running** status:

```
kubectl get pod
```

{{< output >}}
eks-iam-test-7fb8c5ffb8-fdr6c  1/1  Running  0  5m23s
{{< /output >}}

##### Get into the Pod:

```
kubectl exec -it <place Pod Name> /bin/bash
```

##### Manually Call sts:AssumeRoleWithWebIdentity, and you will see AccessKeyId, SecretAccessKey information if configuration is set appropriately

```
aws sts assume-role-with-web-identity \
--role-arn $AWS_ROLE_ARN \
--role-session-name mh9test \
--web-identity-token file://$AWS_WEB_IDENTITY_TOKEN_FILE \
--duration-seconds 1000
```

##### Run awscli to see if it retrives list of Amazon S3 buckets:

```
aws s3 ls
```

##### Run awscli to see if it retrives list of Amazon EC2 instances which does not have privileges in the allocated IAM policy:

```
aws ec2 describe-instances --region us-west-2
```

##### You will get this error message:

{{< output >}}
An error occurred (UnauthorizedOperation) when calling the DescribeInstances operation: You are not authorized to perform this operation.
{{< /output >}}
