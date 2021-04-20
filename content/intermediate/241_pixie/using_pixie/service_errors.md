---
title: "Observe Service Errors"
date: 2021-5-01T09:00:00-00:00
weight: 22
draft: false
---

Let’s see if we can figure out what is causing the application filtering bug we saw earlier in this tutorial.

Given that the bug exists on the “Catalogue” page, there’s a good chance that page involves the `catalogue` service.

Scroll down the page to the “Service List” table and select the `px-sock-shop/catalogue` service.

![service_deeplink](/images/pixie/service_deeplink.png)

Deep links embedded in script views allow you to easily navigate between scripts. Selecting any service name deep link will navigate you to the `px/service` script, which shows us the request statistics for the selected service.

![px_service](/images/pixie/px_service.png)

The `px/service` script view doesn't show any errors, but that might be because the time window isn’t large enough.

Change the `start_time` argument to be `-30m` (note the negative symbol) to make sure that our window is wide enough to include the time when we triggered the bug earlier. Once the script re-runs, you should one or more HTTP errors for the service:

![px_service_error](/images/pixie/px_service_error.png)

{{% notice info %}}
If you don’t see an HTTP error, try increasing the time window or manually re-trigger the bug in the web application (and re-running the script afterwards).
{{% /notice %}}