---
title: "Access the Dashboard"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Now we can access the Kubernetes Dashboard

1. In your Cloud9 environment, click **Tools / Preview / Preview Running Application**
1. Scroll to **the end of the URL** and append:

```
/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

Open a New Terminal Tab  and enter
```
aws eks get-token --cluster-name eksworkshop-eksctl | jq -r '.status.token'
```

Copy the output of this command and then click the radio button next to
*Token* then in the text field below paste the output from the last command.

![Token page](/images/dashboard-connect.png)

Then press *Sign In*.

If you want to see the dashboard in a full tab, click the **Pop Out** button, like below:
![popout](/images/popout.png)
