---
title: "Configure CloudWatch Logs and Kibana"
date: 2018-08-07T08:30:11-07:00
weight: 40
---

### Configure CloudWatch Logs Subscription

CloudWatch Logs can be delivered to other services such as Amazon Elasticsearch for custom processing. This can be achieved by subscribing to a real-time feed of log events. A subscription filter defines the filter pattern to use for filtering which log events gets delivered to Elasticsearch, as well as information about where to send matching log events to.

In this section, we’ll subscribe to the CloudWatch log events from the fluent-cloudwatch stream from the eks/eksworkshop-eksctl log group. This feed will be streamed to the Elasticsearch cluster.

Original instructions for this are available at:

http://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_ES_Stream.html

```
mkdir ~/environment/iam_policy/
cat <<EoF > ~/environment/iam_policy/lambda.json
{
   "Version": "2012-10-17",
   "Statement": [
   {
     "Effect": "Allow",
     "Principal": {
        "Service": "lambda.amazonaws.com"
     },
   "Action": "sts:AssumeRole"
   }
 ]
}
EoF

aws iam create-role --role-name lambda_basic_execution --assume-role-policy-document file://~/environment/iam_policy/lambda.json

aws iam attach-role-policy --role-name lambda_basic_execution --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

Go to the [CloudWatch Logs console](https://console.aws.amazon.com/cloudwatch/home?#logs:)

Select the log group `/eks/eksworkshop-eksctl/containers`. Click on `Actions` and select `Stream to Amazon ElasticSearch Service`.
![Stream to ElasticSearch](/images/logging_cwl_es.png)

Select the ElasticSearch Cluster `kubernetes-logs` and IAM role `lambda_basic_execution`

![Subscribing to logs](/images/logging-cloudwatch-es-subscribe-iam.png)

Click `Next`

Select `Common Log Format` and click `Next`

![ES Log Format](/images/logging-cloudwatch-es-subscribe-log-format.png)

Review the configuration. Click `Next` and then `Start Streaming`

![Review ES Subscription](/images/logging-cloudwatch-es-subscribe-confirmation.png)

Cloudwatch page is refreshed to show that the filter was successfully created

### Configure Kibana

In Amazon Elasticsearch console, select the [kubernetes-logs under My domains](https://console.aws.amazon.com/es/home?#domain:resource=kubernetes-logs;action=dashboard)

![ElasticSearch Details](/images/logging_es_details.png)

Open the Kibana dashboard from the link. After a few minutes, records will begin to be indexed by ElasticSearch. You'll need to configure an index patterns in Kibana.

Set `Index Pattern` as **cwl-\*** and click `Next`

![Index Pattern](/images/logging_index_pattern.png)

Select `@timestamp` from the dropdown list and select `Create index pattern`

![Index Pattern](/images/logging_time_filter.png)

![Kibana Summary](/images/logging_kibana.png)

Click on `Discover` and explore your logs

![Kibana Dashboard](/images/logging_kibana_dashboard.png)
