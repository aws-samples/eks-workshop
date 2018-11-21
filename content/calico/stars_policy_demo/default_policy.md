---
title: "Default Pod-to-Pod Communication"
date: 2018-08-07T08:30:11-07:00
weight: 2
---
In Kubernetes, the **pods by default can communicate with other pods**, regardless of which host they land on. Every pod gets its own IP address so you do not need to explicitly create links between pods. This is demonstrated by the management UI

because we specified NodePort while deploying our services, you can reach this service using worker node IP:NodePort, which is 30002 (for example: 52.12.161.128:30002)

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
{{% notice tip %}}
NodePort leverages the network configuration of the Worker Node. You will need to ensure that you have added the relevant network ports to the Security group assigned to the Worker node in [EC2 Instances](https://console.aws.amazon.com/ec2).

If you have trouble connecting to the Public IP:Port of the worker, then the traffic may be blocked by a VPN/Firewall/Wifi Network Policy. You may try from a cell phone or tethered connection.
{{% /notice %}}

The UI here shows the default behavior, of all services being able to reach each other.

![full access](/images/calico-full-access.png)