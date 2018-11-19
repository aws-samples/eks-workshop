---
title: "Configure Artifact Repository"
date: 2018-11-18T00:00:00-05:00
weight: 50
draft: false
---

### Configure Artifact Repository

Argo uses an artifact repository to pass data between jobs in a workflow, known as artifacts. Amazon S3 can be used as an artifact repository.

Let's create a S3 bucket using the AWS CLI.

```bash
ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
aws s3 mb s3://batch-artifact-repository-${ACCOUNT_ID}/
```

Next, edit the workflow-controller ConfigMap to use the S3 bucket.

```bash
kubectl edit -n argo configmap/workflow-controller-configmap
```

Add the following lines to the end of the ConfigMap:

```
data:
  config: |
    artifactRepository:
      s3:
        bucket: batch-artifact-repository-${ACCOUNT_ID}
        endpoint: s3.amazonaws.com
```

We'll use artifacts in the [Advanced Batch Workflow](/batch/workflow-advanced/) example.