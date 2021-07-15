---
title: "Cleanup"
date: 2021-06-15T00:00:00-00:00
weight: 90
---
solution anymore.
Run the cleanup script with your CloudFormation stack name. The default name is
SparkOnEKS:

```bash
cd sql-based-etl-on-amazon-eks/spark-on-eks
./deployment/delete_all.sh <OPTIONAL:stack_name>
```

On the AWS CloudFormation console, manually delete the remaining resources if needed.