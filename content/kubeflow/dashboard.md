---
title: "Kubeflow Dashboard"
date: 2019-08-22T00:00:00-08:00
weight: 20
draft: false
---

### Kubeflow Dashboard

Get Kubeflow service endpoint:

```
kubectl get ingress -n istio-system -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

Access the endpoint address in a browser to see Kubeflow dashboard. It could take couple of minutes for Load Balancer to launch and health checks to pass

![dashboard](/images/kubeflow/dashboard-welcome.png)

Click on **Start Setup**

Specify the namespace as **eksworkshop**

![dashboard](/images/kubeflow/dashboard-create-namespace.png)

Click on **Finish** to view the dashboard

![dashboard](/images/kubeflow/dashboard-first-look.png)
