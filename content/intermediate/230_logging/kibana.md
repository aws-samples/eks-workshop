---
title: "Kibana"
date: 2020-07-21T22:23:34-04:00
draft: false
weight: 40
---

Finally Let's log into Kibana to visualize our logs.

```bash
echo "Kibana URL: https://${ES_ENDPOINT}/_plugin/kibana/
Kibana user: ${ES_DOMAIN_USER}
Kibana password: ${ES_DOMAIN_PASSWORD}"
```

![Kibana Login](/images/logging/kibana_01.png)

From the Kibana Welcome screen select __Explore on my own__

![Kibana Welcome Screen](/images/logging/kibana_02.png)

Now click __Connect to your Elasticsearch index__

![Kibana Connect to my Index](/images/logging/kibana_03.png)

Add __\*fluent-bit\*__ as the Index pattern and click __Next step__

![Kibana index Pattern 1](/images/logging/kibana_04.png)

Select __@timestamp__ as the Time filter field name and close the Configuration window by clicking on __Create index pattern__

![Kibana index Pattern 2](/images/logging/kibana_05.png)

Finally you can select __Discover__ from the left panel and start exploring the logs

![Kibana Explore](/images/logging/kibana_06.png)
