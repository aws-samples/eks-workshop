---
title: "Serverless EMR job Part 2 - Monitor & Troubleshoot"
date: 2021-05-19T04:02:10+10:00
weight: 60
draft: false
---

#### Monitoring job status

With zero manual effort, the number of Fargate instances change dynamically and distribute across mutliple availability zones. Both autoscaling and multi-AZs support are Out-of-the-Box features.

Watch autoscaling status:
```sh
watch kubectl get pod -n spark
```
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

Fargate supports 4vCPUs max. Let's submit the same job with 5 vCPUs to force the failure.
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
kubectl get pod -n spark
```
![](/images/emr-on-eks/job_hang.png)

Check Spark driver's log once it's running.
```sh
driver_name=$(kubectl get po -n spark | grep "driver" | awk '{print $1}')
kubectl logs ${driver_name} -n spark -c spark-kubernetes-driver
```
The job is not accepted by any resources:
![not_resource](/images/emr-on-eks/not_enough_vcpu.png)

Investigate a hanging executor pod:
```sh
exec_name=$(kubectl get po -n spark | grep "exec-1" | awk '{print $1}')
kubectl describe po ${exec_name} -n spark
```
Congratulations! You found the root cause:
![](/images/emr-on-eks/executor_log.png)