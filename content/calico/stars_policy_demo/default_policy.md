---
title: "Default Pod-to-Pod Communication"
date: 2018-08-07T08:30:11-07:00
weight: 2
---
In Kubernetes, the **pods by default can communicate with other pods**, regardless of which host they land on. Every pod gets its own IP address so you do not need to explicitly create links between pods. This is demonstrated by the management UI

You can access it by going to one of your worker nodes' IP address and specifying port :30002 at the end (for example: 52.12.161.128:30002)

30002 is the port on each node's IP where the service is exposed.

```
kind: Service
metadata:
  name: management-ui 
  namespace: management-ui 
spec:
  type: NodePort
  ports:
  - port: 9001 
    targetPort: 9001
    nodePort: 30002
```
{{% notice note %}}
Remember to open port 30002 in your Worker nodes' Security Group.
{{% /notice %}}

The UI here shows the default behavior, of all services being able to reach each other.

![full access](/images/calico-full-access.png)