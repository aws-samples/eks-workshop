---
title: "Cleanup The Lab"
date: 2019-04-09T00:00:00-03:00
weight: 12
draft: false
---


#### Remove The Namespace

Let's delete the namespace for this exercise:

```bash
rm -f test-creds
rm -f podconsumingsecret.yaml
kubectl delete ns secretslab
```
Output: 
{{< output >}}
namespace "secretslab" deleted
{{< /output >}}

This cleans up the secret and pod we deployed for this lab.
