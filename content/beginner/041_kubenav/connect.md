---
title: "Access the Dashboard"
date: 2018-08-07T08:30:11-07:00
weight: 30
---

Now we can access the Kubernetes Dashboard

1. In your Cloud9 environment, click **Tools / Preview / Preview Running Application**
1. Scroll to **the end of the URL** and append:

```text
/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

The Cloud9 Preview browser doesn't appear to support the token authentication, so once you have the login screen in the cloud9 preview browser tab, press the **Pop Out** button to open the login screen in a regular browser tab, like below:
![popout](/images/popout.png)

Open a New Terminal Tab  and enter

```bash
aws eks get-token --cluster-name eksworkshop-eksctl | jq -r '.status.token'
```

Copy the output of this command and then click the radio button next to
*Token* then in the text field below paste the output from the last command.

![Token page](/images/dashboard-connect.png)

Then press *Sign In*.
