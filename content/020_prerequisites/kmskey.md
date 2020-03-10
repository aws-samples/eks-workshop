---
title: "Create an AWS KMS Custom Managed Key (CMK)"
chapter: false
weight: 32
---



Create a CMK for the EKS cluster to use when encrypting your Kubernetes secrets:
```bash
aws kms create-alias --alias-name alias/eksworkshop --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)
```

Let's retrieve the ARN of the CMK to input into the create cluster command.

```bash
export MASTER_ARN=$(aws kms describe-key --key-id alias/eksworkshop --query KeyMetadata.Arn --output text)
```

We set the MASTER_ARN environment variable to make it easier to refer to the KMS key later.