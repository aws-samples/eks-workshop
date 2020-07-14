---
title: "Kubeflow Dashboard"
date: 2019-08-22T00:00:00-08:00
weight: 20
draft: false
---

### Kubeflow Dashboard

Use **port-forward** to access Kubeflow dashboard

```
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```
In your Cloud9 environment, click **Tools / Preview / Preview Running Application** to access dashboard. You can click on Pop out window button to maximize browser into new tab.

Leave the current terminal running because if you kill the process, you will loose access to the dashboard. Open new Terminal to follow rest of the workshop

![dashboard](/images/kubeflow/dashboard-welcome.png)

Click on **Start Setup**

Specify the namespace as **eksworkshop**

![dashboard](/images/kubeflow/dashboard-create-namespace.png)

Click on **Finish** to view the dashboard

![dashboard](/images/kubeflow/dashboard-first-look.png)
