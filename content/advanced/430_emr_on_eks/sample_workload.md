---
title: "Run sample workload"
date: 2021-04-08T03:21:44-07:00
weight: 20
draft: false
---

Now let's run a sample workload using one of the inbuilt example scripts that calculates the value of pi.

List the virtual EMR clusters that you have, using the below command.


```
aws emr-containers list-virtual-clusters
```

Response:

```
{
    "virtualClusters": [
        {
            "id": "jokbdf64kj891f7iaaot3qo9q",
            "name": "arm5",
            "arn": "arn:aws:emr-containers:us-west-2:525158249545:/virtualclusters/bxtagsj2ahg31c3aualjd58sg",
            "state": "RUNNING",
            "containerProvider": {
                "type": "EKS",
                "id": "arm5",
                "info": {
                    "eksInfo": {
                        "namespace": "spark"
                    }
                }
            },
            "createdAt": "2021-04-08T09:32:43+00:00",
            "tags": {}
        }
    ]
}
```


We will need to use the id of the virtual cluster obtained from the above command to start the job run.

```
aws emr-containers start-job-run \
  --virtual-cluster-id=jokbdf64kj891f7iaaot3qo9q \
  --name=pi-2 \
  --execution-role-arn=arn:aws:iam::525158249545:role/EMRContainers-JobExecutionRole \
  --release-label=emr-6.2.0-latest \
  --job-driver='{
    "sparkSubmitJobDriver": {
      "entryPoint": "local:///usr/lib/spark/examples/src/main/python/pi.py",
      "sparkSubmitParameters": "--conf spark.executor.instances=2 --conf spark.executor.memory=2G --conf spark.executor.cores=2 --conf spark.driver.cores=1"
    }
  }'

  ```

You will be able to see the completed job in EMR console. It should look like below:

![EMR Console of virtual cluster and jobs](/images/emr-on-eks/virtual-cluster1.png)

In the next section we will cover how to use spark history server to view job history. We will also take a look at how to send logs to s3 and cloudwatch.