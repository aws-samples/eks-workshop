---
title: "Argo Dashboard"
date: 2018-11-18T00:00:00-05:00
weight: 80
draft: false
---

### Argo Dashboard

![Argo Dashboard](/images/argo-dashboard.png)

Argo UI lists the workflows and visualizes each workflow (very handy for our last workflow).

To connect, use the same proxy connection setup in [Deploy the Official Kubernetes Dashboard](/beginner/040_dashboard/).

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

You will see the `teardrop` workflow from [Advanced Batch Workflow](/advanced/410_batch/workflow-advanced/). Click on it to see a visualization of the workflow.

![Argo Workflow](/images/argo-workflow.png)

The workflow should _relatively_ look like a teardrop, and provide a live status for each job. Click on **Hotel** to see a summary of the Hotel job.

![Argo Hotel Job](/images/argo-hotel-job.png)

This details basic information about the job, and includes a link to the Logs. The Hotel job logs list the job dependency chain and the current `whalesay`, and should look similar to:

{{< output >}}
Chain:
Alpha
Bravo
Charlie
Echo
Foxtrot
____________________
< This is Job Hotel! >
--------------------
   \
    \
     \
                   ##        .
             ## ## ##       ==
          ## ## ## ##      ===
      /""""""""""""""""___/ ===
 ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
      \______ o          __/
       \    \        __/
         \____\______/
{{< /output >}}

Explore the other jobs in the workflow to see each job's status and logs.
