---
title: "Setup Logging with AWS Fargate"
date: 2018-08-07T08:30:11-07:00
weight: 10
---

### To send logs to a destination of your choice

Apply a ConfigMap to your Amazon EKS cluster with a Fluent Conf data value that defines where container logs are shipped to. Fluent Conf is Fluent Bit, which is a fast and lightweight log processor configuration language that is used to route container logs to a log destination of your choice. For more information, see [Configuration File](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/configuration-file) in the Fluent Bit documentation.

### Sending logs to Cloudwatch

1. Creating the aws observability namespace

```bash
cat > aws-observability-namespace.yaml <<EOF
kind: Namespace
apiVersion: v1
metadata:
  name: aws-observability
  labels:
    aws-observability: enabled
EOF

kubectl apply -f aws-observability-namespace.yaml
```

2. Creating the config map to configure Fluent Bit

```bash
cat > aws-logging-cloudwatch-configmap.yaml <<EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: aws-logging
  namespace: aws-observability
  labels:
data:
  output.conf: |
    [OUTPUT]
        Name cloudwatch_logs
        Match   *
        region ${AWS_REGION}
        log_group_name fluent-bit-cloudwatch
        log_stream_prefix from-fluent-bit-
        auto_create_group true
EOF

kubectl apply -f aws-logging-cloudwatch-configmap.yaml
```

3. Download the CloudWatch IAM policy to your computer. You can also [view the policy](https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json) on GitHub.

```bash
curl -o permissions.json https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json
```

4. Create an IAM policy.

```bash
POLICY_ARN=$(aws iam create-policy --policy-name eks-fargate-logging-policy --policy-document file://permissions.json | jq -r '.Policy.Arn') 
```

5. Attach the IAM policy to the pod execution role specified for your Fargate profile.

```bash
aws iam attach-role-policy \
  --policy-arn $POLICY_ARN \
  --role-name ${POD_EXECUTION_ROLE//arn:aws:iam::[0-9]*:role\//}
```
