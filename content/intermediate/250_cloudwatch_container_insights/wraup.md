---
title: "Wrapping Up"
chapter: false
weight: 12
---

#### Wrapping Up

As you can see it’s fairly easy to get CloudWatch Container Insights to work, and set alarms for CPU and other metrics.

With CloudWatch Container Insights we remove the need to manage and update your own monitoring infrastructure and allow you to use native AWS solutions that you don’t have to manage the platform for.

***

#### Cleanup your Environment

Let's clean up Wordpress so it's not running in your cluster any longer.

```bash
helm -n wordpress-cwi uninstall understood-zebu

kubectl delete namespace wordpress-cwi
```

Run the following command to delete Container Insights from your cluster.

```bash
curl -s https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluentd-quickstart.yaml | sed "s/{{cluster_name}}/eksworkshop-eksctl/;s/{{region_name}}/${AWS_REGION}/" | kubectl delete -f -
```

Delete the SNS topic and the subscription.

```bash
# Delete the SNS Topic
aws sns delete-topic \
  --topic-arn arn:aws:sns:${AWS_REGION}:${ACCOUNT_ID}:wordpress-CPU-Alert

# Delete the subscription
aws sns unsubscribe \
  --subscription-arn $(aws sns list-subscriptions | jq -r '.Subscriptions[].SubscriptionArn')
```

Finally we will remove the _CloudWatchAgentServerPolicy_ policy from the Nodes IAM Role

```bash
aws iam detach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy \
  --role-name ${ROLE_NAME}
```

## Thank you for using CloudWatch Container Insights!

{{% notice tip%}}
There is a lot more to learn about our Observability features using Amazon CloudWatch and AWS X-Ray. Take a look at our [One Observability Workshop](https://observability.workshop.aws)
{{% /notice%}}
