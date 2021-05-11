---
title: "Monitoring and logging Part 1 - Setup"
date: 2021-04-08T04:25:46-07:00
weight: 30
draft: false
---

Logs from the EMR jobs can be sent to cloudwatch and s3. In the last section of running sample job, we did not configure logging

We will run the job again now, only this time we will send the logs to s3 and cloudwatch.

Let's create a cloudwatch log group and an s3 bucket before we can start sending the logs.

```
aws s3 mb s3://emr-eks-logs-5656

aws logs create-log-group --log-group-name=/emr-on-eks/eksworkshop-eksctl

```

Now let's run the job again with logging enabled.

```
cat > request.json <<EOF 
{
    "name": "pi-4",
    "virtualClusterId": "jokbdf64kj891f7iaaot3qo9q",
    "executionRoleArn": "arn:aws:iam::525158249545:role/EMRContainers-JobExecutionRole",
    "releaseLabel": "emr-6.2.0-latest",
    "jobDriver": {
        "sparkSubmitJobDriver": {
            "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
            "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
        }
    },
    "configurationOverrides": {
        "applicationConfiguration": [
            {
                "classification": "spark-defaults",
                "properties": {
                  "spark.dynamicAllocation.enabled": "false",
                  "spark.kubernetes.executor.deleteOnTermination": "true"
                }
            }
        ],
        "monitoringConfiguration": {
            "cloudWatchMonitoringConfiguration": {
                "logGroupName": "/emr-on-eks/eksworkshop-eksctl",
                "logStreamNamePrefix": "pi"
            },
            "s3MonitoringConfiguration": {
                "logUri": "s3://emr-eks-logs-5656/"
            }
        }
    }
}
EOF

aws emr-containers start-job-run --cli-input-json file://request.json

  ```

Output:

```
{
    "id": "00000002u5ipstrq84e",
    "name": "pi-3",
    "arn": "arn:aws:emr-containers:us-west-2:525158249545:/virtualclusters/jokbdf64kj891f7iaaot3qo9q/jobruns/00000002u5ipstrq84e",
    "virtualClusterId": "jokbdf64kj891f7iaaot3qo9q"
}
```


<<<<<<< HEAD
Describe how to use spark history server, how to use S3 for logging, how to monitor jobs using prometheus & grafana.
=======
>>>>>>> 533142d8096b19820bb5412394fb6e79d569be03





