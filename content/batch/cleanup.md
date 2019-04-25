---
title: "Cleanup"
date: 2018-11-18T00:00:00-05:00
weight: 90
draft: false
---

### Cleanup

#### Delete all workflows

```bash
argo delete --all
```

#### Remove Artifact Repository Bucket

{{< tabs name="Delete S3 Bucket" >}}
{{{< tab name="Workshop at AWS event" >}}
This S3 bucket will be deleted for you.<br>

You can proceed with the next step.
{{< /tab >}}
{{< tab name="Workshop in your own account" codelang="bash" >}}
aws s3 rb s3://batch-artifact-repository-${ACCOUNT_ID}/ --force
{{< /tab >}}}
{{< /tabs >}}

#### Undeploy Argo

```bash
kubectl delete -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.2.1/manifests/install.yaml
kubectl delete ns argo
```

#### Cleanup Kubernetes Job

```bash
kubectl delete job/whalesay
```
