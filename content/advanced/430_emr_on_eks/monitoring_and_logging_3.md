---
title: "Monitoring and logging  Part 4 - Prometheus and Grafana"
date: 2021-04-08T04:25:46-07:00
weight: 33
draft: false
---

You will need to have prometheus and grafana installed before you can proceed with this section.

You can follow the [Prometheus and Grafana](/intermediate/240_monitoring/) sections to get the steps to install both of these. 

You can also use [Amazon Managed Service for Prometheus](https://aws.amazon.com/prometheus/) and [Amazon Managed Service for Grafana](https://aws.amazon.com/grafana/). In order to get started with these, follow the official docs for [AMP](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-getting-started.html) and [AMG](https://docs.aws.amazon.com/grafana/latest/userguide/getting-started-with-AMG.html).

Once you have Prometheus and Grafana installed, head over to Grafana, and import the dashboard **11674**.

Now run the below job:

```
aws emr-containers start-job-run \
  --virtual-cluster-id=${VIRTUAL_CLUSTER_ID} \
  --name=pi-2 \
  --execution-role-arn=${EMR_ROLE_ARN} \
  --release-label=emr-6.2.0-latest \
  --job-driver='{
    "sparkSubmitJobDriver": {
      "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
      "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
    }
  }'

  ```

Once the job is started, head over to the dashboard and select the namespace spark as shown below. 


![EMR on EKS cloudwatch logs](/images/emr-on-eks/grafana_1.png)

You will be able to see the resource utilization by spark for running your job.

