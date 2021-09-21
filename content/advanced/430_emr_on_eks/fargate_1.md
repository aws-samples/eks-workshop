---
title: "Serverless EMR job Part 1 - Setup"
date: 2021-05-19T04:02:10+10:00
weight: 60
draft: false
---

Running applications on the serverless compute engine AWS Fargate, makes it easy for you to focus on deliverying business values, as it removes the need to provision, configure autoscaling, and manage the server.

Before we schedule a serverless EMR job on Amazon EKS, a Fargate profile is needed, that specifies which of your Spark pods should use Fargate when they are launched. For more information, see [AWS Fargate profile](https://docs.aws.amazon.com/eks/latest/userguide/fargate-profile.html) and our previous lab [Creating a Fargate Profile](/beginner/180_fargate/creating-profile/).

#### Create Fargate Profile

Add your Fargate profile to EKS by the following command:
```sh 
eksctl create fargateprofile --cluster eksworkshop-eksctl --name emr \
--namespace spark --labels type=etl
```

The `labels` setting provides your application a way to target a particular group of compute resources on EKS.

To ensure your job is picked up by Fargate not by the managed nodegroup on EC2, tag your Spark application by the same `etl` label. 

The configuration looks like this:
```yaml
--conf spark.kubernetes.driver.label.type=etl 
--conf spark.kubernetes.executor.label.type=etl
```

#### Submit a job

The sample job we will submit reads a public [Amazon customer Reviews Dataset](https://s3.amazonaws.com/amazon-reviews-pds/readme.html) (~ 50GB), then counts the total number of words in reviews.

Firstly, setup a permission for data source and target.
```sh
cat <<EoF > review-data-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListObject"
            ],
            "Resource": [
                "arn:aws:s3:::amazon-reviews-pds/parquet/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${s3DemoBucket:5}/output/*"
            ]
        }]
     }
EoF

aws iam put-role-policy --role-name EMRContainers-JobExecutionRole --policy-name review-data-access --policy-document file://review-data-policy.json
```

Secondly, upload the application code to S3.
```sh
# create a pySpark job
cat << EOF >wordcount.py
import sys
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName('Amazon reviews word count').getOrCreate()

df = spark.read.parquet("s3://amazon-reviews-pds/parquet/")
df.selectExpr("explode(split(lower(review_body), ' ')) as words").groupBy("words").count().write.mode("overwrite").parquet(sys.argv[1])
exit()

EOF
# upload the script
aws s3 cp wordcount.py ${s3DemoBucket}
```

Next, get existing EMR resources.
```sh
export VIRTUAL_CLUSTER_ID=$(aws emr-containers list-virtual-clusters --query "virtualClusters[?state=='RUNNING'].id" --output text)

export EMR_ROLE_ARN=$(aws iam get-role --role-name EMRContainers-JobExecutionRole --query Role.Arn --output text)
```

Finally, start a serverless EMR job on EKS
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
      "sparkSubmitParameters": "--conf spark.kubernetes.driver.label.type=etl --conf spark.kubernetes.executor.label.type=etl --conf spark.executor.instances=8 --conf spark.executor.memory=2G --conf spark.driver.cores=1 --conf spark.executor.cores=3"}}' \
  --configuration-overrides '{
    "applicationConfiguration": [{
        "classification": "spark-defaults", 
        "properties": {"spark.kubernetes.allocation.batch.size": "8"}
    }],
    "monitoringConfiguration": {
      "s3MonitoringConfiguration": {
         "logUri": "'${s3DemoBucket}'/fargate-logs/"}}
  }'
```
