---
title: "OpenSearch Dashboards"
date: 2020-07-21T22:23:34-04:00
draft: false
weight: 40
---

Finally Let's log into OpenSearch Dashboards to visualize our logs.

```bash
echo "OpenSearch Dashboards URL: https://${ES_ENDPOINT}/_dashboards/
OpenSearch Dashboards user: ${ES_DOMAIN_USER}
OpenSearch Dashboards password: ${ES_DOMAIN_PASSWORD}"
```

![OpenSearch Dashboards Login](/images/logging/opensearch_01.png)

From the OpenSearch Dashboards Welcome screen select __Explore on my own__

![OpenSearch Dashboards Welcome Screen](/images/logging/opensearch_02.png)

Now click __Confirm__ button on Select your tenant screen

![OpenSearch Tenant Selection Screen](/images/logging/opensearch_03.png)

On the next screen click on OpenSearch Dashboards tile

![OpenSearch Dashboards Tile](/images/logging/opensearch_04.png)

Now click __Add your data__

![OpenSearch Dashboards Add Data](/images/logging/opensearch_05.png)

Now click __Create index Pattern__

![OpenSearch Dashboards Index Pattern](/images/logging/opensearch_06.png)

Add __\*fluent-bit\*__ as the Index pattern and click __Next step__

![OpenSearch Dashboards Index Pattern 1](/images/logging/opensearch_07.png)

Select __@timestamp__ as the Time filter field name and close the Configuration window by clicking on __Create index pattern__

![OpenSearch Dashboards Index Pattern 2](/images/logging/opensearch_08.png)

Finally you can select __Discover__ from the left panel and start exploring the logs

![OpenSearch Dashboards Explore](/images/logging/opensearch_09.png)
