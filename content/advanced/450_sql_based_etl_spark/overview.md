---
title: "Overview"
date: 2021-06-15T00:00:00-00:00
weight: 10
---

This workshop comes with a ready-to-use blueprint, which automatically provisions the necessary
infrastructure and spins up two web interfaces in Amazon EKS to support interactive ETL
build and orchestration. Additionally, it enforces the best practice in data DevOps and CI/CD
deployment.
The following diagram illustrates the solution architecture.

![Solution](/images/sql-etl/architecture.png)

The solution has four main components:
* **Orchestration on Amazon EKS** – The solution offers a highly pluggable workflow
management layer. We use [Argo Workflows](https://argoproj.github.io/argo-workflows/) to orchestrate ETL jobs in a
declarative way. It’s consistent with the standard deployment method in Amazon
EKS. Apache Airflow and other workflow management tools are also available to use.

* **Data workload on Amazon EKS** – This represents a workspace on the same
Amazon EKS cluster, for you to build, test, and run ETL jobs interactively. It’s
powered by Jupyter Notebooks with a custom kernel called [Arc Jupyter](https://github.com/tripl-ai/arc-jupyter). Its Git
integration feature reinforces the best practice in CI/CD deployment operation. This
means every notebook created on a Jupyter instance must check in to a Git repository
for the standard source and version control. The Git repository should be your single
source of truth for the ETL workload. When your Jupyter notebook files (job
definition) and SQL scripts land to Git, followed by an Amazon Simple Storage
Service (Amazon S3) upload, it runs your ETL automatically or based on a time
schedule. The entire deployment process is seamless to prevent any unintentional
human mistakes.

* **Security** – This layer secures Arc, Jupyter Docker images, and other sensitive
information. The IAM roles for service accounts feature (IRSA) on Amazon EKS
provides token authorization with fine-grained access control to other AWS services.
In this solution, Amazon EKS integrates with Amazon Athena, AWS Glue, and S3
buckets securely, so you don’t need to maintain a long-lived AWS credential for your
applications. We also use Amazon CloudWatch for collecting ETL application logs
and monitoring Amazon EKS with the container insights enabled.

* **Data lake** – As an output of the solution, the data destination is an S3 bucket. You
should be able to query the data directly in Athena, backed up by a Data Catalog in
AWS Glue.