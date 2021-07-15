---
title: "SQL-based ETL with Spark on EKS"
date: 2021-06-15T00:00:00-00:00
weight: 450
chapter: true
aliases:
    - /sql_spark_eks/
tags:
  - advanced
  - etl
  - spark
---
# SQL-based ETL pipeline with Apache Spark on Amazon EKS

[Apache Spark](https://spark.apache.org/) is an open-source, distributed data processing framework capable of
performing analytics on large-scale datasets, enabling businesses to derive insights from all
of their data whether it is structured, semi-structured, or unstructured in nature.
You can flexibly deploy Spark applications in multiple ways within your AWS environment,
including Amazon Elastic Kubernetes Service
(Amazon EKS). With the release of Spark 2.3, Kubernetes became a new resource scheduler
(in addition to YARN, Mesos, and Standalone) to provision and manage Spark workloads.
Increasingly, it has become the new standard resource manager for new Spark projects, as we
can tell from the popularity of the open-source project. With Spark 3.1, the Spark on
Kubernetes project is officially production-ready and Generally Available. More data
architecture and patterns are available for businesses to accelerate data-driven transitions.
However, for organizations accustomed to SQL-based data management systems and tools,
adapting to the modern data practice with Apache Spark may slow down the pace of
innovation.

In this workshop, we address this challenge by using the open-source data processing framework
Arc, which subscribes to the SQL-first design principle. Arc abstracts from Apache Spark
and container technologies, in order to foster simplicity whilst maximizing efficiency.

## What is the Arc data processing framework?

Data platforms often repeatedly perform extract, transform, and load (ETL) jobs to achieve
similar outputs and objectives. This can range from simple data operations, such as
standardizing a date column, to performing complex change data capture processes (CDC) to
track historical changes of a record. Although the outcomes are highly similar, the
productivity and cost can vary heavily if not implemented suitably and efficiently.

The Arc processing framework strives to enable data personas to build reusable and
performant ETL pipelines, without having to delve into the complexities of writing verbose
Spark code. Writing your ETL pipeline in native Spark may not scale very well for
organizations not familiar with maintaining code, especially when business requirements
change frequently. The SQL-first approach provides a declarative harness towards building
idempotent data pipelines that can be easily scaled and embedded within your continuous
integration and continuous delivery (CI/CD) process.