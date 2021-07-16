---
title: "Logging with AWS Fargate"
chapter: true
weight: 181
pre: '<i class="fa" aria-hidden="true"></i> '
tags:
  - beginner
---

# Logging with AWS Fargate

In this chapter we will learn about how to setup [Logging with AWS Fargate](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html).

![Fargate Logging Architecture](/images/fargate-logging/fargate_logging_architecture.png)

Amazon EKS with Fargate supports a built-in log router, which means there are no sidecar containers to install or maintain. The log router allows you to use the breadth of services at AWS for log analytics and storage. You can stream logs from Fargate directly to Amazon CloudWatch, Amazon Elasticsearch Service, and Amazon Kinesis Data Firehose destinations such as Amazon S3, Amazon Kinesis Data Streams, and partner tools. Fargate uses a version of AWS for Fluent Bit, an upstream compliant distribution of Fluent Bit managed by AWS. For more information, see [AWS for Fluent Bit](https://github.com/aws/aws-for-fluent-bit) on GitHub.
