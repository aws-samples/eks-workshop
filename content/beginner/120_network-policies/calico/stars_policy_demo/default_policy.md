---
title: "Default Pod-to-Pod Communication"
date: 2018-08-07T08:30:11-07:00
weight: 2
---
In Kubernetes, the **pods by default can communicate with other pods**, regardless of which host they land on. Every pod gets its own IP address so you do not need to explicitly create links between pods. This is demonstrated by the **management-ui**.

{{< output >}}
kind: Service
metadata:
  name: management-ui
  namespace: management-ui
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 9001
{{< /output >}}

To open the Management UI, retrieve the DNS name of the Management UI using:

```
kubectl get svc -o wide -n management-ui
```

Copy the **EXTERNAL-IP** from the output, and paste into a browser.
The EXTERNAL-IP column contains a value that ends with "elb.amazonaws.com” - the full value is the DNS address.

{{< output >}}
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP                                                              PORT(S)        AGE       SELECTOR
management-ui   LoadBalancer   10.100.239.7   a8b8c5f77eda911e8b1a60ea5d5305a4-720629306.us-east-1.elb.amazonaws.com   80:31919/TCP   9s        role=management-ui
{{< /output >}}

The UI here shows the default behavior, of all services being able to reach each other.

![full access](/images/calico-full-access.png)
