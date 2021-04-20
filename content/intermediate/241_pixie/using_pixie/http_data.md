---
title: "Inspect the HTTP Request"
date: 2021-5-01T09:00:00-00:00
weight: 23
draft: false
---

Not only can Pixie automatically trace traffic, it can also see the full request and response bodies for [supported protocols](https://docs.pixielabs.ai/about-pixie/observability/). Let’s use Pixie to see the contents of this HTTP request with error.


### Inspect the HTTP Request

Select the `px/http_data` script from the script drop-down menu and change the `start_time` to `-30m` or any window that will include when you triggered the bug.

This script shows the traced HTTP1/2 requests made within your cluster, as long as the request either originates or is received inside of your cluster. There is quite a bit of HTTP traffic in this cluster, so let’s filter it to only show errors.

Open the script editor using `ctrl+e` (Windows, Linux) or `cmd+e` (Mac).

![script_editor](/images/pixie/script_editor.png)

Delete line 29 and replace it with the following.

```bash
df.service = df.ctx['service']
df = df[df.service == 'px-sock-shop/catalogue']
df = df[df.resp_status >= 400]
```

This code gets the service metadata for the pod making the HTTP request and filters the requests to only include those made by the `catalogue` service and those with errors codes.

{{% notice info %}}
Pixie specifies services and pods using the `namespace/<pod_name,service_name>` format.
{{% /notice %}}

Re-run the script with the RUN button (top right of the page), or using the keyboard shortcut: `ctrl+enter` (Windows, Linux) or `cmd+enter` (Mac).

Hide the script editor using the same command to show it: ctrl+e (Windows, Linux) or cmd+e (Mac).

The output should the request with the error you recently triggered. Click on a row to inspect the row data in json format. Scroll down to the `resp_body` json key and you can see that our error is a `database connection error`.

![http_request_error](/images/pixie/http_request_error.png)

