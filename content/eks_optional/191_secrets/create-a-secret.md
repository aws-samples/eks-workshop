---
title: "Create a Secret"
date: 2019-04-09T00:00:00-03:00
weight: 10
draft: false
---


#### Encrypt Your Secret

Create a namespace for this exercise:

```bash
kubectl create ns secretslab
```
Output: 
{{< output >}}
namespace/secretslab created
{{< /output >}}

Create a text file containing your secret:
```bash
echo -n "am i safe?" > ./test-creds
```


Create your secret
```bash
kubectl create secret \
        generic test-creds \
        --from-file=test-creds=./test-creds \
        --namespace secretslab
```
Output: 
{{< output >}}
secret/test-creds created
{{< /output >}}

Retrieve the secret via the CLI:
```bash
kubectl get secret test-creds \
  -o jsonpath="{.data.test-creds}" \
  --namespace secretslab | \
  base64 --decode
```

Output: 
{{< output >}}
am i safe?
{{< /output >}}

At the conclusion of this lab, we will validate the Decrypt API call in CloudTrail. It will take some time for the event to be viewable in CloudTrail. So, let's go to the next step and attempt to retrieve the secret using a Kubernetes pod.