---
title: "Argo Dashboard"
date: 2018-11-18T00:00:00-05:00
weight: 80
draft: false
---

### Argo Dashboard

![Argo Dashboard](/images/argo-dashboard.png)

Argo UI lists the workflows and visualizes each workflow (very handy for our last workflow).

To connect, use the same proxy connection setup in [Deploy the Official Kubernetes Dashboard](/dashboard/dashboard/).

{{%expand "Show me the command" %}}
```
kubectl proxy --port=8080 --address='0.0.0.0' --disable-filter=true &
```

This will start the proxy, listen on port 8080, listen on all interfaces, and
will disable the filtering of non-localhost requests.

This command will continue to run in the background of the current terminal's session.

{{% notice warning %}}
We are disabling request filtering, a security feature that guards against XSRF attacks.
This isn't recommended for a production environment, but is useful for our dev environment.
{{% /notice %}}

{{% /expand %}}

To access the Argo Dashboard:

1. In your Cloud9 environment, click **Preview / Preview Running Application**
1. Scroll to **the end of the URL** and append:

```
/api/v1/namespaces/argo/services/argo-ui/proxy/
```
