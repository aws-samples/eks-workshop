---
title: "Serverless EMR job"
date: 2021-05-19T04:02:10+10:00
weight: 60
draft: false
---

### Submit job to AWS Fargate

Before we schedule an EMR job running in a serverless environment, a Fargate profile is needed on the EKS cluster, that specifies which of your Spark pods should use Fargate when they are launched. 

Running applications on Fargate, makes it easy for you to focus on deliverying business values, as it removes the need to provision, configure autoscaling, and manage the server. For more information, see [AWS Fargate profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) and our previous lab [Creating a Fargate Profile](beginner/180_fargate/creating-profile/).

Firstly, create your Fargate profile with the following eksctl command:

```sh 
eksctl create fargateprofile --cluster eksworkshop-eksctl --name emr --namespace spark --labels type=notebook

```

The sample job was built in a [Jupyter notebook](https://github.com/aws-samples/sql-based-etl-on-amazon-eks/blob/main/emr-on-eks/green_taxi_load.ipynb), so you use the '`notebook`' job type to tag the Spark pods. Ensure they are hosted by the serverless compute engine AWS Fargate only. The configuration looks like this:

```yaml
--conf spark.kubernetes.driver.label.type=notebook 
--conf spark.kubernetes.executor.label.type=notebook
```

Get your existing resources from EMR:

```sh
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?state=='RUNNING'].id" --output text)

export EMR_ROLE_ARN=$(aws iam get-role --role-name EMRContainers-JobExecutionRole --query Role.Arn --output text)
```

Submit the job:

```sh
aws emr-containers start-job-run --virtual-cluster-id $VIRTUAL_CLUSTER_ID \
  --name nyctaxi-job \
  --execution-role-arn $EMR_ROLE_ARN \
  --release-label emr-6.2.0-latest \
  --job-driver '{
   "sparkSubmitJobDriver": {
      "entryPoint": "https://repo1.maven.org/maven2/ai/tripl/arc_2.12/3.6.2/arc_2.12-3.6.2.jar",
      "entryPointArguments":["--etl.config.uri=https://raw.githubusercontent.com/aws-samples/sql-based-etl-on-amazon-eks/main/emr-on-eks/green_taxi_load.ipynb"],
      "sparkSubmitParameters": "--packages com.typesafe:config:1.4.0 --class ai.tripl.arc.ARC --conf spark.executor.instances=10 --conf spark.executor.memory=5G --conf spark.driver.memory=2G --conf spark.executor.cores=3 --conf spark.kubernetes.driverEnv.ETL_CONF_ENV=test --conf spark.kubernetes.driver.label.type=notebook --conf spark.kubernetes.executor.label.type=notebook --conf spark.kubernetes.driverEnv.OUTPUT=s3://'${s3DemoBucket}'/output/ --conf spark.kubernetes.driverEnv.SCHEMA=https://raw.githubusercontent.com/aws-samples/sql-based-etl-on-amazon-eks/main/emr-on-eks/green_taxi_schema.json"x}}' \
   --configuration-overrides '{"monitoringConfiguration": {"cloudWatchMonitoringConfiguration": {"logGroupName": "/aws/eks/eksworkshop-eksctl/jobs", "logStreamNamePrefix": "fargate-job"}}}'
```

navigate to view the job status on Spark history server:

```sh
echo "https://console.aws.amazon.com/elasticmapreduce/home?region=us-east-1#virtual-cluster-jobs:"${VIRTUAL_CLUSTER_ID}
```
![spark_log](/images/emr-on-eks/spark_log.png)

Navigate to the output S3 bucket to view the job outputs:

```sh
echo "https://s3.console.aws.amazon.com/"${s3DemoBucket}
```


As the EMR job requested 10 executors, the number of Fargate instances will increase from 0 to 10. The autoscaling and multi-AZs support are build-in features with no manual effort needed.

Run the script to observe the autoscaling status:

```sh
kubectl get node --label-columns=eks.amazonaws.com/capacityType,topology.kubernetes.io/zone
```
![fargate_autoscale](/images/emr-on-eks/fargate_autoscaling.png)