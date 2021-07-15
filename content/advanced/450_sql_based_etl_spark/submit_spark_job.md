---
title: "Submit a Spark Task"
date: 2021-06-15T00:00:00-00:00
weight: 70
---
we will reuse the Arc docker image, because it contains the latest Spark distribution. Let's run a native Spark job that is defined by k8s's CRD Spark Operator. It saves efforts on DevOps operation, as the way of deploying Spark application follows the same declarative approach in k8s. It is consistent with other business applications CICD deployment processes. The example demonstrates:

    Save cost with Amazon EC2 Spot instance type
    Dynamically scale a Spark application - via Dynamic Resource Allocation
    Self-recovery after losing a Spark driver
    Monitor a job on Spark WebUI


Execute a PySpark job

Submit a PySpark job deployment/app_code/job/wordcount.py to EKS as usual.

    ```bash
    # get an s3 bucket from CFN output
    app_code_bucket=$(aws cloudformation describe-stacks --stack-name SparkOnEKS --query "Stacks[0].Outputs[?OutputKey=='CODEBUCKET'].OutputValue" --output text)

    kubectl create -n spark configmap special-config --from-literal=codeBucket=$app_code_bucket
    kubectl apply -f source/example/native-spark-job-scheduler.yaml
    ```

Check job progress:

    ```bash
    kubectl get pod -n spark
    # watch progress on SparkUI
    # only works if submit the job from a local computer
    kubectl port-forward word-count-driver 4040:4040 -n spark
    # go to `localhost:4040` from your web browser
    ```

Run the job again if necessary:

    ```bash
    kubectl delete -f source/example/native-spark-job-scheduler.yaml
    kubectl apply -f source/example/native-spark-job-scheduler.yaml
    ```