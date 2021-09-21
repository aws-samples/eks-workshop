---
title: "Serverless EMR job Part 2 - Monitor & Troubleshoot"
date: 2021-05-19T04:02:10+10:00
weight: 60
draft: false
---

#### Monitoring job status

With zero manual effort, the number of Fargate instances change dynamically and distribute across mutliple availability zones. You can again open up couple of terminals and use watch command to see this change.

Watch pod status:
```sh
watch kubectl get pod -n spark
```
Watch node scaling activities: 
```sh
watch kubectl get node \
--label-columns=eks.amazonaws.com/capacityType,topology.kubernetes.io/zone
```
![fargate_autoscale](/images/emr-on-eks/fargate_autoscaling.png)

Navigate to SparkUI to view job status:
```sh
echo -e "\nNavigate to EMR virtual cluster console:\n\nhttps://console.aws.amazon.com/elasticmapreduce/home?"region=${AWS_REGION}"#virtual-cluster-jobs:"${VIRTUAL_CLUSTER_ID}"\n"
```
![spark_log](/images/emr-on-eks/spark_log.png)

View output in S3, once it's done (~ 10min):
```sh
aws s3 ls ${s3DemoBucket}/output/ --summarize --human-readable --recursive
```

#### Troubleshooting

Fargate has flexible configuration options to run your workloads. However, it supports up to 4 vCPU and 30 GB Memory per compute instance. It applies to each of your Spark executors or the driver. Check out the current supported configurations and limits [here](https://aws.amazon.com/fargate/pricing/).

Let's submit the same job with 5 vCPUs that is over the limit to force the failure.
```sh
aws emr-containers start-job-run \
  --virtual-cluster-id $VIRTUAL_CLUSTER_ID \
  --name word_count \
  --execution-role-arn $EMR_ROLE_ARN \
  --release-label emr-6.2.0-latest \
  --job-driver '{
    "sparkSubmitJobDriver": {
      "entryPoint": "'$s3DemoBucket'/wordcount.py",
      "entryPointArguments":["'$s3DemoBucket'/output/"], 
      "sparkSubmitParameters": "--conf spark.kubernetes.driver.label.type=etl --conf spark.kubernetes.executor.label.type=etl --conf spark.executor.instances=8 --conf spark.executor.memory=2G --conf spark.driver.cores=1 --conf spark.executor.cores=5"
    }
  }'
   ```

Problem - the job is stuck with pending status.
```sh
watch kubectl get pod -n spark
```
Wait for about 2 minutes. Press ctl+c to exit, as soon as the Spark driver is running. 
![](/images/emr-on-eks/job_hang.png)

Check the driver’s log:
```sh
driver_name=$(kubectl get pod -n spark | grep "driver" | awk '{print $1}')
kubectl logs ${driver_name} -n spark -c spark-kubernetes-driver
```
The job is not accepted by any resources:
![not_resource](/images/emr-on-eks/not_enough_vcpu.png)

Investigate a hanging executor pod:
```sh
exec_name=$(kubectl get pod -n spark | grep "exec-1" | awk '{print $1}')
kubectl describe pod ${exec_name} -n spark
```
Congratulations! You found the root cause:
![](/images/emr-on-eks/executor_log.png)

Delete the driver pod to stop the hanging job:
```sh
kubectl delete pod ${driver_name} -n spark

# check job status
kubectl get pod -n spark
```
![](/images/emr-on-eks/submitter_terminate.png)
