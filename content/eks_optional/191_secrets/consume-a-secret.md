---
title: "Access the Secret from a Pod"
date: 2019-04-09T00:00:00-03:00
weight: 11
draft: false
---

#### Deploy a Pod to Consume the Secret
Create a YAML file (podconsumingsecret.yaml) with the following pod definition:

```
cat << EOF > podconsumingsecret.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: consumesecret
spec:
  containers:
  - name: shell
    image: amazonlinux:2018.03
    command:
      - "bin/bash"
      - "-c"
      - "cat /tmp/test-creds && sleep 10000"
    volumeMounts:
      - name: sec
        mountPath: "/tmp"
        readOnly: true
  volumes:
  - name: sec
    secret:
      secretName: test-creds
EOF
```

Deploy the pod on your EKS cluster:
```bash
kubectl --namespace secretslab \
        apply -f podconsumingsecret.yaml
```
Output: 
{{< output >}}
pod/consumesecret created
{{< /output >}}

Attach to the pod and attempt to access the secret:
```
kubectl --namespace secretslab exec -it consumesecret -- cat /tmp/test-creds
```

Output: 
{{< output >}}
am i safe?
{{< /output >}}

Let's see if the CloudTrail event for our secret retrieval is now visible. If you go to [CloudTrail](https://console.aws.amazon.com/cloudtrail/home?events&#/events?EventName=Decrypt) you should see a record available if you search for the Event type ```Decrypt``` with output similar to the following screenshot. If the event hasn't shown up yet, wait a few minutes and try again.

![cloudtrail-kms](/images/cloudtrail-proof-1-1024x528.png)

On the next screen, you will perform the cleanup operations for this lab.