---
title: "Monitoring and logging Part 1 - Setup"
date: 2021-04-08T04:25:46-07:00
weight: 30
draft: false
---

Logs from the EMR jobs can be sent to cloudwatch and s3. In the last section of running sample job, we did not configure logging

We will run the job again now, only this time we will send the logs to s3 and cloudwatch.

Let's create a cloudwatch log group before we can start sending the logs.

```
aws logs create-log-group --log-group-name=/emr-on-eks/eksworkshop-eksctl

```

Let's make sure that we have the variables set for the S3 bucket, virtual EMR clusters id, and the ARN of the role that EMR uses for job execution.

```bash
export s3DemoBucket=s3://emr-eks-demo-${ACCOUNT_ID}-${AWS_REGION}
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?state=='RUNNING'].id" --output text)
export EMR_ROLE_ARN=$(aws iam get-role --role-name EMRContainers-JobExecutionRole --query Role.Arn --output text)

```

Now let's run the job again with logging enabled.

```
cat > request.json <<EOF 
{
    "name": "pi-4",
    "virtualClusterId": "${VIRTUAL_CLUSTER_ID}",
    "executionRoleArn": "${EMR_ROLE_ARN}",
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
                "logUri": "${s3DemoBucket}/"
            }
        }
    }
}
EOF

```

Trigger the Spark job
```
aws emr-containers start-job-run --cli-input-json file://request.json
```



Output:

{{< output >}}
    "id": "00000002u5ipstrq84e",
    "name": "pi-4",
    "arn": "arn:aws:emr-containers:us-west-2:xxxxxxxxxxx:/virtualclusters/jokbdf64kj891f7iaaot3qo9q/jobruns/00000002u5ipstrq84e",
    "virtualClusterId": "jokbdf64kj891f7iaaot3qo9q"
{{< /output >}}






