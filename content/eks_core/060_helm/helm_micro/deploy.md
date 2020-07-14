---
title: "Deploy the eksdemo Chart"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

#### Use the dry-run flag to test our templates

To test the syntax and validity of the Chart without actually deploying it,
we'll use the `--dry-run` flag.

The following command will build and output the rendered templates without
installing the Chart:

```sh
helm install --debug --dry-run workshop ~/environment/eksdemo
```

Confirm that the values created by the template look correct.

#### Deploy the chart

Now that we have tested our template, let's install it.

```sh
helm install workshop ~/environment/eksdemo
```

Similar to what we saw previously in the [nginx Helm Chart
example](/beginner/060_helm/helm_nginx/index.html), an output of the command will contain the information about the deployment status, revision, namespace, etc, similar to:

{{< output >}}
NAME: workshop
LAST DEPLOYED: Tue Feb 18 22:11:37 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
{{< /output >}}

In order to review the underlying services, pods and deployments, run:
```sh
kubectl get svc,po,deploy
```
